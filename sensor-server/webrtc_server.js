const express = require('express');
const http = require('http');
const expressWs = require('express-ws');
const { proxy } = require('rtsp-relay')(express);

const app = express();
const server = http.createServer(app);
expressWs(app, server);

// ✅ WebRTC transport 명시
const handler = proxy({
  url: 'rtsp://admin:admin1234!@218.149.187.159:40551/unicast/c2/s0/live',
  transport: 'webrtc', // ← 이게 핵심!
  verbose: true,
});

app.ws('/api/stream', handler);
app.use(express.static('public'));

server.listen(8888, () => {
  console.log('🚀 WebRTC CCTV 서버 실행됨: http://localhost:8888');
});
