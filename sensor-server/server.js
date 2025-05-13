require('dotenv').config();
const express = require('express');
const cors = require('cors');
const fs = require('fs');
const https = require('https');
const WebSocket = require('ws');
const app = express();

// HTTPS 인증서 설정
const sslOptions = {
  cert: fs.readFileSync('C:/Users/Administrator/fullchain.pem'),
  key: fs.readFileSync('C:/Users/Administrator/privkey.pem'),
};




// 공통 설정
app.use(express.json());
app.use(cors());
app.use(express.static('public'));

// 라우터 분리
app.use('/api', require('./routes/user'));     // 로그인/회원
app.use('/api', require('./routes/service'));  // 센서/기타

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
