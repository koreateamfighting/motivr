const express = require('express');
const router = express.Router();
const sql = require('mssql');
const dbConfig = require('../dbConfig');

// 작업 리스트 조회 API
router.get('/work-tasks', async (req, res) => {
  try {
    await sql.connect(dbConfig);
    const result = await sql.query(`
      SELECT 
        id,
        title,
        progress,
        CONVERT(varchar, start_date, 120) AS start_date,
        CONVERT(varchar, end_date, 120) AS end_date,
        CONVERT(varchar, created_at, 120) AS created_at
      FROM work_task
      ORDER BY created_at DESC
    `);
    res.json(result.recordset);
  } catch (err) {
    console.error('❌ 작업 리스트 조회 오류:', err);
    res.status(500).json({ error: '작업 데이터를 불러오는 중 오류가 발생했습니다.' });
  } finally {
    sql.close();
  }
});

module.exports = router;
