const express = require('express');
const sql = require('mssql');
const router = express.Router();
const dbConfig = require('../dbConfig');
const { DateTime } = require('luxon');


// 헬스 체크
router.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', time: new Date().toISOString() });
});


// 센서 데이터 수신 후 유니티 클라
router.post('/sensor', async (req, res) => {
  const data = req.body;
  const createAt = data.CreateAt
  ? DateTime.fromISO(data.CreateAt, { zone: 'Asia/Seoul' }).toFormat('yyyy-LL-dd HH:mm:ss')
  : DateTime.now().setZone('Asia/Seoul').toFormat('yyyy-LL-dd HH:mm:ss');
   
  try {
    const pool = await sql.connect(dbConfig);
    await pool.request()
      .input('RID', sql.VarChar(100), String(data.RID))
      .input('SensorType', sql.NVarChar, String(data.SensorType))
      .input('EventType', sql.NVarChar, String(data.EventType))
      .input('X_Deg', sql.Float, data.X_Deg)
      .input('Y_Deg', sql.Float, data.Y_Deg)
      .input('Z_Deg', sql.Float, data.Z_Deg)
      .input('X_MM', sql.Float, data.X_MM)
      .input('Y_MM', sql.Float, data.Y_MM)
      .input('Z_MM', sql.Float, data.Z_MM)
      .input('BatteryVoltage', sql.Float, data.BatteryVoltage)
      .input('BatteryLevel', sql.Float, data.BatteryLevel)
      .input('Latitude', sql.Float, data.Latitude)
      .input('Longitude', sql.Float, data.Longitude)      
      .input('CreateAt', sql.VarChar, createAt)
      
      
      
      .query(`
        INSERT INTO dbo.RawSensorData
        (RID, SensorType, EventType, X_Deg, Y_Deg, Z_Deg, X_MM, Y_MM, Z_MM,
         BatteryVoltage, BatteryLevel, Latitude, Longitude,  CreateAt)
        VALUES
        (@RID, @SensorType, @EventType, @X_Deg, @Y_Deg, @Z_Deg, @X_MM, @Y_MM, @Z_MM,
         @BatteryVoltage, @BatteryLevel, @Latitude, @Longitude,  @CreateAt)
      `);

    console.log('✅ 센서 데이터 수신:', JSON.stringify(data, null, 2));

    // ✅ WebSocket 전송
    const wss = req.app.get('wss');
    if (wss && wss.clients) {
      const payload = {
        type: 'iotSensorUpdate',
        source: 'server',
        data: {
          ...data,
          CreateAt: data.CreateAt
        }
      };

      wss.clients.forEach(client => {
        if (client.readyState === 1) {
          client.send(JSON.stringify(payload));
        }
      });
    }

    res.status(200).json({ message: '저장 성공', data });

  } catch (err) {
    console.error('❌ DB 오류:', err);
    res.status(500).json({ error: 'DB 저장 실패' });
  }
});


router.post('/test_submit_data', (req, res) => {
  const WebSocket = require('ws');
  const wss = req.app.get('wss');

  const data = req.body;

  const payload = {
    type: 'iotSensorUpdate',
    source: 'client',
    data
  };

  // 🔁 WebSocket으로 클라이언트 데이터만 브로드캐스트
  wss.clients.forEach(client => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(JSON.stringify(payload));
    }
  });

  return res.status(200).json({ message: 'WebSocket broadcast 성공', data });
});

router.get('/progress', async (req, res) => {
  try {
    const pool = await sql.connect(dbConfig); // ✅ 추가
    const result = await pool.request().query(`
      SELECT TOP 1 progress FROM WorkProgress ORDER BY updated_at DESC
    `);
    res.json({ progress: result.recordset[0]?.progress || 0 });
  } catch (err) {
    console.error('❌ Progress fetch error:', err); // ✅ 에러 로깅도 추가
    res.status(500).send('DB Error');
  }
});

router.post('/progress', async (req, res) => {
  const { progress } = req.body;
  try {
    const pool = await sql.connect(dbConfig); // ❗이 줄이 없으면 에러!
    await pool.request()
      .input('progress', sql.Float, progress)
      .query(`
        INSERT INTO WorkProgress (progress, updated_at) VALUES (@progress, GETDATE())
      `);
    res.sendStatus(200);
  } catch (err) {
    console.error('❌ DB 저장 실패:', err); // 디버깅 출력 추가
    res.status(500).send('DB Error');
  }
});

router.get('/recent-sensor-data', async (req, res) => {
  const days = parseInt(req.query.days || '1'); // 기본 1일
  try {
    const pool = await sql.connect(dbConfig);
    const result = await pool.request()
      .input('days', sql.Int, days)
      .query(`
        SELECT *
        FROM RawSensorData
        WHERE CreateAt >= DATEADD(DAY, -@days, GETDATE())
        ORDER BY CreateAt ASC
      `);

    res.status(200).json({ message: '최근 센서 데이터 조회 성공', data: result.recordset });
  } catch (err) {
    console.error('❌ 최근 센서 데이터 조회 실패:', err);
    res.status(500).json({ error: 'DB 조회 실패' });
  }
});






module.exports = router;
