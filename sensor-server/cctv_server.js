require('dotenv').config();
const express = require('express');
const fs = require('fs');
const https = require('https');
const path = require('path');
const cors = require('cors');
const { Server } = require('socket.io');
const { router: cctvRouter } = require('./routes/cctv'); // ✅ index.js에서 묶은 라우터
const { startHlsProcess, startMotionDetect } = require('./routes/cctv/video'); // ✅ 함수는 video.js에서
const { RTCPeerConnection, RTCVideoSource, RTCVideoFrame } = require('wrtc');
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
const server = https.createServer(sslOptions, app);
server.listen(4040, () => {
  console.log('🚀 CCTV 전용 서버 실행 중: https://0.0.0.0:4040');
});
