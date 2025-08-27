const express = require('express');
// sensor.js
const { sql, poolConnect, pool } = require('../db'); // ✅ 수정!

const router = express.Router();
const dbConfig = require('../dbConfig');
const { DateTime } = require('luxon');
const ExcelJS = require('exceljs');

/** ✅ 공통 유틸: 'yyyy-LL-dd HH:mm:ss' or ISO → JS Date(KST 기준) */
/** ✅ UTC/ISO 문자열 → JS Date (KST +9 적용) */
function toKstDate(value) {
  if (value instanceof Date) return DateTime.fromJSDate(value).plus({ hours: 9 }).toJSDate();

  if (typeof value === 'string') {
    // ISO (예: 2025-08-27T23:28:24.163)
    const tryISO = DateTime.fromISO(value, { setZone: true });
    if (tryISO.isValid) {
      return tryISO.plus({ hours: 9 }).toJSDate(); // ✅ 9시간 추가
    }

    // 'yyyy-LL-dd HH:mm:ss'
    const tryFmt = DateTime.fromFormat(value, 'yyyy-LL-dd HH:mm:ss');
    if (tryFmt.isValid) {
      return tryFmt.plus({ hours: 9 }).toJSDate(); // ✅ 9시간 추가
    }
  }

  // fallback: now
  return DateTime.now().plus({ hours: 9 }).toJSDate();
}


/** ✅ SensorInfo 업서트 + Raw 라벨 전파 (RID 단일행 유지) */
async function upsertSensorInfoAndPropagateLabel({
  rid,
  label,
  lat,
  lon,
  sensorType,
  eventType,
  createAt,        // ← JS Date 로 받음
  transaction
}) {
  const normRid = String(rid).trim();
  const normLabel = (label ?? 'unknown').trim();
  const req = transaction ? transaction.request() : pool.request();

  // 1) UPDATE 먼저 (RID 기준)
  const upd = await req
    .input('RID', sql.NVarChar(100), normRid)
    .input('Label', sql.NVarChar(100), normLabel)
    .input('Latitude', sql.Float, lat ?? null)
    .input('Longitude', sql.Float, lon ?? null)
    .input('Location', sql.NVarChar(255), null)
    .input('SensorType', sql.NVarChar(100), sensorType != null ? String(sensorType).trim() : null)
    .input('EventType', sql.NVarChar(100), eventType != null ? String(eventType).trim() : null)
    .input('CreateAt', sql.DateTime2, createAt)     // ✅ DateTime2
    .query(`
      UPDATE master.dbo.SenSorInfo
      SET Label = @Label,
          Latitude = @Latitude,
          Longitude = @Longitude,
          Location = @Location,
          SensorType = @SensorType,
          EventType = @EventType,
          CreateAt = @CreateAt
      WHERE RID = @RID
    `);

  if (upd.rowsAffected[0] === 0) {
    // 2) INSERT, 동시성 유니크 충돌 시 UPDATE로 보정
    try {
      await (transaction ? transaction.request() : pool.request())
        .input('RID', sql.NVarChar(100), normRid)
        .input('Label', sql.NVarChar(100), normLabel)
        .input('Latitude', sql.Float, lat ?? null)
        .input('Longitude', sql.Float, lon ?? null)
        .input('Location', sql.NVarChar(255), null)
        .input('SensorType', sql.NVarChar(100), sensorType != null ? String(sensorType).trim() : null)
        .input('EventType', sql.NVarChar(100), eventType != null ? String(eventType).trim() : null)
        .input('CreateAt', sql.DateTime2, createAt) // ✅ DateTime2
        .query(`
          INSERT INTO master.dbo.SenSorInfo
          (RID, Label, Latitude, Longitude, Location, SensorType, EventType, CreateAt)
          VALUES
          (@RID, @Label, @Latitude, @Longitude, @Location, @SensorType, @EventType, @CreateAt)
        `);
    } catch (e) {
      if (e && (e.number === 2601 || e.number === 2627)) {
        await (transaction ? transaction.request() : pool.request())
          .input('RID', sql.NVarChar(100), normRid)
          .input('Label', sql.NVarChar(100), normLabel)
          .input('Latitude', sql.Float, lat ?? null)
          .input('Longitude', sql.Float, lon ?? null)
          .input('Location', sql.NVarChar(255), null)
          .input('SensorType', sql.NVarChar(100), sensorType != null ? String(sensorType).trim() : null)
          .input('EventType', sql.NVarChar(100), eventType != null ? String(eventType).trim() : null)
          .input('CreateAt', sql.DateTime2, createAt) // ✅ DateTime2
          .query(`
            UPDATE master.dbo.SenSorInfo
            SET Label = @Label,
                Latitude = @Latitude,
                Longitude = @Longitude,
                Location = @Location,
                SensorType = @SensorType,
                EventType = @EventType,
                CreateAt = @CreateAt
            WHERE RID = @RID
          `);
      } else {
        throw e;
      }
    }
  }

  // 3) RawSensorData 라벨 전파 (RID 전체)
  await (transaction ? transaction.request() : pool.request())
    .input('RID', sql.NVarChar(100), normRid)
    .input('Label', sql.NVarChar(100), normLabel)
    .query(`
      UPDATE dbo.RawSensorData
      SET Label = @Label
      WHERE RID = @RID AND (Label IS NULL OR Label <> @Label);
    `);
}



/** ✅ AlarmHistory 삽입: Timestamp를 DateTime2로 직접 삽입(변환 X) */
async function insertAlarmHistoryFromSensorData(data, createAt, transaction = null) {
  const { RID, Label, EventType, Latitude, Longitude } = data;
  const deviceId = `${Label} #${RID}`;

  // createAt이 문자열 or Date → KST Date로 정규화
  const tsDate = toKstDate(createAt);

  let event = '점검필요';
  let log = `${deviceId} : 알려지지 않은 로그`;

  switch (parseInt(EventType)) {
    case 2:
      event = '정상';
      log = `${deviceId} : 정상 로그`;
      break;
    case 5:
      event = '정상';
      log = `${deviceId} : GPS 정상 수집`;
      break;
    case 67:
      event = '주의';
      log = `${deviceId} : 주의 로그`;
      break;
    case 68:
      event = '경고';
      log = `${deviceId} : 경고 로그`;
      break;
  }

  await poolConnect;
  const poolRequest = transaction ? transaction.request() : pool.request();

  // 이전 값 유지 로직
  const lastGeoQuery = `
    SELECT TOP 1 Latitude, Longitude
    FROM AlarmHistory
    WHERE DeviceID = @DeviceID
      AND Type = 'iot'
    ORDER BY Timestamp DESC
  `;

  let lat = Latitude;
  let lon = Longitude;

  if (lat == null || lon == null) {
    const prev = await poolRequest
      .input('DeviceID', sql.NVarChar(100), deviceId)
      .query(lastGeoQuery);
    if (lat == null) lat = prev.recordset[0]?.Latitude ?? null;
    if (lon == null) lon = prev.recordset[0]?.Longitude ?? null;
  }

  // INSERT (CONVERT 제거, DateTime2 직입력)
  const insertRequest = transaction ? transaction.request() : pool.request();
  await insertRequest
    .input('DeviceID', sql.NVarChar(100), deviceId)
    .input('TimestampKST', sql.DateTime2, tsDate)         // ✅ DateTime2
    .input('Event', sql.NVarChar(255), event)
    .input('Log', sql.NVarChar(1000), log)
    .input('Location', sql.NVarChar(255), Label)
    .input('Latitude', sql.Float, lat)
    .input('Longitude', sql.Float, lon)
    .input('Type', sql.NVarChar(20), 'iot')
    .query(`
      INSERT INTO AlarmHistory
      (DeviceID, Timestamp, Event, Log, Location, Latitude, Longitude, Type)
      VALUES
      (@DeviceID, @TimestampKST, @Event, @Log, @Location, @Latitude, @Longitude, @Type)
    `);
}


// 헬스 체크
router.get('/health', (req, res) => {
  const currentTime = DateTime.now().setZone('Asia/Seoul').toISO(); // 서울 시간대로 설정
  res.status(200).json({ status: 'ok', time: currentTime });
});
// 모든 센서 데이터 조회 (옵션: ?limit=1000)
router.get('/sensor-data', async (req, res) => {
  const limit = parseInt(req.query.limit || '1000'); // 기본 1000건 제한

  try {
     await poolConnect;
     const result = await pool.request()
     .input('limit', sql.Int, limit)
     .query(`
       SELECT TOP (@limit)
          IndexKey,RID,Label, SensorType, EventType, X_Deg, Y_Deg, Z_Deg,X_MM, Y_MM, Z_MM,
         BatteryVoltage, BatteryLevel, Latitude, Longitude, CreateAt
       FROM RawSensorData WITH (INDEX(IDX_RawSensorData_CreateAt))
       ORDER BY CreateAt DESC
     `);

    res.status(200).json({ message: '전체 센서 데이터 조회 성공', data: result.recordset });
  } catch (err) {
    console.error('❌ 전체 센서 데이터 조회 실패:', err);
    res.status(500).json({ error: 'DB 조회 실패' });
  }
});



// 센서 데이터 수신 후 유니티 클라이언트
router.post('/sensor', async (req, res) => {
  const data = req.body;

  const label = data.Label ?? 'unknown';
  const createAtDate = toKstDate(data.CreateAt); // ✅ JS Date
  if (!data.RID) return res.status(400).json({ error: 'RID 누락' });

  const t = new sql.Transaction(pool);
  try {
    await poolConnect;
    await t.begin();

    // 1) RawSensorData INSERT
    await t.request()
      .input('RID', sql.NVarChar(100), String(data.RID))
      .input('SensorType', sql.NVarChar(100), data.SensorType != null ? String(data.SensorType) : null)
      .input('EventType', sql.NVarChar(100), data.EventType != null ? String(data.EventType) : null)
      .input('X_Deg', sql.Float, data.X_Deg)
      .input('Y_Deg', sql.Float, data.Y_Deg)
      .input('Z_Deg', sql.Float, data.Z_Deg)
      .input('X_MM', sql.Float, data.X_MM)
      .input('Y_MM', sql.Float, data.Y_MM)
      .input('Z_MM', sql.Float, data.Z_MM)
      .input('BatteryVoltage', sql.Float, data.BatteryVoltage)
      .input('BatteryLevel', sql.Float, data.BatteryLevel)
      .input('Latitude', sql.Float, data.Latitude)
      .input('Longitude', sql.Float, data.Longitude)
      .input('Label', sql.NVarChar(100), label)
      .input('CreateAt', sql.DateTime2, createAtDate)   // ✅ DateTime2
      .query(`
        INSERT INTO dbo.RawSensorData
        (RID, SensorType, EventType, X_Deg, Y_Deg, Z_Deg, X_MM, Y_MM, Z_MM,
         BatteryVoltage, BatteryLevel, Latitude, Longitude, Label, CreateAt)
        VALUES
        (@RID, @SensorType, @EventType, @X_Deg, @Y_Deg, @Z_Deg, @X_MM, @Y_MM, @Z_MM,
         @BatteryVoltage, @BatteryLevel, @Latitude, @Longitude, @Label, @CreateAt)
      `);

    // 2) SenSorInfo 업서트 (RID 기준)
    await t.request()
      .input('RID', sql.NVarChar(100), String(data.RID))
      .input('Label', sql.NVarChar(100), label)
      .input('Latitude', sql.Float, data.Latitude ?? null)
      .input('Longitude', sql.Float, data.Longitude ?? null)
      .input('Location', sql.NVarChar(255), data.Location ?? null)
      .input('SensorType', sql.NVarChar(100), data.SensorType != null ? String(data.SensorType) : null)
      .input('EventType', sql.NVarChar(100), data.EventType != null ? String(data.EventType) : null)
      .input('CreateAt', sql.DateTime2, createAtDate)   // ✅ DateTime2
      .query(`
        MERGE master.dbo.SenSorInfo AS tgt
        USING (SELECT @RID AS RID) AS src
        ON (tgt.RID = src.RID)
        WHEN MATCHED THEN
          UPDATE SET
            Label = @Label,
            Latitude = @Latitude,
            Longitude = @Longitude,
            Location = @Location,
            SensorType = @SensorType,
            EventType = @EventType,
            CreateAt = @CreateAt
        WHEN NOT MATCHED THEN
          INSERT (RID, Label, Latitude, Longitude, Location, SensorType, EventType, CreateAt)
          VALUES (@RID, @Label, @Latitude, @Longitude, @Location, @SensorType, @EventType, @CreateAt);
      `);

    // 3) 라벨 전파
    await t.request()
      .input('RID', sql.NVarChar(100), String(data.RID))
      .input('Label', sql.NVarChar(100), label)
      .query(`
        UPDATE dbo.RawSensorData
        SET Label = @Label
        WHERE RID = @RID AND (Label IS NULL OR Label <> @Label);
      `);

    // 4) AlarmHistory 삽입 (동일 트랜잭션)
    await insertAlarmHistoryFromSensorData(data, createAtDate, t);

    await t.commit();

    console.log('✅ 센서 데이터 수신:', JSON.stringify(data, null, 2));

    // WebSocket 브로드캐스트
    const wss = req.app.get('wss');
    if (wss && wss.clients) {
      const payload = {
        type: 'iotSensorUpdate',
        source: 'server',
        data: {
          ...data,
          CreateAt: data.CreateAt
        }
      };
      wss.clients.forEach(client => {
        if (client.readyState === 1) client.send(JSON.stringify(payload));
      });
    }

    // (선택) 최근 데이터면 SenSorInfo 가벼운 갱신
    const diffMinutes = DateTime.now().setZone('Asia/Seoul')
      .diff(DateTime.fromJSDate(createAtDate), 'minutes').minutes;

    if (diffMinutes <= 30) {
      await pool.request()
        .input('RID', sql.NVarChar(100), String(data.RID))
        .input('Latitude', sql.Float, data.Latitude ?? null)
        .input('Longitude', sql.Float, data.Longitude ?? null)
        .input('SensorType', sql.NVarChar(100), data.SensorType ?? null)
        .input('EventType', sql.NVarChar(100), data.EventType != null ? String(data.EventType) : null)
        .query(`
          UPDATE master.dbo.SenSorInfo
          SET Latitude = @Latitude,
              Longitude = @Longitude,
              SensorType = @SensorType,
              EventType = @EventType
          WHERE RID = @RID;
        `);
    }

    return res.status(200).json({ message: '저장 성공', data });
  } catch (err) {
    try { if (t._aborted !== true) await t.rollback(); } catch (_) {}
    console.error('❌ DB 오류:', err);
    return res.status(500).json({ error: 'DB 저장 실패' });
  }
});


router.post('/test_submit_data', (req, res) => {
  const WebSocket = require('ws');
  const wss = req.app.get('wss');

  const data = req.body;

  const payload = {
    type: 'iotSensorUpdate',
    source: 'client',
    data
  };

  // 🔁 WebSocket으로 클라이언트 데이터만 브로드캐스트
  wss.clients.forEach(client => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(JSON.stringify(payload));
    }
  });

  return res.status(200).json({ message: 'WebSocket broadcast 성공', data });
});

// router.get('/progress', async (req, res) => {
//   try {
//      await poolConnect; // ✅ 추가
//     const result = await pool.request().query(`
//       SELECT TOP 1 progress FROM WorkProgress ORDER BY updated_at DESC
//     `);
//     res.json({ progress: result.recordset[0]?.progress || 0 });
//   } catch (err) {
//     console.error('❌ Progress fetch error:', err); // ✅ 에러 로깅도 추가
//     res.status(500).send('DB Error');
//   }
// });

// router.post('/progress', async (req, res) => {
//   const { progress } = req.body;
//   try {
//      await poolConnect; // ❗이 줄이 없으면 에러!
//     await pool.request()
//       .input('progress', sql.Float, progress)
//       .query(`
//         INSERT INTO WorkProgress (progress, updated_at) VALUES (@progress, GETDATE())
//       `);
//     res.sendStatus(200);
//   } catch (err) {
//     console.error('❌ DB 저장 실패:', err); // 디버깅 출력 추가
//     res.status(500).send('DB Error');
//   }
// });

router.put('/sensor', async (req, res) => {
  const data = req.body;
  if (!data.IndexKey) return res.status(400).json({ error: 'IndexKey 누락' });
  if (!data.RID)      return res.status(400).json({ error: 'RID 누락' });

  // ✅ JS Date로 정규화
  const createAtDate = toKstDate(data.CreateAt);
  const label = data.Label ?? 'unknown';

  const t = new sql.Transaction(pool);
  try {
    await poolConnect;
    await t.begin();

    // 1) 대상 행 업데이트
    const result = await t.request()
      .input('IndexKey', sql.UniqueIdentifier, data.IndexKey)
      .input('RID', sql.NVarChar(100), String(data.RID))
      .input('Label', sql.NVarChar(100), label)
      .input('SensorType', sql.NVarChar(100), data.SensorType != null ? String(data.SensorType) : null)
      .input('EventType', sql.NVarChar(100), data.EventType != null ? String(data.EventType) : null)
      .input('X_Deg', sql.Float, data.X_Deg)
      .input('Y_Deg', sql.Float, data.Y_Deg)
      .input('Z_Deg', sql.Float, data.Z_Deg)
      .input('X_MM', sql.Float, data.X_MM)
      .input('Y_MM', sql.Float, data.Y_MM)
      .input('Z_MM', sql.Float, data.Z_MM)
      .input('BatteryVoltage', sql.Float, data.BatteryVoltage)
      .input('BatteryLevel', sql.Float, data.BatteryLevel)
      .input('Latitude', sql.Float, data.Latitude)
      .input('Longitude', sql.Float, data.Longitude)
      .input('CreateAt', sql.DateTime2, createAtDate)   // ✅ DateTime2
      .query(`
        UPDATE dbo.RawSensorData
        SET Label=@Label, SensorType=@SensorType, EventType=@EventType,
            X_Deg=@X_Deg, Y_Deg=@Y_Deg, Z_Deg=@Z_Deg,
            X_MM=@X_MM, Y_MM=@Y_MM, Z_MM=@Z_MM,
            BatteryVoltage=@BatteryVoltage, BatteryLevel=@BatteryLevel,
            Latitude=@Latitude, Longitude=@Longitude, CreateAt=@CreateAt
        WHERE IndexKey=@IndexKey
      `);

    if (result.rowsAffected[0] === 0) {
      await t.rollback();
      return res.status(404).json({ error: '일치하는 센서 데이터가 없습니다' });
    }

    // 2) SenSorInfo 업서트 + Raw 라벨 전파
    await upsertSensorInfoAndPropagateLabel({
      rid: data.RID,
      label,
      lat: data.Latitude,
      lon: data.Longitude,
      sensorType: data.SensorType,
      eventType: data.EventType,
      createAt: createAtDate,   // ✅ JS Date 전달
      transaction: t
    });

    // 3) AlarmHistory도 갱신
    await insertAlarmHistoryFromSensorData(data, createAtDate, t);

    await t.commit();
    res.status(200).json({ message: '센서 데이터 업데이트 완료', data });
  } catch (err) {
    if (t._aborted !== true) { try { await t.rollback(); } catch {} }
    console.error('❌ 센서 데이터 업데이트 실패:', err);
    res.status(500).json({ error: 'DB 업데이트 실패' });
  }
});

router.post('/sensor/delete', async (req, res) => {
  const { indexKey } = req.body;
  if (!indexKey) return res.status(400).json({ error: 'indexKey는 필수입니다.' });

  try {
    await poolConnect;
    const result = await pool.request()
      .input('IndexKey', sql.VarChar(100), indexKey)
      .query(`
        DELETE FROM RawSensorData
        WHERE IndexKey = @IndexKey
      `);
    if (result.rowsAffected[0] === 0) {
      return res.status(404).json({ error: '삭제할 데이터가 없습니다.' });
    }
    return res.status(200).json({ message: '삭제 완료' });
  } catch (err) {
    console.error('❌ 센서 데이터 삭제 실패:', err);
    return res.status(500).json({ error: 'DB 삭제 실패' });
  }
});

router.get('/rid-count', async (req, res) => {
  try {
    await poolConnect;
    const result = await pool.request().query(`
      SELECT COUNT(*) AS count
      FROM (
        SELECT DISTINCT RID, Label
        FROM RawSensorData
      ) AS UniqueRIDLabel
    `);
    res.status(200).json({ count: result.recordset[0].count });
  } catch (err) {
    console.error('❌ RID+Label 카운트 조회 실패:', err);
    res.status(500).json({ error: 'DB 조회 실패' });
  }
})

router.get('/sensor-status-summary', async (req, res) => {
  try {
    await poolConnect;
    const result = await pool.request().query(`
      WITH Latest AS (
        SELECT
          RID, EventType, X_Deg, Y_Deg, Z_Deg, CreateAt,
          ROW_NUMBER() OVER (PARTITION BY RID ORDER BY CreateAt DESC) AS rn
        FROM RawSensorData WITH (INDEX=IDX_RawSensorData_Latest)
      )
      SELECT 
        RID, EventType, X_Deg, Y_Deg, Z_Deg, CreateAt,
        DATEDIFF(MINUTE, CreateAt, GETDATE()) AS MinutesAgo
      FROM Latest
      WHERE rn = 1
    `);

  const statusCount = { normal: 0, caution: 0, danger: 0, needInspection: 0 };

  for (const row of result.recordset) {
    const minutesAgo = row.MinutesAgo;
    const degs = [row.X_Deg, row.Y_Deg, row.Z_Deg].map(d => Math.abs(d ?? 0));
    const maxDeg = Math.max(...degs);
    const eventType = parseInt(row.EventType);

    if (minutesAgo > 60) {
      statusCount.needInspection++;
    } else if (eventType === 68) {
      if (maxDeg >= 5) statusCount.danger++; else statusCount.normal++;
    } else if (eventType === 67) {
      if (maxDeg >= 3) statusCount.caution++; else statusCount.normal++;
    } else {
      statusCount.normal++;
    }
  }

  res.json({ ...statusCount, total: result.recordset.length });
  } catch (err) {
    console.error('❌ 센서 상태 요약 오류:', err);
    res.status(500).json({ error: 'DB 오류' });
  }
});


router.get('/sensor-data-by-period', async (req, res) => {
  const { startDate, endDate } = req.query;

  if (!startDate || !endDate) {
    return res.status(400).json({ error: 'startDate, endDate are required' });
  }

  // ✅ 입력 로그
  console.log(`📥 센서 조회 요청: startDate=${startDate}, endDate=${endDate}`);

  try {
     await poolConnect;
    const result = await pool.request()
    .input('startDate', sql.VarChar(19), startDate)
    .input('endDate',   sql.VarChar(19), endDate)
      .query(`
        SELECT *
        FROM RawSensorData
        WHERE CreateAt >= @startDate AND CreateAt <= @endDate
        ORDER BY CreateAt ASC
      `);

    const rows = result.recordset;
    // console.log(`📤 총 ${rows.length}건 조회됨`);

    // // ✅ 앞에서 20개만 출력 (너무 많으면 줄여서 로그)
    // rows.slice(21, 40).forEach((row, idx) => {
    //   console.log(`🔹 [${idx + 1}] RID=${row.RID}, EventType=${row.EventType}, CreateAt=${row.CreateAt}`);
    // });

    res.status(200).json({ data: rows });
  } catch (err) {
    console.error('❌ sensor-data-by-period 오류:', err);
    res.status(500).json({ error: 'DB 조회 실패' });
  }
});


router.get('/download-excel', async (req, res) => {
  const { startDate, endDate, rids } = req.query;

  if (!startDate || !endDate || !rids) {
    return res.status(400).json({ error: 'startDate, endDate, rids 모두 필요합니다.' });
  }

  const ridList = rids.split(',').map(r => r.trim());

  try {
    await poolConnect;
    const ExcelJS = require('exceljs');
    const workbook = new ExcelJS.Workbook();
    const resultMap = {}; // ✅ rid → Label 매핑

    for (const rid of ridList) {
      const result = await pool.request()
        .input('startDate', sql.VarChar, startDate)
        .input('endDate', sql.VarChar, endDate)
        .input('rid', sql.VarChar, rid)
        .query(`
          SELECT Label,RID, SensorType, EventType, X_Deg, Y_Deg, Z_Deg,
                 BatteryVoltage, BatteryLevel, Latitude, Longitude, CreateAt
          FROM RawSensorData
          WHERE RID = @rid
            AND CreateAt >= @startDate
            AND CreateAt <= @endDate
          ORDER BY CreateAt ASC
        `);

      if (result.recordset.length > 0) {
        resultMap[rid] = result.recordset[0]; // ✅ 첫 row에서 Label 확보
      }

      const sheet = workbook.addWorksheet(rid);
      sheet.columns = [
        { header: 'Label', key: 'Label' },
        { header: 'RID', key: 'RID' },
        { header: 'SensorType', key: 'SensorType' },
        { header: 'EventType', key: 'EventType' },
        { header: 'X_Deg', key: 'X_Deg' },
        { header: 'Y_Deg', key: 'Y_Deg' },
        { header: 'Z_Deg', key: 'Z_Deg' },
        { header: 'BatteryVoltage', key: 'BatteryVoltage' },
        { header: 'BatteryLevel', key: 'BatteryLevel' },
        { header: 'Latitude', key: 'Latitude' },
        { header: 'Longitude', key: 'Longitude' },
        {
          header: 'CreateAt',
          key: 'CreateAt',
          style: { numFmt: 'yyyy-mm-dd hh:mm:ss' },
        },
      ];

      result.recordset.forEach(row => {
        sheet.addRow(row);
      });
    }

    // ✅ 파일 이름 구성
    const safeStart = startDate.replace(/[: ]/g, '-');
    const safeEnd = endDate.replace(/[: ]/g, '-');
    let filename = '';

    if (ridList.length === 1) {
      const rid = ridList[0];
      const label = resultMap[rid]?.Label || 'nolabel';
      const safeLabel = label.replace(/[^a-zA-Z0-9가-힣_-]/g, '');
      filename = `${safeLabel}_${rid}_${safeStart}_${safeEnd}_iotdata.xlsx`;
    } else {
      const first = ridList[0];
      const last = ridList[ridList.length - 1];
      filename = `${first}_to_${last}_${safeStart}_${safeEnd}_iotdata.xlsx`;
    }

    res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    res.setHeader('Content-Disposition', `attachment; filename=${filename}`);

    await workbook.xlsx.write(res);
    res.end();
  } catch (err) {
    console.error('❌ 엑셀 다운로드 실패:', err);
    res.status(500).json({ error: '엑셀 다운로드 실패' });
  }
});


router.get('/download-excel-rid-only', async (req, res) => {
  const { rid } = req.query;

  if (!rid) {
    return res.status(400).json({ error: 'rid 파라미터가 필요합니다.' });
  }

  try {
    await poolConnect;
    const ExcelJS = require('exceljs');
    const workbook = new ExcelJS.Workbook();

    const result = await pool.request()
      .input('rid', sql.VarChar, rid)
      .query(`
        SELECT Label,RID, SensorType, EventType, X_Deg, Y_Deg, Z_Deg,
               BatteryVoltage, BatteryLevel, Latitude, Longitude, CreateAt
        FROM RawSensorData
        WHERE RID = @rid
        ORDER BY CreateAt ASC
      `);

    const sheet = workbook.addWorksheet(rid);

    sheet.columns = [
      { header: 'Label', key: 'Label' },
      { header: 'RID', key: 'RID' },
      { header: 'SensorType', key: 'SensorType' },
      { header: 'EventType', key: 'EventType' },
      { header: 'X_Deg', key: 'X_Deg' },
      { header: 'Y_Deg', key: 'Y_Deg' },
      { header: 'Z_Deg', key: 'Z_Deg' },
      { header: 'BatteryVoltage', key: 'BatteryVoltage' },
      { header: 'BatteryLevel', key: 'BatteryLevel' },
      { header: 'Latitude', key: 'Latitude' },
      { header: 'Longitude', key: 'Longitude' },
      {
        header: 'CreateAt',
        key: 'CreateAt',
        style: { numFmt: 'yyyy-mm-dd hh:mm:ss' },
      },
    ];

    result.recordset.forEach(row => {
      sheet.addRow(row);
    });

    // ✅ 파일명에 label 포함
    const label = result.recordset[0]?.Label || 'nolabel';
    const safeLabel = label.replace(/[^a-zA-Z0-9가-힣_-]/g, '');
    const filename = `${safeLabel}_${rid}_iotdata.xlsx`;

    res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    res.setHeader('Content-Disposition', `attachment; filename=${filename}`);

    await workbook.xlsx.write(res);
    res.end();
  } catch (err) {
    console.error('❌ 엑셀 다운로드 실패:', err);
    res.status(500).json({ error: '엑셀 다운로드 실패' });
  }
});



// webgl측에서 모든 센서 정보 조회를 하기 위한 목적으로 만든 api (SenSorInfo 테이블 전체)
router.get('/sensor-info', async (req, res) => {
  try {
    await poolConnect;

    const result = await pool.request().query(`
      SELECT 
        IndexKey, RID, Label, Latitude, Longitude,
        Location, SensorType, EventType, CreateAt
      FROM master.dbo.SenSorInfo
      ORDER BY CreateAt DESC
    `);

    res.status(200).json({ message: '센서 정보 조회 성공', data: result.recordset });
  } catch (err) {
    console.error('❌ SenSorInfo 조회 실패:', err);
    res.status(500).json({ error: '센서 정보 조회 실패' });
  }
});

//RID+LABEL별로 각각 최신의 데이터를 유니티에서 받게끔 해주는 api
router.get('/sensor-latest-by-group', async (req, res) => {
  try {
    await poolConnect;

    const result = await pool.request().query(`
      WITH RankedSensorData AS (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY RID, Label ORDER BY CreateAt DESC) AS rn
        FROM RawSensorData
      )
      SELECT *
      FROM RankedSensorData
      WHERE rn = 1
      ORDER BY CreateAt DESC
    `);

    res.status(200).json({ message: 'RID+Label별 최신 센서 데이터', data: result.recordset });
  } catch (err) {
    console.error('❌ sensor-latest-by-group 조회 실패:', err);
    res.status(500).json({ error: 'DB 조회 실패' });
  }
});



module.exports = router;
