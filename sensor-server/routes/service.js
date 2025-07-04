const express = require('express');
const sql = require('mssql');
const router = express.Router();
const dbConfig = require('../dbConfig');
const { DateTime } = require('luxon');


// 헬스 체크
router.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', time: new Date().toISOString() });
});

// 모든 센서 데이터 조회 (옵션: ?limit=10000)
router.get('/sensor-data', async (req, res) => {
  const limit = parseInt(req.query.limit || '10000'); // 기본 10000건 제한

  try {
    const pool = await sql.connect(dbConfig);
    const result = await pool.request()
      .input('limit', sql.Int, limit)
      .query(`
        SELECT TOP (@limit) *
        FROM RawSensorData
        ORDER BY CreateAt DESC
      `);

    res.status(200).json({ message: '전체 센서 데이터 조회 성공', data: result.recordset });
  } catch (err) {
    console.error('❌ 전체 센서 데이터 조회 실패:', err);
    res.status(500).json({ error: 'DB 조회 실패' });
  }
});


// 센서 데이터 수신 후 유니티 클라
router.post('/sensor', async (req, res) => {
  const data = req.body;
  const createAt = data.CreateAt
  ? DateTime.fromISO(data.CreateAt, { zone: 'Asia/Seoul' }).toFormat('yyyy-LL-dd HH:mm:ss')
  : DateTime.now().setZone('Asia/Seoul').toFormat('yyyy-LL-dd HH:mm:ss');
   
  try {
    const pool = await sql.connect(dbConfig);
    await pool.request()
      .input('RID', sql.VarChar(100), String(data.RID))
      .input('SensorType', sql.NVarChar, String(data.SensorType))
      .input('EventType', sql.NVarChar, String(data.EventType))
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
      .input('CreateAt', sql.VarChar, createAt)
      
      
      
      .query(`
        INSERT INTO dbo.RawSensorData
        (RID, SensorType, EventType, X_Deg, Y_Deg, Z_Deg, X_MM, Y_MM, Z_MM,
         BatteryVoltage, BatteryLevel, Latitude, Longitude,  CreateAt)
        VALUES
        (@RID, @SensorType, @EventType, @X_Deg, @Y_Deg, @Z_Deg, @X_MM, @Y_MM, @Z_MM,
         @BatteryVoltage, @BatteryLevel, @Latitude, @Longitude,  @CreateAt)
      `);

    console.log('✅ 센서 데이터 수신:', JSON.stringify(data, null, 2));

    // ✅ WebSocket 전송
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
        if (client.readyState === 1) {
          client.send(JSON.stringify(payload));
        }
      });
    }

    res.status(200).json({ message: '저장 성공', data });

  } catch (err) {
    console.error('❌ DB 오류:', err);
    res.status(500).json({ error: 'DB 저장 실패' });
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

router.get('/progress', async (req, res) => {
  try {
    const pool = await sql.connect(dbConfig); // ✅ 추가
    const result = await pool.request().query(`
      SELECT TOP 1 progress FROM WorkProgress ORDER BY updated_at DESC
    `);
    res.json({ progress: result.recordset[0]?.progress || 0 });
  } catch (err) {
    console.error('❌ Progress fetch error:', err); // ✅ 에러 로깅도 추가
    res.status(500).send('DB Error');
  }
});

router.post('/progress', async (req, res) => {
  const { progress } = req.body;
  try {
    const pool = await sql.connect(dbConfig); // ❗이 줄이 없으면 에러!
    await pool.request()
      .input('progress', sql.Float, progress)
      .query(`
        INSERT INTO WorkProgress (progress, updated_at) VALUES (@progress, GETDATE())
      `);
    res.sendStatus(200);
  } catch (err) {
    console.error('❌ DB 저장 실패:', err); // 디버깅 출력 추가
    res.status(500).send('DB Error');
  }
});

router.put('/sensor', async (req, res) => {
  const data = req.body;

  // CreateAt 시간 변환
  const luxonCreateAt = DateTime.fromFormat(
    data.CreateAt,
    'yyyy-MM-dd HH:mm:ss', // Flutter에서 보내는 포맷
    { zone: 'Asia/Seoul' }
  );
  
  if (!luxonCreateAt.isValid) {
    return res.status(400).json({ error: 'CreateAt 포맷이 유효하지 않습니다.' });
  }
  
  const parsedCreateAt = luxonCreateAt.toJSDate(); // ⬅ 이게 핵심

  if (!data.RID || !parsedCreateAt) {
    return res.status(400).json({ error: 'RID 또는 CreateAt 누락' });
  }
  
  try {
    const pool = await sql.connect(dbConfig);

    const result = await pool.request()
      .input('RID', sql.VarChar(100), String(data.RID))
      .input('SensorType', sql.NVarChar, String(data.SensorType))
      .input('EventType', sql.NVarChar, String(data.EventType))
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
      .input('CreateAt', sql.DateTime, parsedCreateAt)
      .query(`
        UPDATE RawSensorData
        SET
          SensorType = @SensorType,
          EventType = @EventType,
          X_Deg = @X_Deg,
          Y_Deg = @Y_Deg,
          Z_Deg = @Z_Deg,
          X_MM = @X_MM,
          Y_MM = @Y_MM,
          Z_MM = @Z_MM,
          BatteryVoltage = @BatteryVoltage,
          BatteryLevel = @BatteryLevel,
          Latitude = @Latitude,
          Longitude = @Longitude
          WHERE RID = @RID AND CAST(CreateAt AS DATETIME) = CAST(@CreateAt AS DATETIME)
      `);

    if (result.rowsAffected[0] === 0) {
      return res.status(404).json({ error: '일치하는 센서 데이터가 없습니다' });
    }

    console.log('✅ 센서 데이터 업데이트 성공:', data);

    res.status(200).json({ message: '센서 데이터 업데이트 완료', data });

  } catch (err) {
    console.error('❌ 센서 데이터 업데이트 실패:', err);
    res.status(500).json({ error: 'DB 업데이트 실패' });
  }
});

router.post('/sensor/delete', async (req, res) => {
  const { RID, CreateAt } = req.body;

  if (!RID || !CreateAt) {
    return res.status(400).json({ error: 'RID와 CreateAt은 필수입니다.' });
  }

  const dt = DateTime.fromFormat(CreateAt, 'yyyy-MM-dd HH:mm:ss', { zone: 'Asia/Seoul' });
  if (!dt.isValid) {
    console.error('❌ 잘못된 시간 포맷:', CreateAt);
    return res.status(400).json({ error: 'CreateAt 포맷 오류' });
  }

  const parsedCreateAt = dt.toJSDate(); // Date 객체

  try {
    const pool = await sql.connect(dbConfig);

    const result = await pool.request()
      .input('RID', sql.VarChar(100), RID)
      .input('CreateAt', sql.DateTime, parsedCreateAt)
      .query(`
        DELETE FROM RawSensorData
        WHERE RID = @RID AND CreateAt = @CreateAt
      `);

    if (result.rowsAffected[0] === 0) {
      return res.status(404).json({ error: '삭제할 데이터가 없습니다.' });
    }

    console.log(`🗑️ 센서 데이터 삭제 성공: ${RID}, ${CreateAt}`);
    return res.status(200).json({ message: '삭제 완료' });

  } catch (err) {
    console.error('❌ 센서 데이터 삭제 실패:', err);
    return res.status(500).json({ error: 'DB 삭제 실패' });
  }
});


router.get('/rid-count', async (req, res) => {
  try {
    const pool = await sql.connect(dbConfig);
    const result = await pool.request().query(`
      SELECT COUNT(DISTINCT RID) AS count FROM RawSensorData
    `);

    res.status(200).json({ count: result.recordset[0].count });
  } catch (err) {
    console.error('❌ RID 카운트 조회 실패:', err);
    res.status(500).json({ error: 'DB 조회 실패' });
  }
});

router.get('/sensor-status-summary', async (req, res) => {
  try {
    const pool = await sql.connect(dbConfig);
    
    const now = DateTime.now().setZone('Asia/Seoul'); // ✅ 추가된 부분

    // 총 RID 개수 구하기
    const ridCountResult = await pool.request().query(`
      SELECT COUNT(DISTINCT RID) AS count FROM RawSensorData
    `);
    const total = ridCountResult.recordset[0].count;

    // 최신 데이터만 추출
    const result = await pool.request().query(`
      WITH LatestPerRID AS (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY RID ORDER BY CreateAt DESC) AS rn
        FROM RawSensorData
      )
      SELECT *
      FROM LatestPerRID
      WHERE rn = 1
    `);

    const rows = result.recordset.map(row => ({
      ...row,
      CreateAt: DateTime.fromJSDate(row.CreateAt).setZone('Asia/Seoul').toFormat('yyyy-MM-dd HH:mm:ss'),
    }));

    const statusCount = { normal: 0, caution: 0, danger: 0, needInspection: 0 };

    for (const row of rows) {
      const createdAt = DateTime.fromFormat(row.CreateAt, 'yyyy-MM-dd HH:mm:ss').setZone('Asia/Seoul');
      const minutesDiff = now.diff(createdAt, 'minutes').minutes;

      const degs = [row.X_Deg, row.Y_Deg, row.Z_Deg];

      if (minutesDiff > 30) {
        statusCount.needInspection++;
      } else if ([4].includes(parseInt(row.EventType))) {
        const maxDeg = Math.max(...degs.map(d => Math.abs(d || 0)));
        if (maxDeg >= 5) statusCount.danger++;
        else if (maxDeg >= 3) statusCount.caution++;
      } else if ([2, 5].includes(parseInt(row.EventType)) && degs.every(d => Math.abs(d || 0) <= 3)) {
        statusCount.normal++;
      }
      else{
        statusCount.normal++;
      }
    }

    res.json({ ...statusCount, total });

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
    const pool = await sql.connect(dbConfig);
    const result = await pool.request()
      .input('startDate', sql.VarChar, startDate)
      .input('endDate', sql.VarChar, endDate)
      .query(`
        SELECT *
        FROM RawSensorData
        WHERE CreateAt >= @startDate AND CreateAt <= @endDate
        ORDER BY CreateAt ASC
      `);

    const rows = result.recordset;
    console.log(`📤 총 ${rows.length}건 조회됨`);

    // ✅ 앞에서 20개만 출력 (너무 많으면 줄여서 로그)
    rows.slice(21, 40).forEach((row, idx) => {
      console.log(`🔹 [${idx + 1}] RID=${row.RID}, EventType=${row.EventType}, CreateAt=${row.CreateAt}`);
    });

    res.status(200).json({ data: rows });
  } catch (err) {
    console.error('❌ sensor-data-by-period 오류:', err);
    res.status(500).json({ error: 'DB 조회 실패' });
  }
});







module.exports = router;
