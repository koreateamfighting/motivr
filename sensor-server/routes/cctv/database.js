// ✅ routes/cctv/database.js
const express = require('express');
const sql = require('mssql');
const schedule = require('node-schedule');
const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');
const { poolConnect } = require('../../db');
const router = express.Router();





router.get('/cctvs', async (req, res) => {
  try {
    const pool = await poolConnect;
    const result = await pool.request().query(`
      SELECT Id, CamID, Location, IsConnected, EventState, ImageAnalysis, StreamURL, LastRecorded, RecordPath
      FROM CctvStatus
    `);
    res.json(result.recordset);
  } catch (err) {
    console.error('❌ CCTV 조회 실패:', err);
    res.status(500).json({ error: '서버 오류' });
  }
});

router.post('/cctvs', async (req, res) => {
  let {
    camID, location, isConnected, eventState, imageAnalysis,
    streamUrl, recordPath, rtspUrl, onvifXaddr, onvifUser, onvifPass
  } = req.body;

  if (!camID) return res.status(400).json({ error: 'camID는 필수입니다.' });

  const { generateCameraConfig } = require('./util');
  if (!rtspUrl || !onvifXaddr || !onvifUser || !onvifPass) {
    const config = generateCameraConfig(camID);
    if (config) {
      rtspUrl = rtspUrl || config.rtspUrl;
      onvifXaddr = onvifXaddr || config.onvifXaddr;
      onvifUser = onvifUser || config.onvifUser;
      onvifPass = onvifPass || config.onvifPass;
    }
  }

  try {
    const pool = await poolConnect;
    const check = await pool.request()
      .input('CamID', sql.NVarChar, camID)
      .query('SELECT COUNT(*) AS cnt FROM CctvStatus WHERE CamID = @CamID');

    const exists = check.recordset[0].cnt > 0;

    const request = pool.request()
      .input('CamID', sql.NVarChar, camID)
      .input('Location', sql.NVarChar, location || null)
      .input('IsConnected', sql.Bit, isConnected ?? 1)
      .input('EventState', sql.NVarChar, eventState || '정상')
      .input('ImageAnalysis', sql.Float, imageAnalysis ?? 0)
      .input('StreamURL', sql.NVarChar, streamUrl || null)
      .input('RecordPath', sql.NVarChar, recordPath || null)
      .input('RtspUrl', sql.NVarChar, rtspUrl || null)
      .input('OnvifXaddr', sql.NVarChar, onvifXaddr || null)
      .input('OnvifUser', sql.NVarChar, onvifUser || null)
      .input('OnvifPass', sql.NVarChar, onvifPass || null);

    if (exists) {
      await request.query(`
        UPDATE CctvStatus SET
          Location = @Location,
          IsConnected = @IsConnected,
          EventState = @EventState,
          ImageAnalysis = @ImageAnalysis,
          StreamURL = @StreamURL,
          RecordPath = @RecordPath,
          RtspUrl = @RtspUrl,
          OnvifXaddr = @OnvifXaddr,
          OnvifUser = @OnvifUser,
          OnvifPass = @OnvifPass
        WHERE CamID = @CamID
      `);
      res.json({ message: 'CCTV 정보가 업데이트 되었습니다.' });
    } else {
      await request.query(`
        INSERT INTO CctvStatus
        (CamID, Location, IsConnected, EventState, ImageAnalysis, StreamURL, RecordPath, RtspUrl, OnvifXaddr, OnvifUser, OnvifPass)
        VALUES
        (@CamID, @Location, @IsConnected, @EventState, @ImageAnalysis, @StreamURL, @RecordPath, @RtspUrl, @OnvifXaddr, @OnvifUser, @OnvifPass)
      `);
      res.status(201).json({ message: 'CCTV 등록 완료' });
    }
  } catch (err) {
    console.error('❌ CCTV 등록/수정 실패:', err);
    res.status(500).json({ error: '서버 오류' });
  }
});


router.get('/cctvs/device-ids', async (req, res) => {
  try {
    const pool = await poolConnect;
    const result = await pool.request().query(`
      SELECT CamID FROM CctvStatus
    `);
    const camIds = result.recordset.map(row => row.CamID);
    res.status(200).json({ data: camIds });
  } catch (err) {
    console.error('❌ CCTV DeviceID 목록 조회 실패:', err);
    res.status(500).json({ error: 'CCTV DeviceID 목록 조회 실패' });
  }
});



module.exports = router;

const hlsFolder = 'C:\\Users\\Administrator\\sensor-server\\public\\hls';

schedule.scheduleJob('56 * * * *', async () => {
  console.log('⏰ [스케줄러] 매시 56분 - .ts 삭제 + DB + PM2 재시작');

  // 1. .ts 삭제
  fs.readdir(hlsFolder, (err, files) => {
    if (err) {
      console.error('❌ 디렉토리 읽기 오류:', err);
      return;
    }

    files
      .filter(file => file.endsWith('.ts'))
      .forEach(file => {
        const filePath = path.join(hlsFolder, file);
        fs.unlink(filePath, err => {
          if (err) console.error(`❌ ${file} 삭제 실패:`, err);
          else console.log(`🧹 ${file} 삭제됨`);
        });
      });
  });

  // 2. DB LastRecorded 업데이트
  try {
    const now = new Date();
    now.setMinutes(56, 0, 0);
    const kst = new Date(now.getTime() + 9 * 60 * 60 * 1000);
const formatted = kst.toISOString().slice(0, 23).replace('T', ' ');

    const pool = await poolConnect;
    await pool.request().query(`
      UPDATE CctvStatus
      SET LastRecorded = '${formatted}'
    `);
    console.log(`✅ LastRecorded 업데이트 완료: ${formatted}`);
  } catch (err) {
    console.error('❌ LastRecorded 업데이트 실패:', err);
  }

  // 3. PM2 재시작


    exec('pm2 restart cctv-server', (error1, stdout1, stderr1) => {
      if (error1) {
        console.error('❌ cctv-server 재시작 실패:', stderr1);
      } else {
        console.log('✅ cctv-server 재시작 완료:', stdout1);
      }
    });

    // 🔹 새 스케줄 (매일 07:00 motion-server 재시작)
schedule.scheduleJob('0 7 * * *', () => {
  console.log('⏰ [스케줄러] 매일 07:00 - motion-server 재시작');
  exec('pm2 restart motion-server', (error, stdout, stderr) => {
    if (error) {
      console.error('❌ motion-server 재시작 실패:', stderr);
    } else {
      console.log('✅ motion-server 재시작 완료:', stdout);
    }
  });
});
  
});