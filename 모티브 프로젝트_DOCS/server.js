const express = require('express');
const { connectDB, sql } = require('./db');
const dotenv = require('dotenv');
const { parseHexData } = require('./parser'); // 파싱 함수 별도 분리
const cors = require('cors'); // 너가 쓰고 있었으니까 포함

dotenv.config();
const app = express();
app.use(express.json());
app.use(cors());
app.use(express.static('public'));
app.post('/api/sensor', async (req, res) => {
  const { group, number, hex } = req.body;

  if (!group || !number || !hex) {
    return res.status(400).send('입력값 부족');
  }

  const parsed = parseHexData(hex, group, number); // 파싱 실행
  console.log('[파싱 결과]', parsed);

  try {
    const pool = await connectDB();
    await pool.request()
      .input('GroupId', sql.VarChar, group)
      .input('NumberId', sql.VarChar, number)
      .input('DeviceId', sql.Int, parsed.DeviceId)
      .input('RawHex', sql.VarChar(sql.MAX), hex)
      .input('ParsedAt', sql.DateTime, new Date())
      .input('Status', sql.VarChar, parsed.Status || null)
      .input('EventType', sql.VarChar, parsed.EventType || null)
      .input('X_Deg', sql.Float, parsed.X || null)
      .input('Y_Deg', sql.Float, parsed.Y || null)
      .input('Z_Deg', sql.Float, parsed.Z || null)
      .input('BatteryVoltage', sql.Float, parsed.Battery || null)
      .input('Latitude', sql.Float, parsed.Lat || null)
      .input('Longitude', sql.Float, parsed.Lon || null)
      .input('AlertType', sql.VarChar, parsed.AlertType || null)
      .input('SendTryCount', sql.Int, 0)
      .input('SentAt', sql.DateTime, null)
      .input('CreatedAt', sql.DateTime, new Date())
      .input('UpdatedAt', sql.DateTime, new Date())
      .query(`
        INSERT INTO dbo.RawSensorData
        (GroupId, NumberId, DeviceId, RawHex, ParsedAt, Status, EventType, X_Deg, Y_Deg, Z_Deg, BatteryVoltage,
         Latitude, Longitude, AlertType, SendTryCount, SentAt, CreatedAt, UpdatedAt)
        VALUES
        (@GroupId, @NumberId, @DeviceId, @RawHex, @ParsedAt, @Status, @EventType, @X_Deg, @Y_Deg, @Z_Deg, @BatteryVoltage,
         @Latitude, @Longitude, @AlertType, @SendTryCount, @SentAt, @CreatedAt, @UpdatedAt)
      `);

    res.send('✅ 센서 데이터 저장 완료');
  } catch (err) {
    console.error('❌ DB 저장 오류:', err);
    res.status(500).send('DB 저장 실패');
  }
});

app.listen(3000, () => {
  console.log('✅ 서버 실행중 http://localhost:3000');
});
