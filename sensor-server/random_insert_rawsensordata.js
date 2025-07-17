require('dotenv').config();
const sql = require('mssql');
const config = require('./dbConfig');
const moment = require('moment-timezone');
const { v4: uuidv4 } = require('uuid'); // ✅ UUID 생성기


function to2(n) {
  return String(n).padStart(2, '0');
}

function random(min, max) {
  return parseFloat((Math.random() * (max - min) + min).toFixed(2));
}

function getDateRange(start, end) {
  const dates = [];
  let current = new Date(start);
  const last = new Date(end);
  while (current <= last) {
    const yyyy = current.getFullYear();
    const mm = to2(current.getMonth() + 1);
    const dd = to2(current.getDate());
    dates.push(`${yyyy}-${mm}-${dd}`);
    current.setDate(current.getDate() + 1);
  }
  return dates;
}


// ±3 이상 값은 낮은 확률 (10%)만 나오게 조절
function biasedRandom() {
  const chance = Math.random();
  if (chance < 0.05) {
    return parseFloat((Math.random() < 0.5 ? random(3, 5) : random(-5, -3)).toFixed(2));
  } else {
    return parseFloat(random(-2.9, 2.9).toFixed(2));
  }
}

(async () => {
  try {
    const pool = await sql.connect(config);
    const sensorType = '변위';
    const startDate = '2025-07-01';
    const endDate = '2025-07-20';
    const dateList = getDateRange(startDate, endDate);
    
for (const date of dateList){
    for (let i = 1; i <= 20; i++) {
      const rid = `S1_${String(i).padStart(3, '0')}`;
      console.log(`🚀 ${rid} 데이터 삽입 시작`);

        // ✅ SenSorInfo에 RID 등록 여부 확인 + 자동 등록
    const sensorInfoCheck = await pool.request()
    .input('rid', sql.NVarChar(100), rid)
    .query(`SELECT COUNT(*) AS count FROM SenSorInfo WHERE RID = @rid`);

  if (sensorInfoCheck.recordset[0].count === 0) {
    const now = moment().tz('Asia/Seoul').format(); // ISO string with +09:00

    await pool.request()
      .input('IndexKey', sql.UniqueIdentifier, uuidv4())
      .input('RID', sql.NVarChar(100), rid)
      .input('Name', sql.NVarChar(100), 'unknown')
      .input('CreateAt', sql.DateTimeOffset, now)
      .query(`
        INSERT INTO SenSorInfo (IndexKey, RID, Name, CreateAt)
        VALUES (@IndexKey, @RID, @Name, @CreateAt)
      `);

    console.log(`🆕 SenSorInfo 자동 등록됨: ${rid}`);
  }

      // 🌍 GPS 데이터 (EventType 5, 00:00 ~ 23:00)
      for (let h = 0; h < 24; h++) {
        const m  = 0;
        const lat = random(37.12000, 37.13000);
        const lon = random(127.12000, 127.13000);
        const voltage = random(4.0, 4.6);
        const timestamp = `${date} ${to2(h)}:${to2(m)}:00`; // ← 문자열로 직접 전달 (UTC 해석 안 됨)



        await pool.request()
          .input('RID', sql.NVarChar, rid)
          .input('SensorType', sql.NVarChar, sensorType)
          .input('EventType', sql.NVarChar, '5')
          .input('Latitude', sql.Float, lat)
          .input('Longitude', sql.Float, lon)
          .input('BatteryVoltage', sql.Float, voltage)
          .input('BatteryLevel', sql.Float, 0)
          .input('CreateAt', sql.NVarChar, timestamp)
          .query(`
            INSERT INTO RawSensorData
            (RID, SensorType, EventType, Latitude, Longitude, BatteryVoltage, BatteryLevel, CreateAt)
            VALUES (@RID, @SensorType, @EventType, @Latitude, @Longitude, @BatteryVoltage, @BatteryLevel, @CreateAt)
          `);
      }

      // 📈 주기 데이터 (00:09 ~ 15:59, 30분 간격)
      for (let h = 0; h <= 23; h++) {
        for (let m of [9, 39]) {
          const xDeg = biasedRandom();
          const yDeg = biasedRandom();
          const zDeg = biasedRandom();
          const xMm = random(0, 100);
          const yMm = random(0, 100);
          const zMm = random(0, 100);
          const voltage = random(4.2, 4.6);
              const timestamp = `${date} ${to2(h)}:${to2(m)}:00`


          await pool.request()
            .input('RID', sql.NVarChar, rid)
            .input('SensorType', sql.NVarChar, sensorType)
            .input('EventType', sql.NVarChar, '2')
            .input('X_Deg', sql.Float, xDeg)
            .input('Y_Deg', sql.Float, yDeg)
            .input('Z_Deg', sql.Float, zDeg)
            .input('X_MM', sql.Float, xMm)
            .input('Y_MM', sql.Float, yMm)
            .input('Z_MM', sql.Float, zMm)
            .input('BatteryVoltage', sql.Float, voltage)
            .input('BatteryLevel', sql.Float, 0)
            .input('CreateAt', sql.NVarChar, timestamp)  
            .query(`
              INSERT INTO RawSensorData
              (RID, SensorType, EventType, X_Deg, Y_Deg, Z_Deg, X_MM, Y_MM, Z_MM, BatteryVoltage, BatteryLevel, CreateAt)
              VALUES (@RID, @SensorType, @EventType, @X_Deg, @Y_Deg, @Z_Deg, @X_MM, @Y_MM, @Z_MM, @BatteryVoltage, @BatteryLevel, @CreateAt)
            `);
        }
      }

      // 🚨 알람 데이터 (EventType 4, 03:12, 10:28만)
      const alerts = ['03:12', '10:28','17:59'];
      for (const time of alerts) {
        const xDeg = biasedRandom();
        const yDeg = biasedRandom();
        const zDeg = biasedRandom();
        const xMm = random(0, 100);
        const yMm = random(0, 100);
        const zMm = random(0, 100);
        const voltage = random(4.2, 4.6);
        
  // ✅ 문자열로 넘기기 (UTC 변환 없이 KST로 저장됨)
  const timestamp = `${date} ${time}:00`;
        await pool.request()
          .input('RID', sql.NVarChar, rid)
          .input('SensorType', sql.NVarChar, sensorType)
          .input('EventType', sql.NVarChar, '4')
          .input('X_Deg', sql.Float, xDeg)
          .input('Y_Deg', sql.Float, yDeg)
          .input('Z_Deg', sql.Float, zDeg)
          .input('X_MM', sql.Float, xMm)
          .input('Y_MM', sql.Float, yMm)
          .input('Z_MM', sql.Float, zMm)
          .input('BatteryVoltage', sql.Float, voltage)
          .input('BatteryLevel', sql.Float, 0)
          .input('CreateAt', sql.NVarChar, timestamp)
          .query(`
            INSERT INTO RawSensorData
            (RID, SensorType, EventType, X_Deg, Y_Deg, Z_Deg, X_MM, Y_MM, Z_MM, BatteryVoltage, BatteryLevel, CreateAt)
            VALUES (@RID, @SensorType, @EventType, @X_Deg, @Y_Deg, @Z_Deg, @X_MM, @Y_MM, @Z_MM, @BatteryVoltage, @BatteryLevel, @CreateAt)
          `);
      }
      

      console.log(`✅ ${rid} 데이터 삽입 완료`);
    }
  }
    await pool.close();
    console.log('🎉 모든 RID 데이터 삽입 완료!');
  } catch (err) {
    console.error('❌ 오류 발생:', err);
  }
})();

