require('dotenv').config();
const express = require('express');
const fs = require('fs');
const http = require('http');
const https = require('https');
const path = require('path');
const cors = require('cors');
const { Server } = require('socket.io');
const { router: cctvRouter } = require('./routes/cctv'); // ✅ index.js에서 묶은 라우터
const { startHlsProcess, startMotionDetect } = require('./routes/cctv/video'); // ✅ 함수는 video.js에서
const { RTCPeerConnection, RTCVideoSource, RTCVideoFrame } = require('wrtc');
const app = express();
const isProd = process.env.NODE_ENV === 'production';

let server;

if (isProd) {
  const sslOptions = {
    cert: fs.readFileSync(process.env.SSL_CERT_PATH || 'C:/Users/Administrator/fullchain.pem'),
    key: fs.readFileSync(process.env.SSL_KEY_PATH || 'C:/Users/Administrator/privkey.pem'),
  };
  server = https.createServer(sslOptions, app);
} else {
  server = http.createServer(app);
}
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

// app.use('/hls', express.static('public/hls',{
//   setHeaders: (res, path) => {
//     if (path.endsWith('.m3u8')) {
//       res.setHeader('Content-Type', 'application/vnd.apple.mpegurl');
//     }
//     if (path.endsWith('.ts')) {
//       res.setHeader('Content-Type', 'video/mp2t');
//     }
//   }
// }));
app.use('/hls', express.static('public/hls', {
  setHeaders: (res, path) => {
    if (path.endsWith('.m3u8')) {
      res.setHeader('Content-Type', 'application/vnd.apple.mpegurl');
    }
    if (path.endsWith('.ts')) {
      res.setHeader('Content-Type', 'video/mp2t');
    }

    // ✅ 캐시 방지 공통 헤더
    res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate');
    res.setHeader('Pragma', 'no-cache');
    res.setHeader('Expires', '0');
  }
}));

console.log('✅ CCTV 라우터 import 성공');
startHlsProcess('cam1');
startMotionDetect('cam1'); // ✅ 감지도 시작

startHlsProcess('cam2');
startMotionDetect('cam2'); // ✅ cam2도 시작


// HTTPS 서버 실행 (포트 4040)
// ✅ 포트 지정
const PORT = process.env.CCTV_PORT || 4040;

server.listen(PORT, () => {
  const protocol = isProd ? 'https' : 'http';
  console.log(`🚀 CCTV 서버 실행 중: ${protocol}://0.0.0.0:${PORT}`);
});