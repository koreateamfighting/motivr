const sql = require('mssql');
require('dotenv').config();

const dbConfig = {
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  server: process.env.DB_SERVER,
  database: process.env.DB_NAME,
  port: parseInt(process.env.DB_PORT, 10),
  options: {
    trustServerCertificate: true,
    enableArithAbort: true,
  },
  requestTimeout: 60000,
  pool: {
    max: 10,
    min: 1,
    idleTimeoutMillis: 30000,
  },
};

const pool = new sql.ConnectionPool(dbConfig);
const poolConnect = pool.connect();

poolConnect
  .then(() => console.log('✅ DB 연결 완료'))
  .catch(err => {
    console.error('❌ DB 연결 실패:', err);
    process.exit(1);
  });

module.exports = { sql, pool, poolConnect };
