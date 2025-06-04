require('dotenv').config();
const express = require('express');
const fs = require('fs');
const https = require('https');
const path = require('path');
const cors = require('cors');
const { router: cctvRouter, startHlsProcess } = require('./routes/cctv');

const app = express();

// HTTPS 인증서
const sslOptions = {
  cert: fs.readFileSync('C:/Users/Administrator/fullchain.pem'),
  key: fs.readFileSync('C:/Users/Administrator/privkey.pem'),
};

// 공통 미들웨어
app.use(express.json());
app.use(cors());
app.use(express.static('public', {
  setHeaders: (res) => {
    res.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate');
    res.setHeader('Pragma', 'no-cache');
    res.setHeader('Expires', '0');
    res.setHeader('X-Frame-Options', 'ALLOWALL');
    res.setHeader('Content-Security-Policy', "frame-ancestors *");
  }
}));

// CCTV 전용 라우터

app.use('/api', cctvRouter);

app.use('/hls', express.static('public/hls'));
console.log('✅ CCTV 라우터 import 성공');
startHlsProcess('cam1'); // ✅ 자동 실행
startHlsProcess('cam2'); // ✅ 자동 실행


// HTTPS 서버 실행 (포트 4040)
const server = https.createServer(sslOptions, app);
server.listen(4040, () => {
  console.log('🚀 CCTV 전용 서버 실행 중: https://0.0.0.0:4040');
});
