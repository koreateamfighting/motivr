const express = require('express');
const router = express.Router();
const sql = require('mssql');
const dbConfig = require('../dbConfig');


// 최근 알람 리스트 조회
router.get('/alarms', async (req, res) => {
  try {
    await sql.connect(dbConfig);
    const result = await sql.query(`
      SELECT TOP 1000 
        CONVERT(varchar, timestamp, 120) as timestamp,
        level,
        sensor_id,
        message
      FROM alarms
      ORDER BY timestamp DESC
    `);

    res.json(result.recordset);
  } catch (err) {
    console.error('❌ 알람 조회 오류:', err);
    res.status(500).json({ error: '알람 데이터를 불러오는 중 오류가 발생했습니다.' });
  } finally {
    sql.close();
  }
});

module.exports = router;
