const express = require('express');
const router = express.Router();
const sql = require('mssql');
const { pool, poolConnect } = require('../db'); 
const dbConfig = require('../dbConfig');
const multer = require('multer');
const csv = require('csv-parser');
const fs = require('fs');

// multer 설정 (임시 저장 디렉토리)
const upload = multer({ dest: 'uploads/' });

/**
 * ✅ 작업 리스트 조회 API
 */
router.get('/work-tasks', async (req, res) => {
  try {
    await poolConnect;
    const result = await pool.request().query(`
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
    console.log('커넥션 풀 유지');
  }
});

/**
 * ✅ 작업 CSV 업로드 API
 * @route POST /api/upload-csv
 */
router.post('/upload-csv', upload.single('file'), async (req, res) => {
  const filePath = req.file.path;
  const tasks = [];

  const stream = fs.createReadStream(filePath, { encoding: 'utf8' });

  stream
    .pipe(csv({
      mapHeaders: ({ header }) => header.trim().replace(/^\uFEFF/, '')
    }))
    .on('headers', (headers) => {
      const requiredHeaders = ['title', 'progress', 'start_date', 'end_date'];
      const isValid = requiredHeaders.every((h) => headers.includes(h));
      if (!isValid) {
        res.status(400).json({ error: 'CSV 형식이 잘못되었습니다. 필수 컬럼이 없습니다.' });
        fs.unlinkSync(filePath);
        stream.destroy();
      }
    })
    .on('data', (row) => {
      tasks.push(row);
    })
    .on('end', async () => {
      try {
        await poolConnect;
       

        // ✅ DB에서 start_date를 DATE 형식(yyyy-MM-dd)으로 가져옴
        const existing = await pool.request().query(`
          SELECT title, CONVERT(varchar(10), start_date, 120) as start_date
          FROM work_task
        `);
        const existingSet = new Set(
          existing.recordset.map(row => `${row.title.trim()}|${row.start_date}`)
        );

        let insertCount = 0;
        let duplicateCount = 0;

        for (const task of tasks) {
          const title = task.title?.trim() || '';
          let progress = parseInt(task.progress);
          if (isNaN(progress) || progress < 0 || progress > 100) {
            progress = 0;
          }

          const startDate = task.start_date?.trim();
          const endDate = task.end_date?.trim();

          const taskKey = `${title}|${startDate}`;

          // ✅ 중복 검사
          if (existingSet.has(taskKey)) {
            duplicateCount++;
            continue;
          }

          await request.query(`
            INSERT INTO work_task (title, progress, start_date, end_date)
            VALUES (
              N'${title.replace(/'/g, "''")}',
              ${progress},
              ${startDate ? `'${startDate}'` : 'NULL'},
              ${endDate ? `'${endDate}'` : 'NULL'}
            )
          `);

          insertCount++;
        }

        res.json({
          message: `CSV 업로드 완료. 중복 건수 ${duplicateCount}개를 제외하고 ${insertCount}개가 반영되었습니다.`,
          inserted: insertCount,
          duplicated: duplicateCount
        });
      } catch (err) {
        console.error('❌ CSV 저장 오류:', err);
        res.status(500).json({ error: 'CSV 저장 중 오류가 발생했습니다.' });
      } finally {
        fs.unlinkSync(filePath);
        console.log('커넥션 풀 유지');
      }
    });
});

// PATCH /api/work-tasks/:id
router.patch('/work-tasks/:id', async (req, res) => {
  const { id } = req.params;
  const { title, progress, start_date, end_date } = req.body;

  if (!id || !title || progress === undefined) {
    return res.status(400).json({ error: '필수 값이 누락되었습니다.' });
  }

  try {
    await poolConnect;
    const request = new pool.request().Request();

    const safeTitle = title.replace(/'/g, "''");
    const safeProgress = parseInt(progress);
    const safeStart = start_date ? `'${start_date}'` : 'NULL';
    const safeEnd = end_date ? `'${end_date}'` : 'NULL';

    const query = `
      UPDATE work_task
      SET title = N'${safeTitle}',
          progress = ${safeProgress},
          start_date = ${safeStart},
          end_date = ${safeEnd}
      WHERE id = ${id}
    `;

    await request.query(query);
    res.json({ message: '✅ 작업이 성공적으로 수정되었습니다.' });

  } catch (err) {
    console.error('❌ 작업 수정 실패:', err);
    res.status(500).json({ error: '서버 오류로 작업 수정에 실패했습니다.' });
  } finally {
    console.log('커넥션 풀 유지');
  }
});
router.post('/bulk-update', async (req, res) => {
  const tasks = req.body;

  if (!Array.isArray(tasks)) {
    return res.status(400).json({ error: '유효하지 않은 요청 형식입니다.' });
  }

  try {
    const pool = await poolConnect;

    for (const task of tasks) {
      const { id, title, progress, start_date, end_date } = task;

      if (!id || !title || progress === undefined) continue;

      await pool.request().request()
        .input('id', sql.Int, id)
        .input('title', sql.NVarChar(100), title)
        .input('progress', sql.Int, progress)
        .input('start_date', sql.DateTime, start_date || null)
        .input('end_date', sql.DateTime, end_date || null)
        .query(`
          UPDATE work_task
          SET title = @title,
              progress = @progress,
              start_date = @start_date,
              end_date = @end_date
          WHERE id = @id
        `);
    }

    res.status(200).json({ message: '✅ 작업 일괄 수정이 완료되었습니다.' });
  } catch (err) {
    console.error('❌ 작업 일괄 수정 실패:', err);
    res.status(500).json({ error: '서버 오류로 작업 일괄 수정에 실패했습니다.' });
  } finally {
    console.log('커넥션 풀 유지');
  }
});

/**
 * ✅ 작업 삭제 API
 * @route POST /api/delete-tasks
 */
router.post('/delete-tasks', async (req, res) => {
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
        .query('DELETE FROM work_task WHERE id = @id');
    }

    res.status(200).json({ message: `✅ ${ids.length}개의 작업이 삭제되었습니다.` });
  } catch (err) {
    console.error('❌ 작업 삭제 실패:', err);
    res.status(500).json({ error: '작업 삭제 중 서버 오류가 발생했습니다.' });
  } finally {
    console.log('커넥션 풀 유지');
  }
});


module.exports = router;