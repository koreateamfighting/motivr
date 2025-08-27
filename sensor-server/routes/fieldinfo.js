const express = require('express');
const router = express.Router();
const sql = require('mssql');
const dbConfig = require('../dbConfig');
const { pool, poolConnect } = require('../db'); 
// ✅ 최근 1건의 FieldInfo 조회
router.get('/fieldinfo', async (req, res) => {
  try {
    await poolConnect;
    const result = await pool.request().query(`
      SELECT TOP 1 *
      FROM FieldInfo
      ORDER BY id DESC
    `);

    if (result.recordset.length > 0) {
      res.json(result.recordset[0]);
    } else {
      res.status(404).json({ error: '데이터가 없습니다.' });
    }
  } catch (err) {
    console.error('❌ FieldInfo 조회 오류:', err);
    res.status(500).json({ error: '현장 정보를 불러오는 중 오류 발생' });
  } finally {
    console.log("필드인포");
  }
});

// ✅ FieldInfo 삽입
router.post('/fieldinfo', async (req, res) => {
  const {
    ConstructionType,
    ConstructionName,
    Address,
    Company,
    Orderer,
    Location,
    StartDate,
    EndDate,
    Latitude,
    Longitude
  } = req.body;

  if (!ConstructionType || !ConstructionName || !Address) {
    return res.status(400).json({ error: '필수 항목이 누락되었습니다.' });
  }

  try {
    await poolConnect;
    const query = `
      INSERT INTO FieldInfo (
        ConstructionType, ConstructionName, Address, Company, Orderer,
        Location, StartDate, EndDate, Latitude, Longitude
      ) VALUES (
        N'${ConstructionType.replace(/'/g, "''")}',
        N'${ConstructionName.replace(/'/g, "''")}',
        N'${Address.replace(/'/g, "''")}',
        N'${Company?.replace(/'/g, "''") || ''}',
        N'${Orderer?.replace(/'/g, "''") || ''}',
        N'${Location?.replace(/'/g, "''") || ''}',
        '${StartDate || ''}',
        '${EndDate || ''}',
        ${Latitude || 'NULL'},
        ${Longitude || 'NULL'}
      )
    `;
    await pool.request().query(query);
    res.json({ message: '✅ FieldInfo가 성공적으로 저장되었습니다.' });
  } catch (err) {
    console.error('❌ FieldInfo 저장 오류:', err);
    res.status(500).json({ error: '현장 정보 저장 중 오류 발생' });
  } finally {
    console.log("필드인포");
  }
});

module.exports = router;
