// routes/sensorinfo.js
const express = require('express');
const router = express.Router();
const sql = require('mssql');
const { DateTime } = require('luxon');
const { poolConnect } = require('../db'); // { pool, poolConnect } 중 poolConnect만 써도 OK

// 테이블명 (고정)
const TBL = 'master.dbo.SenSorInfo';

/** KST(Asia/Seoul) 기준 'yyyy-LL-dd HH:mm:ss' 문자열로 포맷 */
function toKstString(input) {
  try {
    if (!input) {
      return DateTime.now().setZone('Asia/Seoul').toFormat('yyyy-LL-dd HH:mm:ss');
    }
    if (input instanceof Date) {
      return DateTime.fromJSDate(input).setZone('Asia/Seoul').toFormat('yyyy-LL-dd HH:mm:ss');
    }
    // 우선 ISO 시도, 실패시 지정 포맷 시도
    const iso = DateTime.fromISO(String(input), { setZone: true });
    if (iso.isValid) {
      return iso.setZone('Asia/Seoul').toFormat('yyyy-LL-dd HH:mm:ss');
    }
    const fmt = DateTime.fromFormat(String(input), 'yyyy-LL-dd HH:mm:ss', { zone: 'Asia/Seoul' });
    if (fmt.isValid) {
      return fmt.toFormat('yyyy-LL-dd HH:mm:ss');
    }
  } catch (_) {}
  return DateTime.now().setZone('Asia/Seoul').toFormat('yyyy-LL-dd HH:mm:ss');
}

/** 응답용: DB의 KST(local) datetime -> ISO(+09:00) */
function kstToIso(rowDate) {
  // DB에는 'yyyy-MM-dd HH:mm:ss' 로 저장되어 있다고 가정
  return rowDate ? new Date(`${rowDate}+09:00`).toISOString() : null;
}

/** body에 필드가 ‘존재하는지’를 기준으로 COALESCE 업데이트를 위해 값/NULL을 결정 */
function pickOrNull(body, key) {
  return Object.prototype.hasOwnProperty.call(body, key) ? body[key] : null;
}

// ---------------------------------------------------------------------------
// GET: 전체 조회 (최신순)
// ---------------------------------------------------------------------------
router.get('/sensorinfo', async (req, res) => {
  try {
    const pool = await poolConnect;
    const result = await pool.request().query(`
      SELECT IndexKey, RID, Label, Latitude, Longitude, Location, SensorType, EventType, CreateAt
      FROM ${TBL}
      ORDER BY CreateAt DESC
    `);

    const rows = result.recordset.map(r => ({
      ...r,
      CreateAt: kstToIso(r.CreateAt),
    }));

    res.status(200).json({ message: 'SenSorInfo 전체 조회 성공', data: rows });
  } catch (err) {
    console.error('❌ SenSorInfo 전체 조회 실패:', err);
    res.status(500).json({ error: 'SenSorInfo DB 조회 실패' });
  }
});

// ---------------------------------------------------------------------------
// GET: 단건 조회 (RID 기준)
// ---------------------------------------------------------------------------
router.get('/sensorinfo/:rid', async (req, res) => {
  const rid = String(req.params.rid || '').trim();
  if (!rid) return res.status(400).json({ error: 'RID가 필요합니다.' });

  try {
    const pool = await poolConnect;
    const result = await pool.request()
      .input('RID', sql.NVarChar(100), rid)
      .query(`
        SELECT IndexKey, RID, Label, Latitude, Longitude, Location, SensorType, EventType, CreateAt
        FROM ${TBL}
        WHERE RID = @RID
      `);

    if (result.recordset.length === 0) {
      return res.status(404).json({ error: '해당 RID의 행이 없습니다.' });
    }

    const row = result.recordset[0];
    row.CreateAt = kstToIso(row.CreateAt);
    res.status(200).json({ message: 'SenSorInfo 단건 조회 성공', data: row });
  } catch (err) {
    console.error('❌ SenSorInfo 단건 조회 실패:', err);
    res.status(500).json({ error: 'SenSorInfo 단건 조회 실패' });
  }
});

// ---------------------------------------------------------------------------
// POST: 행 추가 (INSERT) — IndexKey는 NEWID() 기본값 사용
// body: { RID*(필수), Label, Latitude, Longitude, Location, SensorType, EventType, CreateAt? }
// ---------------------------------------------------------------------------
router.post('/sensorinfo', async (req, res) => {
  const {
    RID,
    Label,
    Latitude,
    Longitude,
    Location,
    SensorType,
    EventType,
    CreateAt,
  } = req.body || {};

  const rid = String(RID || '').trim();
  if (!rid) return res.status(400).json({ error: 'RID는 필수입니다.' });

  const label = Label != null ? String(Label).trim() : null;
  const sensorType = SensorType != null ? String(SensorType).trim() : null;
  const eventType = EventType != null ? String(EventType).trim() : null;
  const createAtStr = toKstString(CreateAt); // KST 보존 문자열

  try {
    const pool = await poolConnect;

    // 중복 RID 검사 (선택)
    const exist = await pool.request()
      .input('RID', sql.NVarChar(100), rid)
      .query(`SELECT TOP 1 RID FROM ${TBL} WHERE RID = @RID`);

    if (exist.recordset.length > 0) {
      return res.status(409).json({ error: '이미 존재하는 RID입니다.' });
    }

    const insert = await pool.request()
      .input('RID', sql.NVarChar(100), rid)
      .input('Label', sql.NVarChar(100), label)
      .input('Latitude', sql.Float, Latitude ?? null)
      .input('Longitude', sql.Float, Longitude ?? null)
      .input('Location', sql.NVarChar(255), Location ?? null)
      .input('SensorType', sql.NVarChar(100), sensorType)
      .input('EventType', sql.NVarChar(100), eventType)
      .input('CreateAt', sql.VarChar, createAtStr) // 테이블은 DATETIME → 문자열로 안전 삽입
      .query(`
        INSERT INTO ${TBL}
          (RID, Label, Latitude, Longitude, Location, SensorType, EventType, CreateAt)
        OUTPUT INSERTED.*
        VALUES
          (@RID, @Label, @Latitude, @Longitude, @Location, @SensorType, @EventType, @CreateAt)
      `);

    const row = insert.recordset[0];
    row.CreateAt = kstToIso(row.CreateAt);
    res.status(200).json({ message: '행 추가 성공', data: row });
  } catch (err) {
    if (err && (err.number === 2601 || err.number === 2627)) {
      return res.status(409).json({ error: 'RID 유니크 충돌' });
    }
    console.error('❌ SenSorInfo 행 추가 실패:', err);
    res.status(500).json({ error: 'SenSorInfo 행 추가 실패' });
  }
});

// ---------------------------------------------------------------------------
// PUT: 행 수정 (RID 기준 부분 업데이트)
// body에 ‘존재하는 필드’만 갱신되도록 COALESCE 사용
// ---------------------------------------------------------------------------
router.put('/sensorinfo/:rid', async (req, res) => {
  const rid = String(req.params.rid || '').trim();
  if (!rid) return res.status(400).json({ error: 'RID가 필요합니다.' });

  // 존재 여부 확인
  try {
    const pool = await poolConnect;

    const found = await pool.request()
      .input('RID', sql.NVarChar(100), rid)
      .query(`SELECT TOP 1 RID FROM ${TBL} WHERE RID = @RID`);

    if (found.recordset.length === 0) {
      return res.status(404).json({ error: '수정 대상 RID가 없습니다.' });
    }

    const Label = pickOrNull(req.body, 'Label');
    const Latitude = pickOrNull(req.body, 'Latitude');
    const Longitude = pickOrNull(req.body, 'Longitude');
    const Location = pickOrNull(req.body, 'Location');
    const SensorType = pickOrNull(req.body, 'SensorType');
    const EventType = pickOrNull(req.body, 'EventType');
    const CreateAt = pickOrNull(req.body, 'CreateAt');

    const label = Label != null ? String(Label).trim() : null;
    const sensorType = SensorType != null ? String(SensorType).trim() : null;
    const eventType = EventType != null ? String(EventType).trim() : null;
    const createAtStr = CreateAt != null ? toKstString(CreateAt) : null;

    await pool.request()
      .input('RID', sql.NVarChar(100), rid)
      .input('Label', sql.NVarChar(100), label)
      .input('Latitude', sql.Float, Latitude)
      .input('Longitude', sql.Float, Longitude)
      .input('Location', sql.NVarChar(255), Location)
      .input('SensorType', sql.NVarChar(100), sensorType)
      .input('EventType', sql.NVarChar(100), eventType)
      .input('CreateAt', sql.VarChar, createAtStr)
      .query(`
        UPDATE ${TBL}
        SET
          Label      = COALESCE(@Label, Label),
          Latitude   = COALESCE(@Latitude, Latitude),
          Longitude  = COALESCE(@Longitude, Longitude),
          Location   = COALESCE(@Location, Location),
          SensorType = COALESCE(@SensorType, SensorType),
          EventType  = COALESCE(@EventType, EventType),
          CreateAt   = COALESCE(@CreateAt, CreateAt)
        WHERE RID = @RID
      `);

    // 수정 후 조회해서 반환
    const after = await pool.request()
      .input('RID', sql.NVarChar(100), rid)
      .query(`
        SELECT IndexKey, RID, Label, Latitude, Longitude, Location, SensorType, EventType, CreateAt
        FROM ${TBL}
        WHERE RID = @RID
      `);

    const row = after.recordset[0];
    row.CreateAt = kstToIso(row.CreateAt);
    res.status(200).json({ message: '행 수정 성공', data: row });
  } catch (err) {
    console.error('❌ SenSorInfo 행 수정 실패:', err);
    res.status(500).json({ error: 'SenSorInfo 행 수정 실패' });
  }
});

// ---------------------------------------------------------------------------
// DELETE: 행 삭제 (RID 기준)
// ---------------------------------------------------------------------------
router.delete('/sensorinfo/:rid', async (req, res) => {
  const rid = String(req.params.rid || '').trim();
  if (!rid) return res.status(400).json({ error: 'RID가 필요합니다.' });

  try {
    const pool = await poolConnect;
    const result = await pool.request()
      .input('RID', sql.NVarChar(100), rid)
      .query(`DELETE FROM ${TBL} WHERE RID = @RID`);

    if (result.rowsAffected[0] === 0) {
      return res.status(404).json({ error: '삭제 대상이 없습니다.' });
    }
    res.status(200).json({ message: '행 삭제 성공' });
  } catch (err) {
    console.error('❌ SenSorInfo 행 삭제 실패:', err);
    res.status(500).json({ error: 'SenSorInfo 행 삭제 실패' });
  }
});

module.exports = router;
