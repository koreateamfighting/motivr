const express = require('express');
const router = express.Router();
const sql = require('mssql');
const dbConfig = require('../dbConfig');
const { DateTime } = require('luxon');
const { pool, poolConnect } = require('../db'); 
const ExcelJS = require('exceljs');

// 🔎 type = 'iot' 알람 조회
router.get('/alarmhistory/iot', async (req, res) => {
  try {
    const pool = await poolConnect;
    const result = await pool.request().query(`
      SELECT TOP 100
        Id, DeviceID, Timestamp, Event, Log, Location, Latitude, Longitude, Type
      FROM AlarmHistory
      WHERE Type = 'iot'
      ORDER BY Timestamp DESC
    `);

    res.status(200).json({ message: 'iot 알람 조회 성공', data: result.recordset });
  } catch (err) {
    console.error('❌ iot 알람 조회 실패:', err);
    res.status(500).json({ error: 'iot 알람 DB 조회 실패' });
  }
});

// 🔎 type = 'cctv' 알람 조회
router.get('/alarmhistory/cctv', async (req, res) => {
  try {
    const pool = await poolConnect;
    const result = await pool.request().query(`
      SELECT TOP 100
        Id, DeviceID, Timestamp, Event, Log, Location, Latitude, Longitude, Type
      FROM AlarmHistory
      WHERE Type = 'cctv'
      ORDER BY Timestamp DESC
    `);

    res.status(200).json({ message: 'cctv 알람 조회 성공', data: result.recordset });
  } catch (err) {
    console.error('❌ cctv 알람 조회 실패:', err);
    res.status(500).json({ error: 'cctv 알람 DB 조회 실패' });
  }
});

// 🔎 CCTV 알람 중 '주의' 또는 '경고' 이벤트만 조회 (DeviceID,so Timestamp, Event 포함)
router.get('/alarmhistory/cctv/alert', async (req, res) => {
  try {
    const pool = await poolConnect;

    const result = await pool.request().query(`
      SELECT DeviceID, Timestamp, Event
      FROM AlarmHistory
      WHERE Type = 'cctv'
        AND Event IN (N'주의', N'경고')
        AND CONVERT(date, DATEADD(hour, 9, Timestamp)) = CONVERT(date, DATEADD(hour, 9, GETDATE()))
      ORDER BY Timestamp DESC
    `);

    const rows = result.recordset.map(row => ({
      DeviceID: row.DeviceID,
      Event: row.Event,
      Timestamp: new Date(`${row.Timestamp}+09:00`).toISOString()
    }));

    res.status(200).json({ message: '주의/경고 CCTV 알람 조회 성공', data: rows });
  } catch (err) {
    console.error('❌ 주의/경고 CCTV 알람 조회 실패:', err);
    res.status(500).json({ error: '주의/경고 CCTV 알람 조회 실패' });
  }
});



// ✅ IoT 알람 히스토리 추가 전용
router.post('/alarmhistory/iot', async (req, res) => {
  const {
    DeviceID,   // RID
    Label,      // 라벨명
    Timestamp,
    Event,
    Log,
    Latitude,
    Longitude
  } = req.body;

  const combinedDeviceId = `${Label} #${DeviceID}`;
  const formattedTime = Timestamp
    ? DateTime.fromISO(Timestamp, { zone: 'Asia/Seoul' }).toFormat('yyyy-LL-dd HH:mm:ss')
    : DateTime.now().setZone('Asia/Seoul').toFormat('yyyy-LL-dd HH:mm:ss');

  try {
    const pool = await poolConnect;

    const insertResult = await pool.request()
      .input('DeviceID', sql.NVarChar, combinedDeviceId)
      .input('Timestamp', sql.VarChar, formattedTime)
      .input('Event', sql.NVarChar, Event)
      .input('Log', sql.NVarChar, Log)
      .input('Location', sql.NVarChar, Label)
      .input('Latitude', sql.Float, Latitude)
      .input('Longitude', sql.Float, Longitude)
      .input('Type', sql.NVarChar, 'iot')
      .query(`
        INSERT INTO AlarmHistory (DeviceID, Timestamp, Event, Log, Location, Latitude, Longitude, Type)
        OUTPUT INSERTED.*
        VALUES (@DeviceID, @Timestamp, @Event, @Log, @Location, @Latitude, @Longitude, @Type)
      `);

    const insertedRow = insertResult.recordset[0];

    // ✅ WebSocket 브로드캐스트 조건
    if (['주의', '경고', '점검필요'].includes(Event)) {
      const wss = req.app.get('wss');
      if (wss && wss.clients) {
        const message = {
          type: 'iot-alert',
          data: {
            ...insertedRow,
            Timestamp: new Date(`${insertedRow.Timestamp}+09:00`).toISOString()
          }
        };

        // 모든 클라이언트에게 전송
        wss.clients.forEach(client => {
          if (client.readyState === 1) { // OPEN
            client.send(JSON.stringify(message));
          }
        });
      }
    }

    res.status(200).json({ message: 'IoT 알람 추가 완료' });
  } catch (err) {
    console.error('❌ IoT 알람 저장 실패:', err);
    res.status(500).json({ error: 'IoT 알람 저장 실패' });
  }
});



// ✅ CCTV 알람 히스토리 추가 전용
router.post('/alarmhistory/cctv', async (req, res) => {
  const {
    DeviceID,
    Timestamp,
    Event,
    Log,
    Location
  } = req.body;

  const formattedTime = Timestamp
    ? DateTime.fromISO(Timestamp, { zone: 'Asia/Seoul' }).toFormat('yyyy-LL-dd HH:mm:ss')
    : DateTime.now().setZone('Asia/Seoul').toFormat('yyyy-LL-dd HH:mm:ss');

  try {
    const pool = await poolConnect;

    await pool.request()
      .input('DeviceID', sql.NVarChar, DeviceID)
      .input('Timestamp', sql.VarChar, formattedTime)
      .input('Event', sql.NVarChar, Event)
      .input('Log', sql.NVarChar, `[${DeviceID}] ${Log}`)
      .input('Location', sql.NVarChar, Location)
      .input('Latitude', sql.Float, null)
      .input('Longitude', sql.Float, null)
      .input('Type', sql.NVarChar, 'cctv')
      .query(`
        INSERT INTO AlarmHistory (DeviceID, Timestamp, Event, Log, Location, Latitude, Longitude, Type)
        VALUES (@DeviceID, @Timestamp, @Event, @Log, @Location, @Latitude, @Longitude, @Type)
      `);

    res.status(200).json({ message: 'CCTV 알람 추가 완료' });
  } catch (err) {
    console.error('❌ CCTV 알람 저장 실패:', err);
    res.status(500).json({ error: 'CCTV 알람 저장 실패' });
  }
});



// 알람 히스토리 수정 전용 API
router.put('/alarmhistory/update', async (req, res) => {
  const alarms = req.body;

  if (!Array.isArray(alarms) || alarms.length === 0) {
    return res.status(400).json({ error: '수정할 알람 데이터가 없습니다.' });
  }

  try {
    await poolConnect;

    for (const alarm of alarms) {
      const {
        Id, Timestamp, Event, Log
      } = alarm;

      if (!Id || !Timestamp || !Event) continue;

      const formattedTime = DateTime.fromISO(Timestamp, { zone: 'Asia/Seoul' }).toFormat('yyyy-LL-dd HH:mm:ss');

      await pool.request()
        .query(`
          UPDATE AlarmHistory
          SET 
            Timestamp = '${formattedTime}',
            Event = N'${Event.replace(/'/g, "''")}',
            Log = N'${(Log || '').replace(/'/g, "''")}'
          WHERE Id = ${Id}
        `);
    }

    res.status(200).json({ message: '알람 수정 완료' });
  } catch (err) {
    console.error('❌ 알람 수정 오류:', err);
    res.status(500).json({ error: '알람 수정 중 오류 발생' });
  }
});
// 알람 히스토리 삭제 전용 API
router.post('/alarmhistory/delete', async (req, res) => {
  const { ids } = req.body;

  if (!Array.isArray(ids) || ids.length === 0) {
    return res.status(400).json({ error: '삭제할 ID가 없습니다.' });
  }

  try {
    const pool = await poolConnect;

    const idList = ids.join(',');

     await pool.request().query(`
      DELETE FROM AlarmHistory
      WHERE Id IN (${idList})
    `);

    res.status(200).json({ message: '알람 삭제 완료' });
  } catch (err) {
    console.error('❌ 알람 삭제 오류:', err);
    res.status(500).json({ error: '알람 삭제 중 오류 발생' });
  }
});
//최근 7일내 의 cctv 주의,경고 로드 엑셀 파일 다운로드
router.get('/alarmhistory/download-excel-cctv', async (req, res) => {
  const { camId } = req.query;

  if (!camId) return res.status(400).json({ error: 'camId는 필수입니다.' });

  try {
    const pool = await poolConnect; // ✅ 명시적으로 pool 선언 추가
    const workbook = new ExcelJS.Workbook();
    const sheet = workbook.addWorksheet('AlarmHistory');

    const result = await pool.request()
      .input('DeviceID', sql.NVarChar, camId)
      .query(`
        SELECT DeviceID, Timestamp, Event, Log, Location
        FROM AlarmHistory
        WHERE DeviceID = @DeviceID
          AND Type = 'cctv'
          AND Timestamp >= DATEADD(DAY, -7, GETDATE())
        ORDER BY Timestamp DESC
      `);

    sheet.columns = [
      { header: 'DeviceID', key: 'DeviceID' },
      { header: 'Timestamp', key: 'Timestamp', style: { numFmt: 'yyyy-mm-dd hh:mm:ss' } },
      { header: 'Event', key: 'Event' },
      { header: 'Log', key: 'Log' },
      { header: 'Location', key: 'Location' },
    ];

    result.recordset.forEach(row => {
      sheet.addRow(row);
    });

    const filename = `alarm_logs_${camId}_${new Date().toISOString().slice(0,10)}.xlsx`;
    res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    res.setHeader('Content-Disposition', `attachment; filename=${filename}`);
    await workbook.xlsx.write(res);
    res.end();
  } catch (err) {
    console.error('❌ 알람 히스토리 엑셀 다운로드 실패:', err);
    res.status(500).json({ error: '서버 오류' });
  }
});
//멀티디바이스 다운로드 가능, 특정 기간을 설정하여 cctv 주의,경고 로드 엑셀 파일 다운로드 (default는 당일)
router.get('/alarmhistory/download-excel-cctv-period-multi', async (req, res) => {
  const { camId, startDate, endDate } = req.query;

  if (!camId || !startDate || !endDate) {
    return res.status(400).json({ error: 'camId, startDate, endDate는 필수입니다.' });
  }

  try {
    const deviceIds = camId.split(',').map(id => id.trim()).filter(Boolean);
    const pool = await poolConnect;
    const workbook = new ExcelJS.Workbook();

    for (const deviceId of deviceIds) {
      const result = await pool.request()
        .input('DeviceID', sql.NVarChar, deviceId)
        .input('StartDate', sql.DateTime, new Date(startDate))
        .input('EndDate', sql.DateTime, new Date(endDate))
        .query(`
          SELECT DeviceID, Timestamp, Event, Log, Location
          FROM AlarmHistory
          WHERE DeviceID = @DeviceID
            AND Type = 'cctv'
            AND Timestamp BETWEEN @StartDate AND @EndDate
          ORDER BY Timestamp DESC
        `);

      const sheet = workbook.addWorksheet(deviceId);
      sheet.columns = [
        { header: 'DeviceID', key: 'DeviceID' },
        { header: 'Timestamp', key: 'Timestamp', style: { numFmt: 'yyyy-mm-dd hh:mm:ss' } },
        { header: 'Event', key: 'Event' },
        { header: 'Log', key: 'Log' },
        { header: 'Location', key: 'Location' },
      ];

      result.recordset.forEach(row => {
        sheet.addRow(row);
      });
    }

    const dateStr = new Date().toISOString().slice(0, 10);
    let filename = '';

    if (deviceIds.length === 1) {
      filename = `alarm_logs_${deviceIds[0]}_${dateStr}.xlsx`;
    } else {
      filename = `alarm_logs_${deviceIds[0]}~${deviceIds[deviceIds.length - 1]}_${dateStr}.xlsx`;
    }

    res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    res.setHeader('Content-Disposition', `attachment; filename=${filename}`);

    await workbook.xlsx.write(res);
    res.end();
  } catch (err) {
    console.error('❌ 복수 CCTV 기간 엑셀 다운로드 실패:', err);
    res.status(500).json({ error: '서버 오류' });
  }
});



// ✅ CCTV 로그 저장용 API
router.post('/alarmhistory/cctvlog', async (req, res) => {
  const { camId, isConnected } = req.body;

  if (!camId || typeof isConnected !== 'boolean') {
    return res.status(400).json({ error: 'camId 또는 isConnected 누락됨' });
  }

  const event = isConnected ? '점검필요' : '정상';
  const log = isConnected
    ? `[${camId}]영상 이미지 수집 실패`
    : `[${camId}]영상 이미지 수집 성공`;
  const timestamp = DateTime.now().setZone('Asia/Seoul').toFormat('yyyy-LL-dd HH:mm:ss');

  try {
    const pool = await poolConnect;

    await pool.request()
      .input('DeviceID', sql.NVarChar, camId)
      .input('Timestamp', sql.VarChar, timestamp)
      .input('Event', sql.NVarChar, event)
      .input('Log', sql.NVarChar, log)
      .input('Location', sql.NVarChar, null)
      .input('Latitude', sql.Float, null)
      .input('Longitude', sql.Float, null)
      .input('Type', sql.NVarChar, 'cctv')
      .query(`
        INSERT INTO AlarmHistory (DeviceID, Timestamp, Event, Log, Location, Latitude, Longitude, Type)
        VALUES (@DeviceID, @Timestamp, @Event, @Log, @Location, @Latitude, @Longitude, @Type)
      `);

    res.status(200).json({ message: 'CCTV 알람 저장 완료' });
  } catch (err) {
    console.error('❌ CCTV 로그 저장 실패:', err);
    res.status(500).json({ error: 'CCTV 로그 저장 실패' });
  }
});

router.get('/alarmhistory/cctv/latest', async (req, res) => {
  try {
    const pool = await poolConnect;

    const result = await pool.request().query(`
      SELECT ah.*
      FROM AlarmHistory ah
      JOIN (
        SELECT DeviceID, MAX(Timestamp) AS LatestTime
        FROM AlarmHistory
        WHERE Type = 'cctv'
        GROUP BY DeviceID
      ) latest
      ON ah.DeviceID = latest.DeviceID AND ah.Timestamp = latest.LatestTime
      WHERE ah.Type = 'cctv'
      ORDER BY ah.Timestamp DESC;
    `);

    // ⏰ KST → ISO 8601 (with UTC offset)
    const rows = result.recordset.map(row => ({
      ...row,
      Timestamp: new Date(`${row.Timestamp}+09:00`).toISOString()
    }));

    res.status(200).json({ message: '최신 CCTV 알람 조회 성공', data: rows });
  } catch (err) {
    console.error('❌ 최신 CCTV 알람 조회 실패:', err);
    res.status(500).json({ error: '최신 CCTV 알람 조회 실패' });
  }
});

// 🔎 CCTV 알람 중 특정 DeviceID + '주의' 또는 '경고' 최신순 100건
router.get('/alarmhistory/cctv/alert-by-device/:deviceId', async (req, res) => {
  const deviceId = req.params.deviceId;

  if (!deviceId) {
    return res.status(400).json({ error: 'DeviceID가 필요합니다.' });
  }

  try {
    const pool = await poolConnect;

    const result = await pool.request()
      .input('DeviceID', sql.NVarChar, deviceId)
      .query(`
        SELECT TOP 100 DeviceID, Timestamp, Event
        FROM AlarmHistory
        WHERE Type = 'cctv'
          AND Event IN (N'주의', N'경고')
          AND DeviceID = @DeviceID
        ORDER BY Timestamp DESC
      `);

    const rows = result.recordset.map(row => ({
      DeviceID: row.DeviceID,
      Event: row.Event,
      Timestamp: new Date(`${row.Timestamp}+09:00`).toISOString()
    }));

    res.status(200).json({ message: `${deviceId} 알람 조회 성공`, data: rows });
  } catch (err) {
    console.error(`❌ ${deviceId} 알람 조회 실패:`, err);
    res.status(500).json({ error: '알람 조회 중 오류 발생' });
  }
});

// 🔎 CCTV 그래프 시각화용: 시간 범위에 따라 '주의', '경고' 알람 조회
router.get('/alarmhistory/cctv/graph-data', async (req, res) => {
  const { startDate, endDate } = req.query;

  if (!startDate || !endDate) {
    return res.status(400).json({ error: 'startDate와 endDate는 필수입니다.' });
  }

  try {
    await poolConnect;

    const result = await pool.request()
      .input('startDate', sql.VarChar, startDate)
      .input('endDate', sql.VarChar, endDate)
      .query(`
        SELECT DeviceID, Timestamp, Event
        FROM AlarmHistory
        WHERE Type = 'cctv'
          AND Event IN (N'주의', N'경고')
          AND Timestamp >= @startDate AND Timestamp <= @endDate
        ORDER BY Timestamp ASC
      `);

    const rows = result.recordset.map(row => ({
      DeviceID: row.DeviceID,
      Event: row.Event,
      Timestamp: new Date(`${row.Timestamp}+09:00`).toISOString()
    }));

    res.status(200).json({
      message: 'CCTV 그래프용 알람 데이터 조회 성공',
      data: rows
    });
  } catch (err) {
    console.error('❌ CCTV 그래프용 알람 데이터 조회 실패:', err);
    res.status(500).json({ error: 'CCTV 그래프용 알람 데이터 조회 실패' });
  }
});


// // ✅ 알람 히스토리 추가 또는 업데이트
// router.post('/alarmhistory', async (req, res) => {
//   const {
//     DeviceID,
//     Timestamp,
//     Event,
//     Log,
//     Location,
//     Latitude,
//     Longitude,
//     Type
//   } = req.body;

//   // 타임스탬프 가공
//   const formattedTime = Timestamp
//     ? DateTime.fromISO(Timestamp, { zone: 'Asia/Seoul' }).toFormat('yyyy-LL-dd HH:mm:ss')
//     : DateTime.now().setZone('Asia/Seoul').toFormat('yyyy-LL-dd HH:mm:ss');

//   try {
//     const pool = await poolConnect;

//     // 기존 DeviceID 존재 여부 확인
//     const check = await pool.request()
//       .input('DeviceID', sql.NVarChar, DeviceID)
//       .query(`SELECT Id FROM AlarmHistory WHERE DeviceID = @DeviceID`);

//     if (check.recordset.length > 0) {
//       // 🟠 UPDATE
//       await pool.request()
//         .input('DeviceID', sql.NVarChar, DeviceID)
//         .input('Timestamp', sql.VarChar, formattedTime)
//         .input('Event', sql.NVarChar, Event)
//         .input('Log', sql.NVarChar, Log)
//         .input('Location', sql.NVarChar, Location)
//         .input('Latitude', sql.Float, Latitude)
//         .input('Longitude', sql.Float, Longitude)
//         .input('Type', sql.NVarChar, Type)
//         .query(`
//           UPDATE AlarmHistory
//           SET Timestamp = @Timestamp,
//               Event = @Event,
//               Log = @Log,
//               Location = @Location,
//               Latitude = @Latitude,
//               Longitude = @Longitude,
//               Type = @Type
//           WHERE DeviceID = @DeviceID
//         `);

//       res.status(200).json({ message: '기존 알람 업데이트 완료' });
//     } else {
//       // 🟢 INSERT
//       await pool.request()
//         .input('DeviceID', sql.NVarChar, DeviceID)
//         .input('Timestamp', sql.VarChar, formattedTime)
//         .input('Event', sql.NVarChar, Event)
//         .input('Log', sql.NVarChar, Log)
//         .input('Location', sql.NVarChar, Location)
//         .input('Latitude', sql.Float, Latitude)
//         .input('Longitude', sql.Float, Longitude)
//         .input('Type', sql.NVarChar, Type)
//         .query(`
//           INSERT INTO AlarmHistory (DeviceID, Timestamp, Event, Log, Location, Latitude, Longitude, Type)
//           VALUES (@DeviceID, @Timestamp, @Event, @Log, @Location, @Latitude, @Longitude, @Type)
//         `);

//       res.status(200).json({ message: '새 알람 추가 완료' });
//     }
//   } catch (err) {
//     console.error('❌ 알람 히스토리 저장 실패:', err);
//     res.status(500).json({ error: 'DB 저장 실패' });
//   }
// });



module.exports = router;
