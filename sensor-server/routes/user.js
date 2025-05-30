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

// ID 중복 체크
router.get('/check-id', async (req, res) => {
  const { userID } = req.query;

  if (!userID) {
    return res.status(400).json({ error: 'userID는 필수입니다.' });
  }

  try {
    const pool = await sql.connect(dbConfig);
    const result = await pool.request()
      .input('UserID', sql.NVarChar, userID)
      .query('SELECT COUNT(*) as count FROM Users WHERE UserID = @UserID');
      console.log('아이디 파라미터 체크 : ',userID) 
    const isAvailable = result.recordset[0].count === 0;
    console.log('✅ 중복 체크 결과:', result.recordset[0]);

    res.json({ isAvailable });
  } catch (err) {
    console.error('❌ 중복 체크 오류:', err);
    res.status(500).json({ error: '서버 오류' });
  }
});


// 회원가입
router.post('/register', async (req, res) => {
  console.log('✅ 요청 도착:', req.body); // 1
  const {
    userID,
    password,
    name,
    phoneNumber,
    email,
    company,
    department,
    position,
    role
  } = req.body;

  if (!userID || !password) {
    return res.status(400).json({ error: '아이디와 비밀번호는 필수입니다.' });
  }

  try {
    const pool = await sql.connect(dbConfig);
    console.log('🔌 DB 연결 성공');

    const existingUser = await pool.request()
      .input('UserID', sql.NVarChar, userID)
      .query('SELECT * FROM Users WHERE UserID = @UserID');

    if (existingUser.recordset.length > 0) {
      console.warn('⚠️ 이미 존재하는 사용자');
      return res.status(409).json({ error: '이미 존재하는 사용자입니다.' });
    }

    console.log('🔐 비밀번호 해싱 시작');
    const hashedPassword = await bcrypt.hash(password, 10);
    console.log('✅ 해싱 완료');

    await pool.request()
      .input('UserID', sql.NVarChar, userID)
      .input('PasswordHash', sql.NVarChar, hashedPassword)
      .input('Name', sql.NVarChar, name)
      .input('PhoneNumber', sql.NVarChar, phoneNumber)
      .input('Email', sql.NVarChar, email)
      .input('Company', sql.NVarChar, company)
      .input('Department', sql.NVarChar, department)
      .input('Position', sql.NVarChar, position)
      .input('Role', sql.NVarChar, role)
      .query(`INSERT INTO Users (UserID, PasswordHash, Name, PhoneNumber, Email, Company, Department, Position, Role)
              VALUES (@UserID, @PasswordHash, @Name, @PhoneNumber, @Email, @Company, @Department, @Position, @Role)`);

    console.log('📦 회원가입 DB INSERT 성공');
    res.status(201).json({ message: '회원가입 완료' });
  } catch (err) {
    console.error('❌ 서버 오류:', err);
    res.status(500).json({ error: '서버 오류' });
  }
});

// 로그인
router.post('/login', async (req, res) => {
  const { userID, password } = req.body;

  if (!userID || !password) {
    return res.status(400).json({ error: '아이디와 비밀번호는 필수입니다.' });
  }

  try {
    const pool = await sql.connect(dbConfig);
    const result = await pool.request()
      .input('UserID', sql.NVarChar, userID)
      .query('SELECT * FROM Users WHERE UserID = @UserID');

    const user = result.recordset[0];
    if (!user) return res.status(401).json({ error: '존재하지 않는 사용자입니다.' });

    const match = await bcrypt.compare(password, user.PasswordHash);
    if (!match) return res.status(401).json({ error: '비밀번호가 일치하지 않습니다.' });

    const accessToken = generateAccessToken(user);
    const refreshToken = generateRefreshToken(user);

    await pool.request()
      .input('UserID', sql.NVarChar, userID)
      .input('RefreshToken', sql.NVarChar, refreshToken)
      .query('UPDATE Users SET RefreshToken = @RefreshToken, LastLoginAt = GETDATE() WHERE UserID = @UserID');

    res.json({ accessToken, refreshToken });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: '서버 오류' });
  }
});

// 로그아웃
router.post('/logout', async (req, res) => {
  const { userID } = req.body;

  if (!userID) {
    return res.status(400).json({ error: 'userID는 필수입니다.' });
  }

  try {
    const pool = await sql.connect(dbConfig);

    await pool.request()
      .input('UserID', sql.NVarChar, userID)
      .query('UPDATE Users SET RefreshToken = NULL WHERE UserID = @UserID');

    console.log(`🚪 로그아웃 성공: ${userID}`);
    res.status(200).json({ message: '로그아웃 완료' });
  } catch (err) {
    console.error('❌ 로그아웃 오류:', err);
    res.status(500).json({ error: '서버 오류' });
  }
});


router.get('/find-id', async (req, res) => {
  const { name } = req.query;

  if (!name) {
    return res.status(400).json({ error: '이름이 필요합니다.' });
  }

  try {
    const pool = await sql.connect(dbConfig);
    const result = await pool.request()
      .input('Name', sql.NVarChar, name)
      .query('SELECT UserID FROM Users WHERE Name = @Name');

    if (result.recordset.length === 0) {
      return res.status(404).json({ error: '사용자를 찾을 수 없습니다.' });
    }

    const userIDs = result.recordset.map(row => row.UserID);

    return res.json({ userIDs }); // 배열로 응답
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: '서버 오류' });
  }
});


module.exports = router;