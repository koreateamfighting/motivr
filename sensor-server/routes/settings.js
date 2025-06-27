const express = require('express');
const router = express.Router();
const sql = require('mssql');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const dbConfig = require('../dbConfig');

// 저장 경로 설정
const uploadDir = path.join(__dirname, '../public/uploads');
if (!fs.existsSync(uploadDir)) fs.mkdirSync(uploadDir, { recursive: true });

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadDir),
  filename: (req, file, cb) => cb(null, 'logo_' + Date.now() + path.extname(file.originalname)),
});

const upload = multer({ storage });

// 설정 저장 라우트
router.post('/update-settings', upload.single('logo'), async (req, res) => {
  const { title } = req.body;
  let logoPath = req.file ? `/uploads/${req.file.filename}` : null;

  try {
    const pool = await sql.connect(dbConfig);

    // 기존 설정 가져오기
    const latest = await pool.request().query(`
      SELECT TOP 1 LogoUrl FROM SiteSettings ORDER BY UpdatedAt DESC
    `);

    if (!logoPath && latest.recordset.length > 0) {
      logoPath = latest.recordset[0].LogoUrl; // 기존 로고 유지
    }

    await pool.request()
      .input('Title', sql.NVarChar, title)
      .input('LogoUrl', sql.NVarChar, logoPath)
      .query(`
        INSERT INTO SiteSettings (Title, LogoUrl)
        VALUES (@Title, @LogoUrl)
      `);

    res.status(200).json({ message: '설정 저장 완료', logoUrl: logoPath });
  } catch (err) {
    console.error('❌ 설정 저장 실패:', err);
    res.status(500).json({ error: '서버 오류' });
  }
});


router.get('/get-settings', async (req, res) => {
    try {
      const pool = await sql.connect(dbConfig);
      const result = await pool.request().query(`
        SELECT TOP 1 Title, LogoUrl
        FROM SiteSettings
        ORDER BY UpdatedAt DESC
      `);
  
      if (result.recordset.length === 0) {
        return res.status(404).json({ error: '설정이 존재하지 않습니다.' });
      }
  
      res.json(result.recordset[0]); // { Title: ..., LogoUrl: ... }
    } catch (err) {
      console.error('❌ 설정 조회 실패:', err);
      res.status(500).json({ error: '서버 오류' });
    }
  });

  

module.exports = router;
