const express = require('express');
const sql = require('mssql');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const router = express.Router();

const dbConfig = require('../dbConfig');
const JWT_SECRET = process.env.JWT_SECRET;
const JWT_REFRESH_SECRET = process.env.JWT_REFRESH_SECRET;

function generateAccessToken(user) {
  return jwt.sign({ userID: user.UserID, id: user.Id }, JWT_SECRET, { expiresIn: '15m' });
}
function generateRefreshToken(user) {
  return jwt.sign({ userID: user.UserID, id: user.Id }, JWT_REFRESH_SECRET, { expiresIn: '7d' });
}

// 로그인
router.post('/api/login', async (req, res) => {
  const { userID, password } = req.body;

  const pool = await sql.connect(dbConfig);
  const result = await pool.request()
    .input('UserID', sql.NVarChar, userID)
    .query('SELECT * FROM Users WHERE UserID = @UserID');

  const user = result.recordset[0];
  if (!user) return res.status(401).json({ error: '존재하지 않는 사용자' });

  const match = await bcrypt.compare(password, user.PasswordHash);
  if (!match) return res.status(401).json({ error: '비밀번호 불일치' });

  const accessToken = generateAccessToken(user);
  const refreshToken = generateRefreshToken(user);

  await pool.request()
    .input('UserID', sql.NVarChar, userID)
    .input('RefreshToken', sql.NVarChar, refreshToken)
    .query('UPDATE Users SET RefreshToken = @RefreshToken, LastLoginAt = GETDATE() WHERE UserID = @UserID');

  res.json({ accessToken, refreshToken });
});

// 토큰 재발급
router.post('/refresh', async (req, res) => {
  const { refreshToken } = req.body;
  if (!refreshToken) return res.sendStatus(401);

  try {
    const payload = jwt.verify(refreshToken, JWT_REFRESH_SECRET);
    const pool = await sql.connect(dbConfig);
    const result = await pool.request()
      .input('UserID', sql.NVarChar, payload.userID)
      .query('SELECT RefreshToken FROM Users WHERE UserID = @UserID');

    if (result.recordset[0]?.RefreshToken !== refreshToken) return res.sendStatus(403);
    const newAccessToken = generateAccessToken(payload);
    res.json({ accessToken: newAccessToken });
  } catch (err) {
    res.sendStatus(403);
  }
});

// 로그아웃
router.post('/logout', async (req, res) => {
  const { userID } = req.body;
  const pool = await sql.connect(dbConfig);
  await pool.request()
    .input('UserID', sql.NVarChar, userID)
    .query('UPDATE Users SET RefreshToken = NULL WHERE UserID = @UserID');

  res.json({ message: '로그아웃 완료' });
});

module.exports = router;
