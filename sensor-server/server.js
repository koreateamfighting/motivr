require('dotenv').config();
const express = require('express');
const sql = require('mssql');
const cors = require('cors');
const { DateTime } = require('luxon');

const app = express();
app.use(express.json());
app.use(cors());
app.use(express.static('public'));

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


// ✅ 헬스체크 API
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', time: new Date().toISOString() });
});



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

app.listen(3000, () => {
  console.log('🚀 Server running on http://localhost:3000');
});
