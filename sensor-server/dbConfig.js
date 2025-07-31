require('dotenv').config();

const isProd = process.env.NODE_ENV === 'production';

const config = {
  server: process.env.DB_SERVER,
  database: process.env.DB_NAME,
  port: parseInt(process.env.DB_PORT || '1433'),
  options: {
    trustServerCertificate: true,
  },
  pool: {
    max: 30,
    min: 5,
    idleTimeoutMillis: 30000,
  },
};

// 👉 운영 환경이면 user/password 포함
if (isProd) {
  config.user = process.env.DB_USER;
  config.password = process.env.DB_PASS;
} else {
  // 👉 로컬 환경일 경우 Windows 인증
  config.options.trustedConnection = true;
}

module.exports = config;
