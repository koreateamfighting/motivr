const express = require('express');
const router = express.Router();
const sql = require('mssql');
const { pool, poolConnect } = require('../db'); 
const dbConfig = require('../dbConfig');

// 공지사항 조회
router.get('/notices', async (req, res) => {
  try {
    await poolConnect;
    const result = await pool.request().query(`
      SELECT TOP 500
  id, content, CONVERT(varchar, created_at, 120) as created_at
FROM notice
ORDER BY created_at DESC

    `);
    res.json(result.recordset);
  } catch (err) {
    console.error('❌ 공지사항 조회 오류:', err);
    res.status(500).json({ error: '공지사항을 불러오는 중 오류가 발생했습니다.' });
  } finally {
    console.log('커넥션 풀 유지');
  }
});

router.patch('/notices/:id', async (req, res) => {
  const { id } = req.params;
  const { content } = req.body;

  if (!id || !content) {
    return res.status(400).json({ error: '필수 값이 누락되었습니다.' });
  }

  try {
    await poolConnect;
    

    const safeContent = content.replace(/'/g, "''");

    await pool.request().query(`
      UPDATE notice
      SET content = N'${safeContent}'
      WHERE id = ${id}
    `);

    res.json({ message: '✅ 공지사항이 성공적으로 수정되었습니다.' });
  } catch (err) {
    console.error('❌ 공지사항 수정 실패:', err);
    res.status(500).json({ error: '서버 오류로 공지사항 수정에 실패했습니다.' });
  } finally {
    console.log('커넥션 풀 유지');
  }
});


// 공지사항 추가
router.post('/notices', async (req, res) => {
  const { content, createdAt } = req.body;

  if (!content || !createdAt) {
    return res.status(400).json({ error: '공지 내용 또는 시간 누락' });
  }

  try {
    await poolConnect;
    const safeContent = content.replace(/'/g, "''");
    const safeCreatedAt = createdAt.replace(/'/g, "''"); // 보안 처리

    await pool.request().query(`
      INSERT INTO notice (content, created_at)
      VALUES (N'${safeContent}', '${safeCreatedAt}')
    `);

    res.status(200).json({ message: '✅ 공지사항이 성공적으로 등록되었습니다.' });
  } catch (err) {
    console.error('❌ 공지사항 등록 오류:', err);
    res.status(500).json({ error: '공지사항 등록 중 오류가 발생했습니다.' });
  } finally {
    console.log('커넥션 풀 유지');
  }
});



// ✅ 공지사항 일괄 수정
router.post('/bulk-update-notices', async (req, res) => {
  const updates = req.body; // [{ id: 1, content: "..." }, {...}]

  if (!Array.isArray(updates)) {
    return res.status(400).json({ error: '유효하지 않은 데이터 형식입니다.' });
  }

  try {
    await poolConnect;

    for (const update of updates) {
      const { id, content } = update;
      if (typeof id !== 'number' || typeof content !== 'string') continue;

      const safeContent = content.replace(/'/g, "''");
      
      await pool.request().query(`
        UPDATE notice
        SET content = N'${safeContent}'
        WHERE id = ${id}
      `);
    }

    res.json({ message: `✅ ${updates.length}개의 공지사항이 수정되었습니다.` });
  } catch (err) {
    console.error('❌ 공지사항 일괄 수정 실패:', err);
    res.status(500).json({ error: '공지사항 일괄 수정 중 서버 오류가 발생했습니다.' });
  } finally {
    console.log('커넥션 풀 유지');
  }
});


router.post('/delete-notices', async (req, res) => {
  const ids = req.body.ids;

  if (!Array.isArray(ids)) {
    return res.status(400).json({ error: '유효하지 않은 요청 형식입니다.' });
  }

  try {
    await poolConnect;
    

    for (const id of ids) {
      if (typeof id !== 'number') continue;
      await pool.request()
        .input('id', sql.Int, id)
        .query('DELETE FROM notice WHERE id = @id');
    }

    res.status(200).json({ message: `✅ ${ids.length}개의 공지사항이 삭제되었습니다.` });
  } catch (err) {
    console.error('❌ 공지사항 삭제 실패:', err);
    res.status(500).json({ error: '공지사항 삭제 중 서버 오류가 발생했습니다.' });
  } finally {
    console.log('커넥션 풀 유지');
  }
});


module.exports = router;
