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

// 알람 추가 (manual 이벤트 등록용)
router.post('/alarms', async (req, res) => {
  const { timestamp, level, message } = req.body;

  if (!timestamp || !level || !message) {
    return res.status(400).json({ error: '필수 항목 누락' });
  }

  try {
    await sql.connect(dbConfig);
    await sql.query(`
      INSERT INTO alarms (timestamp, level, message)
      VALUES (
        '${timestamp}',
        N'${level.replace(/'/g, "''")}',    
        N'${message.replace(/'/g, "''")}'
      )
    `);

    res.status(200).json({ message: '알람 등록 완료' });
  } catch (err) {
    console.error('❌ 알람 추가 오류:', err);
    res.status(500).json({ error: '알람 등록 중 오류 발생' });
  } finally {
    sql.close();
  }
});

module.exports = router;
