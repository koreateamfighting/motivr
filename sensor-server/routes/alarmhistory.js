const express = require('express');
const router = express.Router();
const sql = require('mssql');
const dbConfig = require('../dbConfig');
const { DateTime } = require('luxon');

// 🔎 알람 히스토리 조회 (최신 100개)
router.get('/alarmhistory', async (req, res) => {
  try {
    const pool = await sql.connect(dbConfig);
    const result = await pool.request().query(`
      SELECT TOP 100 *
      FROM AlarmHistory
      ORDER BY Timestamp DESC
    `);
    res.status(200).json({ message: '알람 히스토리 조회 성공', data: result.recordset });
  } catch (err) {
    console.error('❌ 알람 히스토리 조회 실패:', err);
    res.status(500).json({ error: 'DB 조회 실패' });
  }
});


// ✅ 알람 히스토리 추가 또는 업데이트
router.post('/alarmhistory', async (req, res) => {
  const {
    DeviceID,
    Timestamp,
    Event,
    Log,
    Location,
    Latitude,
    Longitude,
    Type
  } = req.body;

  // 타임스탬프 가공
  const formattedTime = Timestamp
    ? DateTime.fromISO(Timestamp, { zone: 'Asia/Seoul' }).toFormat('yyyy-LL-dd HH:mm:ss')
    : DateTime.now().setZone('Asia/Seoul').toFormat('yyyy-LL-dd HH:mm:ss');

  try {
    const pool = await sql.connect(dbConfig);

    // 기존 DeviceID 존재 여부 확인
    const check = await pool.request()
      .input('DeviceID', sql.NVarChar, DeviceID)
      .query(`SELECT Id FROM AlarmHistory WHERE DeviceID = @DeviceID`);

    if (check.recordset.length > 0) {
      // 🟠 UPDATE
      await pool.request()
        .input('DeviceID', sql.NVarChar, DeviceID)
        .input('Timestamp', sql.VarChar, formattedTime)
        .input('Event', sql.NVarChar, Event)
        .input('Log', sql.NVarChar, Log)
        .input('Location', sql.NVarChar, Location)
        .input('Latitude', sql.Float, Latitude)
        .input('Longitude', sql.Float, Longitude)
        .input('Type', sql.NVarChar, Type)
        .query(`
          UPDATE AlarmHistory
          SET Timestamp = @Timestamp,
              Event = @Event,
              Log = @Log,
              Location = @Location,
              Latitude = @Latitude,
              Longitude = @Longitude,
              Type = @Type
          WHERE DeviceID = @DeviceID
        `);

      res.status(200).json({ message: '기존 알람 업데이트 완료' });
    } else {
      // 🟢 INSERT
      await pool.request()
        .input('DeviceID', sql.NVarChar, DeviceID)
        .input('Timestamp', sql.VarChar, formattedTime)
        .input('Event', sql.NVarChar, Event)
        .input('Log', sql.NVarChar, Log)
        .input('Location', sql.NVarChar, Location)
        .input('Latitude', sql.Float, Latitude)
        .input('Longitude', sql.Float, Longitude)
        .input('Type', sql.NVarChar, Type)
        .query(`
          INSERT INTO AlarmHistory (DeviceID, Timestamp, Event, Log, Location, Latitude, Longitude, Type)
          VALUES (@DeviceID, @Timestamp, @Event, @Log, @Location, @Latitude, @Longitude, @Type)
        `);

      res.status(200).json({ message: '새 알람 추가 완료' });
    }
  } catch (err) {
    console.error('❌ 알람 히스토리 저장 실패:', err);
    res.status(500).json({ error: 'DB 저장 실패' });
  }
});

module.exports = router;
