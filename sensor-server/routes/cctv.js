// routes/cctv.js
const express = require('express');
const { spawn, exec } = require('child_process');
const schedule = require('node-schedule');
const path = require('path');
const fs = require('fs');
const sql = require('mssql');
const dbConfig = require('../dbConfig'); // 너가 이미 쓰고 있는 DB 설정
const Onvif = require('node-onvif');
const axios = require('axios');
const router = express.Router();
const ffmpegProcesses = {};
const hlsFolder = 'C:\\Users\\Administrator\\sensor-server\\public\\hls'; // 삭제할 .ts 파일 경로

// const camConfigs = {
//   cam1: 'rtsp://admin:admin1234!@218.149.187.159:40551/unicast/c1/s0/live',
//   cam2: 'rtsp://admin:admin1234!@218.149.187.159:40551/unicast/c2/s0/live',
// };
// const camOnvifConfig = {
//   cam1: {
//     xaddr: 'http://218.149.187.159:40081/onvif/device_service',
//     user: 'admin',
//     pass: 'admin1234!'
//   },
//   cam2: {
//     xaddr: 'http://218.149.187.159:40082/onvif/device_service',
//     user: 'admin',
//     pass: 'admin1234!'
//   }
// };


// camID 규칙에 따라 RTSP, ONVIF 기본값 자동 생성 함수
function generateCameraConfig(camID) {
  const match = camID.toLowerCase().match(/^cam(\d+)$/);
  if (!match) return null;

  const camNumber = parseInt(match[1], 10);
  const rtspBase = 'rtsp://admin:admin1234!@218.149.187.159:40551/unicast/';
  const onvifBasePort = 40080;

  return {
    rtspUrl: `${rtspBase}c${camNumber}/s0/live`,
    onvifXaddr: `http://218.149.187.159:${onvifBasePort + camNumber}/onvif/device_service`,
    onvifUser: 'admin',
    onvifPass: 'admin1234!',
  };
}



async function getCamerasFromDb() {
  const pool = await sql.connect(dbConfig);
  const result = await pool.request().query(`
    SELECT CamID, RtspUrl, OnvifXaddr, OnvifUser, OnvifPass
    FROM CctvStatus
    WHERE CamID IS NOT NULL
  `);

  // 결과를 객체로 가공 (CamID -> {rtsp, onvif 정보})
  const cams = {};
  result.recordset.forEach(row => {
    cams[row.CamID] = {
      rtsp: row.RtspUrl,
      onvif: {
        xaddr: row.OnvifXaddr,
        user: row.OnvifUser,
        pass: row.OnvifPass
      }
    };
  });

  

  return cams;
}


async function startHlsProcess(cam) {
  const cams = await getCamerasFromDb();
  const camInfo = cams[cam];


 
  if (!camInfo) {
    console.error(`❌ 유효하지 않은 카메라 ID: ${cam}`);
    return;
  }
  if (ffmpegProcesses[cam]) {
    console.log(`⚠️ ${cam} 이미 실행 중`);
    return;
  }

  const outputDir = path.join(__dirname, '..', 'public', 'hls');
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  const outputPath = path.join(outputDir, `${cam}.m3u8`);
  const rtspUrl = camInfo.rtsp;
  if (!rtspUrl) {
    console.error(`❌ ${cam}의 RTSP URL이 설정되지 않았습니다.`);
    return;
  }

  console.log(`🎬 [${cam}] HLS 스트림 시작`);
  const ffmpeg = spawn('ffmpeg', [
    '-rtsp_transport', 'tcp',
    '-i', rtspUrl,
    '-c:v', 'libx264',
    '-preset', 'ultrafast',
    '-tune', 'zerolatency',
    '-f', 'hls',
   // cctv.js 내부 spawn 옵션에서 다음처럼 수정
'-hls_time', '2',
'-hls_list_size', '6',
'-hls_flags', 'delete_segments+omit_endlist',
'-hls_delete_threshold', '1', // ⬅️ 오래된 세그먼트 즉시 삭제

    
    outputPath,
  ]);

  ffmpeg.stderr.on('data', data => {
    console.error(`[${cam}] ffmpeg stderr: ${data}`);
  });

  ffmpeg.on('close', code => {
    console.log(`📴 [${cam}] ffmpeg 종료 (code: ${code})`);
    delete ffmpegProcesses[cam];
  });

  ffmpegProcesses[cam] = ffmpeg;
}
async function startMotionDetect(cam) {
  const cams = await getCamerasFromDb();
  const camInfo = cams[cam];

  if (!camInfo) {
    console.error(`❌ 유효하지 않은 카메라 ID: ${cam}`);
    return;
  }

  const streamUrl = camInfo.rtsp;

  if (!streamUrl) {
    console.error(`❌ ${cam}의 RTSP URL이 없습니다.`);
    return;
  }

  try {
    await axios.post('http://localhost:5001/start', {
      cam_id: cam,
      url: streamUrl,
    });
    console.log(`🚀 ${cam} 감지 요청 완료`);
  } catch (err) {
    console.error(`❌ ${cam} 감지 요청 실패:`, err.message);
  }
}


// 👉 기존 API 유지
router.get('/start-hls/:cam', async (req, res) => {
  const cam = req.params.cam;
  await startHlsProcess(cam);
  res.send(`✅ ${cam} HLS 스트림 시작 요청됨`);
  await startMotionDetect(cam);
});


router.get('/stop-hls/:cam', (req, res) => {
  const cam = req.params.cam;
  const proc = ffmpegProcesses[cam];

  if (!proc) return res.status(404).send(`❌ ${cam} 스트림 없음`);

  proc.kill('SIGKILL');
  delete ffmpegProcesses[cam];
  res.send(`🛑 ${cam} 중단됨`);
});

router.get('/stop-hls/all', (req, res) => {
  Object.entries(ffmpegProcesses).forEach(([cam, proc]) => {
    proc.kill('SIGKILL');
    console.log(`🛑 ${cam} 종료됨`);
  });
  Object.keys(ffmpegProcesses).forEach(cam => delete ffmpegProcesses[cam]);
  res.send('🧹 전체 종료됨');
});

router.post('/cctvs', async (req, res) => {
  let {
    camID,
    location,
    isConnected,
    eventState,
    imageAnalysis,
    streamUrl,
    recordPath,
    rtspUrl,
    onvifXaddr,
    onvifUser,
    onvifPass,
  } = req.body;

  if (!camID) {
    return res.status(400).json({ error: 'camID는 필수입니다.' });
  }

  
  // 자동생성 로직: rtspUrl, onvifXaddr, onvifUser, onvifPass가 없으면 기본값 생성
  if (!rtspUrl || !onvifXaddr || !onvifUser || !onvifPass) {
    const generatedConfig = generateCameraConfig(camID);
    if (generatedConfig) {
      rtspUrl = rtspUrl || generatedConfig.rtspUrl;
      onvifXaddr = onvifXaddr || generatedConfig.onvifXaddr;
      onvifUser = onvifUser || generatedConfig.onvifUser;
      onvifPass = onvifPass || generatedConfig.onvifPass;
    }
  }
  

  try {
    const pool = await sql.connect(dbConfig);

    // 1) 기존 CamID 존재 여부 확인
    const checkResult = await pool.request()
      .input('CamID', sql.NVarChar, camID)
      .query('SELECT COUNT(*) AS cnt FROM CctvStatus WHERE CamID = @CamID');
    const exists = checkResult.recordset[0].cnt > 0;

    if (exists) {
      // 2) 존재하면 UPDATE
      await pool.request()
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
        .input('OnvifPass', sql.NVarChar, onvifPass || null)
        .query(`
          UPDATE CctvStatus
          SET Location = @Location,
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

      res.status(200).json({ message: 'CCTV 정보가 업데이트 되었습니다.' });
    } else {
      // 3) 없으면 INSERT
      await pool.request()
        .input('CamID', sql.NVarChar, camID)
        .input('Location', sql.NVarChar, location || null)
        .input('IsConnected', sql.Bit, isConnected ?? 1)
        .input('EventState', sql.NVarChar, eventState || '정상')
        .input('ImageAnalysis', sql.Float, imageAnalysis ?? 0)
        .input('StreamURL', sql.NVarChar, streamUrl)
        .input('RecordPath', sql.NVarChar, recordPath || null)
        .input('RtspUrl', sql.NVarChar, rtspUrl || null)
        .input('OnvifXaddr', sql.NVarChar, onvifXaddr || null)
        .input('OnvifUser', sql.NVarChar, onvifUser || null)
        .input('OnvifPass', sql.NVarChar, onvifPass || null)
        .query(`
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


router.get('/cctvs', async (req, res) => {
  try {
    const pool = await sql.connect(dbConfig);
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
router.get('/probe-onvif', async (req, res) => {
  try {
    const devices = await Onvif.startProbe();
    const infoList = devices.map(d => ({
      name: d.name,
      address: d.address,
      hardware: d.hardware,
      xaddrs: d.xaddrs
    }));
    res.json(infoList);
  } catch (err) {
    console.error('❌ ONVIF 탐색 실패:', err);
    res.status(500).json({ error: 'ONVIF 탐색 실패' });
  }
});

router.get('/fetch-onvif/:cam', async (req, res) => {
  const cam = req.params.cam;
  const cams = await getCamerasFromDb();
  const camInfo = cams[cam];

  if (!camInfo || !camInfo.onvif || !camInfo.onvif.xaddr) {
    return res.status(400).json({ error: `알 수 없는 카메라 ID 또는 ONVIF 설정이 없습니다: ${cam}` });
  }

  try {
    const device = new Onvif.OnvifDevice({
      xaddr: camInfo.onvif.xaddr,
      user: camInfo.onvif.user,
      pass: camInfo.onvif.pass
    });

    await device.init();

    const info = await device.getInformation();
    const snapshot = await device.fetchSnapshotUri();
    const streamUri = await device.getUdpStreamUrl();

    res.json({
      cam,
      deviceInfo: info,
      snapshotUri: snapshot.uri,
      streamUri
    });
  } catch (err) {
    console.error(`❌ ONVIF 정보 조회 실패 (${cam}):`, err);
    res.status(500).json({ error: `ONVIF 정보 조회 실패: ${cam}`, message: err.message });
  }
});




// ✅ export
module.exports = {
  router,
  startHlsProcess,
  startMotionDetect, // ✅ 이게 꼭 있어야 import 가능
};



schedule.scheduleJob('56 6 * * *', async () => {
  console.log('⏰ [스케줄러] 6 56분 - .ts 파일 삭제 및 PM2 재시작 시작');

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

  // 2. LastRecorded = 오늘 날짜의 06:56:00
  try {
    const now = new Date();
    now.setHours(6, 56, 0, 0);
    const formatted = now.toISOString().slice(0, 23); // 'YYYY-MM-DDTHH:MM:SS.mmm'

    const pool = await sql.connect(dbConfig);
    await pool.request().query(`
      UPDATE CctvStatus
      SET LastRecorded = '${formatted}'
    `);
    console.log(`✅ LastRecorded 업데이트 완료: ${formatted}`);
  } catch (err) {
    console.error('❌ LastRecorded 업데이트 실패:', err);
  }

  // 3. pm2 재시작
  exec('pm2 restart motion-server', (error2, stdout2, stderr2) => {
    if (error2) {
      console.error('❌ PM2 2번 재시작 실패:', stderr2);
      return;
    }
    console.log('✅ PM2 2번 재시작 완료:', stdout2);
  
    // 2번이 성공했을 때만 1번 재시작
    exec('pm2 restart cctv-server', (error1, stdout1, stderr1) => {
      if (error1) {
        console.error('❌ PM2 1번 재시작 실패:', stderr1);
      } else {
        console.log('✅ PM2 1번 재시작 완료:', stdout1);
      }
    });
  });
});