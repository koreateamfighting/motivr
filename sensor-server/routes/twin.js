const express = require('express');
const router = express.Router();
const fs = require('fs');
const path = require('path');

// Twin 객체 상태 저장 및 브로드캐스트
router.post('/save_twin', (req, res) => {
  const { datetime, objects } = req.body;

  if (!datetime || !Array.isArray(objects)) {
    return res.status(400).json({ error: 'datetime과 objects 배열이 필요합니다.' });
  }

  console.log('🌀 [TwinObjects] 전체 JSON 수신:');
  console.log(JSON.stringify(req.body, null, 2));

  // ✅ 로그 저장
  try {
    const now = new Date();
    const filename = `twin_log_${now.toISOString().slice(0, 19).replace(/[:T]/g, '-')}.txt`;
    const logDir = path.join(__dirname, '..', 'logs');

    if (!fs.existsSync(logDir)) {
      fs.mkdirSync(logDir, { recursive: true }); // ⬅ 안전하게 생성
    }

    const filePath = path.join(logDir, filename);
    fs.writeFileSync(filePath, JSON.stringify(req.body, null, 2), 'utf-8');

    console.log(`📄 Twin 로그 저장됨: ${filePath}`);
  } catch (err) {
    console.error('❌ 로그 파일 저장 실패:', err);
  }

  // ✅ WebSocket 브로드캐스트
  const wss = req.app.get('wss');
  if (wss && wss.clients) {
    const payload = {
      type: 'twinObjectBatch',
      source: 'webgl',
      data: req.body,
    };

    wss.clients.forEach(client => {
      if (client.readyState === 1) {
        client.send(JSON.stringify(payload));
      }
    });
  }

  res.status(200).json({ message: 'Twin 객체 데이터 수신 완료', count: objects.length });
});

// 🔵 WebGL이 요청 시 최신 twin 로그 파일 전달

router.get('/load_twin', (req, res) => {
  const logDir = path.join(__dirname, '..', 'logs');

  try {
    if (!fs.existsSync(logDir)) {
      return res.status(404).json({ error: 'logs 폴더가 존재하지 않습니다.' });
    }

    const files = fs.readdirSync(logDir)
      .filter(f => f.startsWith('twin_log_') && f.endsWith('.txt'))
      .sort((a, b) => {
        const timeA = fs.statSync(path.join(logDir, a)).mtime;
        const timeB = fs.statSync(path.join(logDir, b)).mtime;
        return timeB - timeA; // 최신 파일이 앞으로 오도록
      });

    if (files.length === 0) {
      return res.status(404).json({ error: '로그 파일이 존재하지 않습니다.' });
    }

    const latestFilePath = path.join(logDir, files[0]);
    const contents = fs.readFileSync(latestFilePath, 'utf-8');

    let jsonData;
    try {
      jsonData = JSON.parse(contents);
    } catch (err) {
      return res.status(400).json({ error: '로그 파일 내용이 유효한 JSON이 아닙니다.' });
    }

    // ✅ Unity가 요구하는 구조: 최상위 JSON에 datetime, objects
    if (!jsonData.datetime || !Array.isArray(jsonData.objects)) {
      return res.status(400).json({ error: '올바른 TwinSnapshot 구조가 아닙니다.' });
    }

    console.log(`📤 최신 twin 로그 파일 응답: ${latestFilePath}`);
    res.status(200).json(jsonData);  // ⬅ 핵심 변경: wrapping 없이 바로 응답

  } catch (err) {
    console.error('❌ 최신 twin 로그 읽기 실패:', err);
    res.status(500).json({ error: '서버 오류 발생' });
  }
});


// 📤 POST: CSV 저장
router.post('/save_info1', (req, res) => {
  const { csv } = req.body;

  if (!csv) {
    return res.status(400).json({ error: 'CSV 데이터가 필요합니다.' });
  }

  try {
    const now = new Date();
    const timestamp = now.toISOString().slice(0, 19).replace(/[:T]/g, '-');
    const filename = `info_${timestamp}.csv`;
    const logDir = path.join(__dirname, '..', 'logs2');

    if (!fs.existsSync(logDir)) {
      fs.mkdirSync(logDir, { recursive: true });
    }

    const filePath = path.join(logDir, filename);
    fs.writeFileSync(filePath, csv, 'utf-8');

    console.log(`✅ CSV 저장 완료: ${filePath}`);
    res.status(200).json({ message: 'CSV 저장 성공', filename });
  } catch (err) {
    console.error('❌ CSV 저장 실패:', err);
    res.status(500).json({ error: 'CSV 저장 실패' });
  }
});

// 📥 GET: 최신 CSV 다운로드
router.get('/load_info1', (req, res) => {
  const logDir = path.join(__dirname, '..', 'logs2');

  try {
    const files = fs.readdirSync(logDir)
      .filter(f => f.endsWith('.csv'))
      .sort((a, b) => {
        const timeA = fs.statSync(path.join(logDir, a)).mtime;
        const timeB = fs.statSync(path.join(logDir, b)).mtime;
        return timeB - timeA;
      });

    if (files.length === 0) {
      return res.status(404).json({ error: 'CSV 파일이 없습니다.' });
    }

    const latestFile = files[0];
    const filePath = path.join(logDir, latestFile);

    res.setHeader('Content-Disposition', `attachment; filename=${latestFile}`);
    res.setHeader('Content-Type', 'text/csv');
    res.sendFile(filePath);
  } catch (err) {
    console.error('❌ CSV 로드 실패:', err);
    res.status(500).json({ error: 'CSV 다운로드 실패' });
  }
});
// 📤 POST: CSV 저장
router.post('/save_info2', (req, res) => {
  const { csv } = req.body;

  if (!csv) {
    return res.status(400).json({ error: 'CSV 데이터가 필요합니다.' });
  }

  try {
    const now = new Date();
    const timestamp = now.toISOString().slice(0, 19).replace(/[:T]/g, '-');
    const filename = `info_${timestamp}.csv`;
    const logDir = path.join(__dirname, '..', 'logs3');

    if (!fs.existsSync(logDir)) {
      fs.mkdirSync(logDir, { recursive: true });
    }

    const filePath = path.join(logDir, filename);
    fs.writeFileSync(filePath, csv, 'utf-8');

    console.log(`✅ CSV 저장 완료: ${filePath}`);
    res.status(200).json({ message: 'CSV 저장 성공', filename });
  } catch (err) {
    console.error('❌ CSV 저장 실패:', err);
    res.status(500).json({ error: 'CSV 저장 실패' });
  }
});

// 📥 GET: 최신 CSV 다운로드
router.get('/load_info2', (req, res) => {
  const logDir = path.join(__dirname, '..', 'logs3');

  try {
    const files = fs.readdirSync(logDir)
      .filter(f => f.endsWith('.csv'))
      .sort((a, b) => {
        const timeA = fs.statSync(path.join(logDir, a)).mtime;
        const timeB = fs.statSync(path.join(logDir, b)).mtime;
        return timeB - timeA;
      });

    if (files.length === 0) {
      return res.status(404).json({ error: 'CSV 파일이 없습니다.' });
    }

    const latestFile = files[0];
    const filePath = path.join(logDir, latestFile);

    res.setHeader('Content-Disposition', `attachment; filename=${latestFile}`);
    res.setHeader('Content-Type', 'text/csv');
    res.sendFile(filePath);
  } catch (err) {
    console.error('❌ CSV 로드 실패:', err);
    res.status(500).json({ error: 'CSV 다운로드 실패' });
  }
});
// 📤 POST: CSV 저장
router.post('/save_info3', (req, res) => {
  const { csv } = req.body;

  if (!csv) {
    return res.status(400).json({ error: 'CSV 데이터가 필요합니다.' });
  }

  try {
    const now = new Date();
    const timestamp = now.toISOString().slice(0, 19).replace(/[:T]/g, '-');
    const filename = `info_${timestamp}.csv`;
    const logDir = path.join(__dirname, '..', 'logs4');

    if (!fs.existsSync(logDir)) {
      fs.mkdirSync(logDir, { recursive: true });
    }

    const filePath = path.join(logDir, filename);
    fs.writeFileSync(filePath, csv, 'utf-8');

    console.log(`✅ CSV 저장 완료: ${filePath}`);
    res.status(200).json({ message: 'CSV 저장 성공', filename });
  } catch (err) {
    console.error('❌ CSV 저장 실패:', err);
    res.status(500).json({ error: 'CSV 저장 실패' });
  }
});

// 📥 GET: 최신 CSV 다운로드
router.get('/load_info3', (req, res) => {
  const logDir = path.join(__dirname, '..', 'logs4');

  try {
    const files = fs.readdirSync(logDir)
      .filter(f => f.endsWith('.csv'))
      .sort((a, b) => {
        const timeA = fs.statSync(path.join(logDir, a)).mtime;
        const timeB = fs.statSync(path.join(logDir, b)).mtime;
        return timeB - timeA;
      });

    if (files.length === 0) {
      return res.status(404).json({ error: 'CSV 파일이 없습니다.' });
    }

    const latestFile = files[0];
    const filePath = path.join(logDir, latestFile);

    res.setHeader('Content-Disposition', `attachment; filename=${latestFile}`);
    res.setHeader('Content-Type', 'text/csv');
    res.sendFile(filePath);
  } catch (err) {
    console.error('❌ CSV 로드 실패:', err);
    res.status(500).json({ error: 'CSV 다운로드 실패' });
  }
});

module.exports = router;
