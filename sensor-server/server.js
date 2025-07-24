require('dotenv').config();
const express = require('express');
const cors = require('cors');
const fs = require('fs');
const https = require('https');
const WebSocket = require('ws');
const { spawn } = require('child_process'); // ✅ 추가
const app = express();
const path = require('path'); // ✅ 빠졌던 부분

// ✅ CORS 허용
app.use(cors());

// ✅ 요청 바디 크기 제한을 최대 20GB까지 허용
app.use(express.json({ limit: '20000mb' }));
app.use(express.urlencoded({ extended: true, limit: '20000mb' }));

// HTTPS 인증서 설정
const sslOptions = {
  cert: fs.readFileSync('C:/Users/Administrator/fullchain.pem'),
  key: fs.readFileSync('C:/Users/Administrator/privkey.pem'),
};




// 공통 설정
app.use(express.json());
app.use(cors());
app.use(express.static('public', {
  setHeaders: (res, path) => {
    res.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate');
    res.setHeader('Pragma', 'no-cache');
    res.setHeader('Expires', '0');
    res.setHeader('X-Frame-Options', 'ALLOWALL');
    res.setHeader('Content-Security-Policy', "frame-ancestors *");
  }
}));



// 라우터 분리
app.use('/api', require('./routes/user'));     // 로그인/회원
app.use('/api', require('./routes/sensor'));  
app.use('/api', require('./routes/notice'));  // 센서/기타
app.use('/api', require('./routes/worktask'));
app.use('/api', require('./routes/duty'));
app.use('/api', require('./routes/fieldinfo'));
app.use('/api', require('./routes/twin'));
app.use('/api', require('./routes/specialsensor'));
app.use('/api', require('./routes/alarmhistory'));
const settingRouter = require('./routes/settings');
app.use('/api', settingRouter);



// HTTPS 서버 생성
const server = https.createServer(sslOptions, app);

const wss = new WebSocket.Server({ server });

app.set('wss', wss); // 공유 등록

// 🟢 순수 WebSocket 서버 붙이기 (Unity 대응)


wss.on('connection', (ws, req) => {
  console.log('🟢 Unity WebSocket 연결됨');

  ws.on('message', (message) => {
    console.log('📥 Unity로부터 메시지:', message.toString());

    // 예: 응답 보내기
    ws.send(JSON.stringify({ server: '서버에서 응답했습니다!', echo: message.toString() }));
  });

  ws.on('close', () => {
    console.log('🔴 Unity WebSocket 연결 종료');
  });
});


// 서버 실행
server.listen(3030, () => {
  console.log('🚀 HTTPS + WebSocket 서버 실행 중: https://0.0.0.0:3030');
});
