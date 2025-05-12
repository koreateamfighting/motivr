require('dotenv').config();
const express = require('express');
const sql = require('mssql');
const cors = require('cors');
const { DateTime } = require('luxon');
const fs = require('fs');
const https = require('https');
const { Server } = require('socket.io'); // socket.io 추가

const app = express();
app.use(express.json());
app.use(cors());
app.use(express.static('public'));


const sslOptions = {
  cert: fs.readFileSync('C:/Users/Administrator/fullchain.pem'),
  key: fs.readFileSync('C:/Users/Administrator/privkey.pem'),
};

const dbConfig = {
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  server: process.env.DB_SERVER,
  database: process.env.DB_NAME,
  port: parseInt(process.env.DB_PORT),
  options: {
    trustServerCertificate: true,
  },
};

// HTTPS 서버 생성
const server = https.createServer(sslOptions, app);

// WebSocket 서버 설정 (https 기반)
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"],
  },
});

// WebSocket 연결
io.on('connection', (socket) => {
  console.log(`🔵 WebSocket 연결됨: ${socket.id}`);
  socket.on('disconnect', () => {
    console.log(`🔴 WebSocket 연결 해제: ${socket.id}`);
  });
});

// 헬스 체크 API
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', time: new Date().toISOString() });
});

// 센서 데이터 수신 API
app.post('/api/sensor', async (req, res) => {
  const data = req.body;
  const nowKST = DateTime.now().setZone('Asia/Seoul').toJSDate();

  try {
    const pool = await sql.connect(dbConfig);
    await pool.request()
      .input('RID', sql.VarChar(100), String(data.RID))
      .input('SensorType', sql.VarChar, String(data.SensorType))
      .input('EventType', sql.VarChar, String(data.EventType))
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

    console.log('✅ 수신된 데이터:', JSON.stringify(data, null, 2));
    res.status(200).json({ message: '저장 성공', data });
  } catch (err) {
    console.error('DB 오류:', err);
    res.status(500).json({ error: 'DB 저장 실패' });
  }
});

// 테스트용 API
app.post('/api/test_submit_data', (req, res) => {
  console.log("📥 Raw body:", req.body);

  // 클라이언트가 보낸 메시지 형태가 { message: '내용' }인 경우
  const { message } = req.body;

  if (message) {
    console.log(`📩 수신된 메시지: ${message}`);

    const ServerResponse = {
      ID: "테스트",
      val: "250512"
    };

    // WebSocket을 통해 클라이언트들에게 전송
    io.emit('new_data', ServerResponse);

    return res.status(200).json({ sent: ServerResponse });
  }

  // 기존 방식도 유지
  const { ID, val } = req.body;

  if (!ID || val === undefined) {
    console.log('❌ 전송된 ID 또는 val 없음');
    return res.status(400).json({ error: 'ID와 val 값이 모두 필요합니다.' });
  }

  console.log(`📩 수신된 데이터 - ID: ${ID}, val: ${val}`);
  io.emit('new_data', { ID, val });

  res.status(200).json({ receivedData: { ID, val } });
});


// HTTPS 서버 리스닝
server.listen(3030, () => {
  console.log('🚀 HTTPS Server running on https://0.0.0.0:3030');
});
