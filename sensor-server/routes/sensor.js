const express = require('express');
// sensor.js
const { sql, poolConnect, pool } = require('../db'); // ✅ 수정!

const router = express.Router();
const dbConfig = require('../dbConfig');
const { DateTime } = require('luxon');
const ExcelJS = require('exceljs');

// 헬스 체크
router.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', time: new Date().toISOString() });
});

// 모든 센서 데이터 조회 (옵션: ?limit=10000)
router.get('/sensor-data', async (req, res) => {
  const limit = parseInt(req.query.limit || '500'); // 기본 10000건 제한

  try {
     await poolConnect;
     const result = await pool.request()
     .input('limit', sql.Int, limit)
     .query(`
       SELECT TOP (@limit)
          IndexKey,RID, SensorType, EventType, X_Deg, Y_Deg, Z_Deg,X_MM, Y_MM, Z_MM,
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


// 센서 데이터 수신 후 유니티 클라
router.post('/sensor', async (req, res) => {
  const data = req.body;
  const createAt = data.CreateAt
  ? DateTime.fromISO(data.CreateAt, { zone: 'Asia/Seoul' }).toFormat('yyyy-LL-dd HH:mm:ss')
  : DateTime.now().setZone('Asia/Seoul').toFormat('yyyy-LL-dd HH:mm:ss');
   
  try {
     await poolConnect;
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
     await poolConnect; // ✅ 추가
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
     await poolConnect; // ❗이 줄이 없으면 에러!
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
     await poolConnect;

    const result = await pool.request()
      .input('IndexKey', sql.UniqueIdentifier, data.IndexKey)
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
          WHERE IndexKey = @IndexKey

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
  console.log('📥 요청 수신 - req.body:', req.body); // 🔍 여기 필수
  const { indexKey } = req.body;

  if (!indexKey) {
    return res.status(400).json({ error: 'indexKey는 필수입니다.' });
  }

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

    console.log(`🗑️ 센서 데이터 삭제 성공: ${indexKey}`);
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
    await poolConnect;

    const result = await pool.request().query(`
WITH Latest AS (
  SELECT
    RID, EventType, X_Deg, Y_Deg, Z_Deg, CreateAt,
    ROW_NUMBER() OVER (PARTITION BY RID ORDER BY CreateAt DESC) AS rn
  FROM RawSensorData WITH (INDEX=IDX_RawSensorData_Latest)
)
SELECT 
  *,
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

      if (minutesAgo > 30) {
        statusCount.needInspection++;
      } else if (eventType === 4) {
        if (maxDeg >= 5) statusCount.danger++;
        else if (maxDeg >= 3) statusCount.caution++;
      } else if ([2, 5].includes(eventType) && degs.every(d => d <= 3)) {
        statusCount.normal++;
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
      .input('startDate', sql.VarChar, startDate)
      .input('endDate', sql.VarChar, endDate)
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
    const workbook = new ExcelJS.Workbook();

    for (const rid of ridList) {
      const result = await pool.request()
        .input('startDate', sql.VarChar, startDate)
        .input('endDate', sql.VarChar, endDate)
        .input('rid', sql.VarChar, rid)
        .query(`
          SELECT RID, SensorType, EventType, X_Deg, Y_Deg, Z_Deg,
                 BatteryVoltage, BatteryLevel, Latitude, Longitude, CreateAt
          FROM RawSensorData
          WHERE RID = @rid
            AND CreateAt >= @startDate
            AND CreateAt <= @endDate
          ORDER BY CreateAt ASC
        `);

      const sheet = workbook.addWorksheet(rid); // 시트 이름 = RID

      sheet.columns = [
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
          style: { numFmt: 'yyyy-mm-dd hh:mm:ss' }, // ✅ 시간 포함 포맷 지정
        },
      ];

      result.recordset.forEach(row => {
        sheet.addRow(row);
      });
    }

    // ✅ 안전한 파일 이름 생성
    const safeStart = startDate.replace(/[: ]/g, '-');
    const safeEnd = endDate.replace(/[: ]/g, '-');
    const filename = `${safeStart}_${safeEnd}_iotdata.xlsx`;

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
        SELECT RID, SensorType, EventType, X_Deg, Y_Deg, Z_Deg,
               BatteryVoltage, BatteryLevel, Latitude, Longitude, CreateAt
        FROM RawSensorData
        WHERE RID = @rid
        ORDER BY CreateAt ASC
      `);

    const sheet = workbook.addWorksheet(rid);

    sheet.columns = [
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
        style: { numFmt: 'yyyy-mm-dd hh:mm:ss' }, // ✅ 시간 포함 포맷 지정
      },
    ];

    result.recordset.forEach(row => {
      sheet.addRow(row);
    });

    const filename = `${rid}_iotdata.xlsx`;
    res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    res.setHeader('Content-Disposition', `attachment; filename=${filename}`);

    await workbook.xlsx.write(res);
    res.end();
  } catch (err) {
    console.error('❌ 엑셀 다운로드 실패:', err);
    res.status(500).json({ error: '엑셀 다운로드 실패' });
  }
});





module.exports = router;
