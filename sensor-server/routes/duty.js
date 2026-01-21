const express = require('express');
const router = express.Router();
const sql = require('mssql');
const dbConfig = require('../dbConfig');
const { pool, poolConnect } = require('../db'); 


// // ✅ GET: 전체 작업 목록 조회
// router.get('/duties', async (req, res) => {
//   try {
//     const pool = await poolConnect;
//     const result = await pool.request().query(`
//       SELECT Id, DutyName, StartDate, EndDate, Progress
//       FROM Duty
//       ORDER BY StartDate DESC
//     `);
//     res.json(result.recordset);
//   } catch (err) {
//     console.error('❌ Duty 목록 조회 실패:', err);
//     res.status(500).json({ error: '서버 오류' });
//   }
// });

// // ✅ POST: 작업 추가
// router.post('/duties', async (req, res) => {
//   const { DutyName, StartDate, EndDate, Progress } = req.body;

//   if (!DutyName || !StartDate || !EndDate || Progress == null) {
//     return res.status(400).json({ error: '필수 항목 누락' });
//   }

//   try {
//     const pool = await poolConnect;
//     await pool.request()
//       .input('DutyName', sql.NVarChar, DutyName)
//       .input('StartDate', sql.Date, StartDate)
//       .input('EndDate', sql.Date, EndDate)
//       .input('Progress', sql.Int, Progress)
//       .query(`
//         INSERT INTO Duty (DutyName, StartDate, EndDate, Progress)
//         VALUES (@DutyName, @StartDate, @EndDate, @Progress)
//       `);

//     res.status(200).json({ message: '작업 추가 완료' });
//   } catch (err) {
//     console.error('❌ 작업 추가 실패:', err);
//     res.status(500).json({ error: '서버 오류' });
//   }
// });

// ✅ GET: 가장 최근 Duty 1건 조회
router.get('/duties/latest', async (req, res) => {
    try {
      const pool = await poolConnect;
      const result = await pool.request().query(`
        SELECT TOP 1 Id, DutyName, StartDate, EndDate, Progress
        FROM Duty
        ORDER BY Id DESC
      `);
  
      if (result.recordset.length === 0) {
        return res.status(404).json({ error: 'Duty 항목이 없습니다.' });
      }
  
      res.json(result.recordset[0]);
    } catch (err) {
      console.error('❌ 최신 Duty 조회 실패:', err);
      res.status(500).json({ error: '서버 오류' });
    }
  });
  
  // ✅ PATCH: 최근 항목 수정
router.patch('/duties/latest', async (req, res) => {
    const { DutyName, StartDate, EndDate, Progress } = req.body;
  
    if (!DutyName || !StartDate || !EndDate || Progress == null) {
      return res.status(400).json({ error: '필수 항목 누락' });
    }
  
    try {
      const pool = await poolConnect;
  
      // 가장 최근 항목 ID 가져오기
      const latestResult = await pool.request().query(`
        SELECT TOP 1 Id FROM Duty ORDER BY Id DESC
      `);
  
      if (latestResult.recordset.length === 0) {
        return res.status(404).json({ error: '수정할 작업이 없습니다.' });
      }
  
      const latestId = latestResult.recordset[0].Id;
  
      // 수정 실행
      await pool.request()
        .input('Id', sql.Int, latestId)
        .input('DutyName', sql.NVarChar, DutyName)
        .input('StartDate', sql.Date, StartDate)
        .input('EndDate', sql.Date, EndDate)
        .input('Progress', sql.Int, Progress)
        .query(`
          UPDATE Duty
          SET DutyName = @DutyName,
              StartDate = @StartDate,
              EndDate = @EndDate,
              Progress = @Progress
          WHERE Id = @Id
        `);
  
      res.status(200).json({ message: '최근 작업 수정 완료' });
    } catch (err) {
      console.error('❌ Duty 수정 실패:', err);
      res.status(500).json({ error: '서버 오류' });
    }
  });
  

module.exports = router;
