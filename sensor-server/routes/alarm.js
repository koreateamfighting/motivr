const express = require('express');
const router = express.Router();
const dbConfig = require('../dbConfig');
const { sql, pool, poolConnect } = require('../db'); // ✅ 수정

// 최근 알람 리스트 조회 (limit 파라미터 사용 가능)
router.get('/alarms', async (req, res) => {
  const limit = parseInt(req.query.limit, 10) || 100;

  try {
    await poolConnect;

    const result = await pool.request()
      .input('limit', sql.Int, limit)
      .query(`
        SELECT TOP (@limit)
          id,
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
    console.log('📘 /alarms 호출 - 커넥션 풀 유지');
  }
});


// 알람 추가 (manual 이벤트 등록용)
router.post('/alarms', async (req, res) => {
  const { timestamp, level, message } = req.body;

  if (!timestamp || !level || !message) {
    return res.status(400).json({ error: '필수 항목 누락' });
  }

  try {
    await poolConnect;
    await pool.request()
  .input('timestamp', sql.VarChar, timestamp)
  .input('level', sql.NVarChar, level)
  .input('message', sql.NVarChar, message)
  .query(`
    INSERT INTO alarms (timestamp, level, message)
    VALUES (@timestamp, @level, @message)
  `);


    res.status(200).json({ message: '알람 등록 완료' });
  } catch (err) {
    console.error('❌ 알람 추가 오류:', err);
    res.status(500).json({ error: '알람 등록 중 오류 발생' });
  } finally {
    console.log('커넥션 풀 유지');
  }
});

// 알람 수정
router.put('/alarms', async (req, res) => {
  const alarms = req.body;

  if (!Array.isArray(alarms) || alarms.length === 0) {
    return res.status(400).json({ error: '수정할 알람 데이터가 없습니다.' });
  }

  try {
    await poolConnect;

    for (const alarm of alarms) {
      const { id, timestamp, level, message } = alarm;
    
      if (!id || !timestamp || !level || !message) continue;
    
      await sql.query(`
        UPDATE alarms
        SET 
          timestamp = '${timestamp}',
          level = N'${level.replace(/'/g, "''")}',
          message = N'${message.replace(/'/g, "''")}'
        WHERE id = ${id}
      `);
    }
    res.status(200).json({ message: '알람 수정 완료' });
  } catch (err) {
    console.error('❌ 알람 수정 오류:', err);
    res.status(500).json({ error: '알람 수정 중 오류 발생' });
  } finally {
    console.log('커넥션 풀 유지');
  }
});


// 알람 삭제
router.post('/alarms/delete', async (req, res) => {
  const { ids } = req.body;

  if (!Array.isArray(ids) || ids.length === 0) {
    return res.status(400).json({ error: '삭제할 ID가 없습니다.' });
  }

  try {
    await poolConnect;

    const idList = ids.join(',');

    await sql.query(`
      DELETE FROM alarms
      WHERE id IN (${idList})
    `);

    res.status(200).json({ message: '알람 삭제 완료' });
  } catch (err) {
    console.error('❌ 알람 삭제 오류:', err);
    res.status(500).json({ error: '알람 삭제 중 오류 발생' });
  } finally {
    console.log('커넥션 풀 유지');
  }
});



module.exports = router;
