const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const cors = require('cors');

const app = express();
const PORT = 3000; // 원하는 포트 사용

app.use(cors());

// CCTV 프록시
app.use('/cctv', createProxyMiddleware({
  target: 'http://cctvsec.ktict.co.kr:8081', // CCTV 서버
  changeOrigin: true,
  pathRewrite: {
    '^/cctv': '', // /cctv 접두어 제거
  },
  secure: false, // http 강제 허용
}));

app.listen(PORT, () => {
  console.log(`Proxy server running at http://localhost:${PORT}`);
});
