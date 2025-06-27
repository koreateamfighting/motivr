const express = require('express');
const sql = require('mssql');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const router = express.Router();
const dbConfig = require('../dbConfig');



const JWT_SECRET = process.env.JWT_SECRET;
const JWT_REFRESH_SECRET = process.env.JWT_REFRESH_SECRET;

function generateAccessToken(user) {
  return jwt.sign(
    { userID: user.UserID, id: user.Id, role: user.Role }, // ✅ role 포함
    JWT_SECRET,
    { expiresIn: '15m' }
  );
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
    role, // 유지!
    responsibilities
  } = req.body;
  
  const userRole = role || 'disabled'; // 클라이언트가 안 보내면 'disabled'로 처리

  if (!userID || !password ||!email) {
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
    .input('Role', sql.NVarChar, userRole) // 👈 이 부분에서 기본값 반영
    .input('Responsibilities', sql.NVarChar, responsibilities)
    .query(`
      INSERT INTO Users 
      (UserID, PasswordHash, Name, PhoneNumber, Email, Company, Department, Position, Role, Responsibilities)
      VALUES 
      (@UserID, @PasswordHash, @Name, @PhoneNumber, @Email, @Company, @Department, @Position, @Role, @Responsibilities)
    `);
  

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

  if (!userID || !password ) {
    return res.status(400).json({ error: '아이디, 비밀번호, 이메일은 필수입니다.' });
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

      res.json({
        accessToken,
        refreshToken,
        role: user.Role,  // 💡 선택사항
        name: user.Name   // 💡 선택사항
      });
      
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

// 임시 비밀번호 발급
router.post('/recover-password', async (req, res) => {
  const { userID, email } = req.body;

  if (!userID || !email) {
    return res.status(400).json({ error: '아이디와 이메일은 필수입니다.' });
  }

  try {
    const pool = await sql.connect(dbConfig);
    const result = await pool.request()
      .input('UserID', sql.NVarChar, userID)
      .query('SELECT * FROM Users WHERE UserID = @UserID');

    const user = result.recordset[0];

    if (!user) {
      return res.status(404).json({ error: '존재하지 않는 사용자입니다.' });
    }

    if (user.Email !== email) {
      return res.status(403).json({ error: '계정의 이메일과 일치하지 않습니다.' });
    }

    // 1. 임시 비밀번호 생성
    const tempPassword = generateRandomPassword();
    const hashed = await bcrypt.hash(tempPassword, 10);

    // 2. DB 업데이트
    await pool.request()
      .input('UserID', sql.NVarChar, userID)
      .input('PasswordHash', sql.NVarChar, hashed)
      .query('UPDATE Users SET PasswordHash = @PasswordHash WHERE UserID = @UserID');

    // 3. 프론트에 임시 비밀번호 반환
    return res.status(200).json({ tempPassword });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: '서버 오류' });
  }
});

// 임시 비밀번호 생성 함수
function generateRandomPassword() {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  return Array.from({ length: 10 }, () => chars[Math.floor(Math.random() * chars.length)]).join('');
}

//비밀번호 변경
router.post('/change-password', async (req, res) => {
  const { userID, currentPassword, newPassword } = req.body;

  if (!userID || !currentPassword || !newPassword) {
    return res.status(400).json({ error: '모든 필드를 입력해주세요.' });
  }

  try {
    const pool = await sql.connect(dbConfig);
    const result = await pool.request()
      .input('UserID', sql.NVarChar, userID)
      .query('SELECT * FROM Users WHERE UserID = @UserID');

    const user = result.recordset[0];
    if (!user) return res.status(404).json({ error: '사용자를 찾을 수 없습니다.' });

    const match = await bcrypt.compare(currentPassword, user.PasswordHash);
    if (!match) return res.status(401).json({ error: '현재 비밀번호가 일치하지 않습니다.' });

    const hashed = await bcrypt.hash(newPassword, 10);

    await pool.request()
      .input('UserID', sql.NVarChar, userID)
      .input('PasswordHash', sql.NVarChar, hashed)
      .query('UPDATE Users SET PasswordHash = @PasswordHash WHERE UserID = @UserID');

    return res.status(200).json({ message: '비밀번호 변경 성공' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: '서버 오류' });
  }
});

// 사용자 목록 조회 (조건부 role 필터링)
router.get('/users/by-role', async (req, res) => {
  const { includeRoles = '', excludeRoles = '' } = req.query;

  try {
    const pool = await sql.connect(dbConfig);

    const includeList = includeRoles.split(',').filter(r => r.trim());
    const excludeList = excludeRoles.split(',').filter(r => r.trim());

    let query = 'SELECT UserID, Role FROM Users WHERE 1=1 AND Role != \'admin\'';

    if (includeList.length > 0) {
      const inParams = includeList.map((_, i) => `@include${i}`).join(',');
      query += ` AND Role IN (${inParams})`;
    }
    if (excludeList.length > 0) {
      const exParams = excludeList.map((_, i) => `@exclude${i}`).join(',');
      query += ` AND Role NOT IN (${exParams})`;
    }

    const request = pool.request();
    includeList.forEach((role, i) => request.input(`include${i}`, sql.NVarChar, role));
    excludeList.forEach((role, i) => request.input(`exclude${i}`, sql.NVarChar, role));

    const result = await request.query(query);
    res.json(result.recordset);
  } catch (err) {
    console.error('❌ 사용자 조회 오류:', err);
    res.status(500).json({ error: '서버 오류' });
  }
}); // ✅ 올바르게 닫음

// ✅ 사용자 권한 변경 API
router.post('/users/update-role', async (req, res) => {
  const { userIDs, newRole } = req.body;

  if (!Array.isArray(userIDs) || !newRole) {
    return res.status(400).json({ error: 'userIDs 배열과 newRole은 필수입니다.' });
  }

  try {
    const pool = await sql.connect(dbConfig);
    const transaction = new sql.Transaction(pool);
    await transaction.begin();

    for (const userID of userIDs) {
      await transaction.request()
        .input('UserID', sql.NVarChar, userID)
        .input('NewRole', sql.NVarChar, newRole)
        .query('UPDATE Users SET Role = @NewRole WHERE UserID = @UserID');
    }

    await transaction.commit();
    res.status(200).json({ message: '역할 업데이트 완료' });
  } catch (err) {
    console.error('❌ 역할 변경 오류:', err);
    res.status(500).json({ error: '서버 오류' });
  }
});

router.get('/users/all', async (req, res) => {
  try {
    const pool = await sql.connect(dbConfig);
    const result = await pool.request()
      .query("SELECT UserID, Role FROM Users WHERE UserID != 'admin'"); // 🔒 admin 제외

    const users = result.recordset.reduce((acc, row) => {
      acc[row.UserID] = row.Role;
      return acc;
    }, {});

    res.json(users); // 예: { test1: "enabled", test2: "disabled", ... }
  } catch (err) {
    console.error('❌ 전체 사용자 조회 오류:', err);
    res.status(500).json({ error: '서버 오류' });
  }
});


module.exports = router;