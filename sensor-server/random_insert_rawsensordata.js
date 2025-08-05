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

async function insertAlarmHistoryFromSensorData(data, createAt, pool , transaction = null) {
  const { RID, Label, EventType, Latitude, Longitude } = data;
  const deviceId = `${Label} #${RID}`;
  const timestamp = createAt;

  let event = '점검필요';
  let log = `${deviceId} : 알려지지 않은 로그`;

  switch (parseInt(EventType)) {
    case 2:
      event = '정상';
      log = `${deviceId} : 정상 로그`;
      break;
    case 5:
      event = '정상';
      log = `${deviceId} : GPS 정상 수집`;
      break;
    case 67:
      event = '주의';
      log = `${deviceId} : 주의 로그`;
      break;
    case 68:
      event = '경고';
      log = `${deviceId} : 경고 로그`;
      break;
  }

  // ❗ 이전 값 유지 (Latitude, Longitude 없을 경우)
  const lastGeoQuery = `
    SELECT TOP 1 Latitude, Longitude
    FROM AlarmHistory
    WHERE DeviceID = @DeviceID
      AND Type = 'iot'
    ORDER BY Timestamp DESC
  `;
  const geoRequest = transaction ? transaction.request() : pool.request();  // ⬅ 위치 조회용
  let lat = Latitude;
  let lon = Longitude;
  
  if (lat == null || lon == null) {
    const prev = await geoRequest
      .input('DeviceID', sql.NVarChar(100), deviceId)
      .query(lastGeoQuery);
    if (lat == null) lat = prev.recordset[0]?.Latitude ?? null;
    if (lon == null) lon = prev.recordset[0]?.Longitude ?? null;
  }
  
  // ⬇ 알람 삽입은 별도의 request 사용!
  const insertRequest = transaction ? transaction.request() : pool.request();
  
  await insertRequest
    .input('DeviceID', sql.NVarChar(100), deviceId)
    .input('Timestamp', sql.DateTime, timestamp)
    .input('Event', sql.NVarChar(255), event)
    .input('Log', sql.NVarChar(1000), log)
    .input('Location', sql.NVarChar(255), Label)
    .input('Latitude', sql.Float, lat)
    .input('Longitude', sql.Float, lon)
    .input('Type', sql.NVarChar(20), 'iot')
    .query(`
      INSERT INTO AlarmHistory
      (DeviceID, Timestamp, Event, Log, Location, Latitude, Longitude, Type)
      VALUES
      (@DeviceID, @Timestamp, @Event, @Log, @Location, @Latitude, @Longitude, @Type)
    `);
}




(async () => {
  try {
    const pool = await sql.connect(config);
    const sensorType = '변위';
    const startDate = '2025-08-05';
    const endDate = '2025-08-05';
    const dateList = getDateRange(startDate, endDate);
    const ridToLabelMap = {};

    // 1. RID 별로 label 등록 및 캐싱
    for (let i = 1; i <= 20; i++) {
      const rid = `S1_${String(i).padStart(3, '0')}`;
      const label = `label_${rid}`;

      const check = await pool.request()
        .input('rid', sql.NVarChar(100), rid)
        .query(`SELECT Label FROM SenSorInfo WHERE RID = @rid`);

      if (check.recordset.length === 0) {
        const now = moment().tz('Asia/Seoul').format();
        await pool.request()
          .input('IndexKey', sql.UniqueIdentifier, uuidv4())
          .input('RID', sql.NVarChar(100), rid)
          .input('Label', sql.NVarChar(100), label)
          .input('CreateAt', sql.DateTimeOffset, now)
          .query(`
            INSERT INTO SenSorInfo (IndexKey, RID, Label, CreateAt)
            VALUES (@IndexKey, @RID, @Label, @CreateAt)
          `);
        console.log(`🆕 SenSorInfo 등록됨: ${rid}, Label=${label}`);
      } else {
        console.log(`✅ SenSorInfo 존재: ${rid}, Label=${check.recordset[0].Label}`);
      }

      ridToLabelMap[rid] = label;
    }

    // 2. 날짜별 데이터 삽입
    for (const date of dateList) {
      for (let i = 1; i <= 20; i++) {
        const rid = `S1_${String(i).padStart(3, '0')}`;
        const label = ridToLabelMap[rid];

        console.log(`🚀 ${rid} 데이터 삽입 시작`);

        // 🌍 GPS 데이터 (EventType 5)
        for (let h = 0; h < 24; h++) {
          const lat = random(37.12, 37.13);
          const lon = random(127.12, 127.13);
          const voltage = random(4.0, 4.6);
          const timestamp = moment.tz(`${date} ${to2(h)}:00:00`, 'Asia/Seoul').toDate();

          await pool.request()
            .input('RID', sql.NVarChar, rid)
            .input('Label', sql.NVarChar, label)
            .input('SensorType', sql.NVarChar, sensorType)
            .input('EventType', sql.NVarChar, '5')
            .input('Latitude', sql.Float, lat)
            .input('Longitude', sql.Float, lon)
            .input('BatteryVoltage', sql.Float, voltage)
            .input('BatteryLevel', sql.Float, 0)
            .input('CreateAt', sql.DateTime, timestamp)  
            .query(`
              INSERT INTO RawSensorData
              (RID, Label, SensorType, EventType, Latitude, Longitude, BatteryVoltage, BatteryLevel, CreateAt)
              VALUES (@RID, @Label, @SensorType, @EventType, @Latitude, @Longitude, @BatteryVoltage, @BatteryLevel, @CreateAt)
            `);
            await insertAlarmHistoryFromSensorData({
              RID: rid,
              Label: label,
              EventType: '5',
              Latitude: lat,
              Longitude: lon,
            }, timestamp, pool);
        }

        // 📈 주기 데이터 (EventType 2)
        for (let h = 0; h <= 23; h++) {
          for (const m of [9, 39]) {
            const xDeg = biasedRandom();
            const yDeg = biasedRandom();
            const zDeg = biasedRandom();
            const xMm = random(0, 100);
            const yMm = random(0, 100);
            const zMm = random(0, 100);
            const voltage = random(4.2, 4.6);
            const timestamp = `${date} ${to2(h)}:${to2(m)}:00`;

            await pool.request()
              .input('RID', sql.NVarChar, rid)
              .input('Label', sql.NVarChar, label)
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
                (RID, Label, SensorType, EventType, X_Deg, Y_Deg, Z_Deg, X_MM, Y_MM, Z_MM, BatteryVoltage, BatteryLevel, CreateAt)
                VALUES (@RID, @Label, @SensorType, @EventType, @X_Deg, @Y_Deg, @Z_Deg, @X_MM, @Y_MM, @Z_MM, @BatteryVoltage, @BatteryLevel, @CreateAt)
              `);
              await insertAlarmHistoryFromSensorData({
                RID: rid,
                Label: label,
                EventType: '2',
                Latitude: null,
                Longitude: null,
              }, timestamp, pool);
          }
        }
// 🚨 알람 데이터 (EventType 67: 주의, 68: 경고)
const alertTimes = [];
while (alertTimes.length < 10) {
  const hour = Math.floor(Math.random() * 24);
  const minute = Math.floor(Math.random() * 60);
  const time = `${to2(hour)}:${to2(minute)}`;
  if (!alertTimes.includes(time)) alertTimes.push(time);
}

for (const time of alertTimes) {
  const xDeg = biasedRandom();
  const yDeg = biasedRandom();
  const zDeg = biasedRandom();
  const xMm = random(0, 100);
  const yMm = random(0, 100);
  const zMm = random(0, 100);
  const voltage = random(4.2, 4.6);
  const timestamp = `${date} ${time}:00`;

  // ✅ EventType 결정: 5 이상이면 경고(68), 3 이상이면 주의(67)
  let eventType = null;
  if (Math.abs(xDeg) >= 5 || Math.abs(yDeg) >= 5 || Math.abs(zDeg) >= 5) {
    eventType = '68'; // 경고
  } else if (Math.abs(xDeg) >= 3 || Math.abs(yDeg) >= 3 || Math.abs(zDeg) >= 3) {
    eventType = '67'; // 주의
  } else {
    continue; // 3 미만이면 무시 (주의나 경고 아님)
  }

  await pool.request()
    .input('RID', sql.NVarChar, rid)
    .input('Label', sql.NVarChar, label)
    .input('SensorType', sql.NVarChar, sensorType)
    .input('EventType', sql.NVarChar, eventType)
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
      (RID, Label, SensorType, EventType, X_Deg, Y_Deg, Z_Deg,
       X_MM, Y_MM, Z_MM, BatteryVoltage, BatteryLevel, CreateAt)
      VALUES (@RID, @Label, @SensorType, @EventType, @X_Deg, @Y_Deg, @Z_Deg,
              @X_MM, @Y_MM, @Z_MM, @BatteryVoltage, @BatteryLevel, @CreateAt)
    `);
    await insertAlarmHistoryFromSensorData({
      RID: rid,
      Label: label,
      EventType: eventType,
      Latitude: null,
      Longitude: null,
    }, timestamp, pool);
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
