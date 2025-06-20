module.exports = {
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  server: process.env.DB_SERVER,
  database: process.env.DB_NAME,
  port: parseInt(process.env.DB_PORT),
  options: {
    trustServerCertificate: true,
  },
  pool: {
    max: 30,              // 최대 연결 수 (기본 10 → 확장)
    min: 5,               // 최소 연결 수 (지속적인 연결 유지)
    idleTimeoutMillis: 30000, // 연결 미사용 상태 유지 시간 (ms)
  },
};
