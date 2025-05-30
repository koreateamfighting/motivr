const express = require('express');
const router = express.Router();
const sql = require('mssql');
const dbConfig = require('../dbConfig');

// 공지사항 조회
router.get('/notices', async (req, res) => {
  try {
    await sql.connect(dbConfig);
    const result = await sql.query(`
      SELECT 
        id,     
        content,
        CONVERT(varchar, created_at, 120) as created_at
      FROM notice
      ORDER BY created_at DESC
    `);
    res.json(result.recordset);
  } catch (err) {
    console.error('❌ 공지사항 조회 오류:', err);
    res.status(500).json({ error: '공지사항을 불러오는 중 오류가 발생했습니다.' });
  } finally {
    sql.close(); // ✅ 연결 닫기
  }
});

module.exports = router;
