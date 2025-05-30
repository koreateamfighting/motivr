const express = require('express');
const sql = require('mssql');
const { DateTime } = require('luxon');
const router = express.Router();
const dbConfig = require('../dbConfig');

// 헬스 체크
router.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', time: new Date().toISOString() });
});

// 센서 데이터 수신
router.post('/sensor', async (req, res) => {
  const data = req.body;
  const nowKST = DateTime.now().setZone('Asia/Seoul').toJSDate();

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
      .input('CreateAt', sql.DateTime, nowKST)
      .query(`
        INSERT INTO dbo.RawSensorData
        (RID, SensorType, EventType, X_Deg, Y_Deg, Z_Deg, X_MM, Y_MM, Z_MM,
         BatteryVoltage, BatteryLevel, Latitude, Longitude, CreateAt)
        VALUES
        (@RID, @SensorType, @EventType, @X_Deg, @Y_Deg, @Z_Deg, @X_MM, @Y_MM, @Z_MM,
         @BatteryVoltage, @BatteryLevel, @Latitude, @Longitude, @CreateAt)
      `);

    console.log('✅ 센서 데이터 수신:', JSON.stringify(data, null, 2));
    res.status(200).json({ message: '저장 성공', data });
  } catch (err) {
    console.error('❌ DB 오류:', err);
    res.status(500).json({ error: 'DB 저장 실패' });
  }
});

router.post('/test_submit_data', (req, res) => {
  const WebSocket = require('ws');
  const wss = req.app.get('wss');
  const { message, ID, val } = req.body;

  // 클라이언트가 보낸 데이터
  const clientPayload = {
    source: "client",
    receivedData: {
      ID,
      val: parseFloat(val)
    }
  };

  // 서버에서 보내는 응답
  const serverPayload = {
    source: "server",
    receivedData: {
      ID: "변위센서2",
      val: 12.34
    }
  };

  // 🔁 먼저 클라이언트 요청 내용을 그대로 브로드캐스트
  wss.clients.forEach(client => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(JSON.stringify(clientPayload));
    }
  });

  // 🔁 이어서 서버가 보내는 메시지도 같이 브로드캐스트
  setTimeout(() => {
    wss.clients.forEach(client => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(JSON.stringify(serverPayload));
      }
    });
  }, 500); // 0.5초 뒤 서버 응답처럼 보내기

  return res.status(200).json(clientPayload); // 응답은 클라이언트 내용
});






module.exports = router;
