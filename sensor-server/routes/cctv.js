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
    // 입력 (RTSP)
    '-rtsp_transport', 'tcp',
    '-rtsp_flags', 'prefer_tcp',
    '-buffer_size', '1024000',
    '-i', rtspUrl,
    // 인코딩
    '-c:v', 'libx264',
    '-preset', 'ultrafast',
    '-tune', 'zerolatency',
    '-b:v', '1500k',                      // 비트레이트 고정
    '-maxrate', '1500k',
    '-bufsize', '3000k',
    '-g', '50',                           // 키프레임 간격
    '-keyint_min', '50',
    '-sc_threshold', '0',
    '-an',                                // 오디오 제거
    '-vsync', 'cfr',                      // 프레임 동기화
    '-max_muxing_queue_size', '1024',
    // HLS
    '-f', 'hls',
    '-hls_time', '2',
    '-hls_list_size', '6',
    '-hls_flags', 'delete_segments+omit_endlist',
    '-start_number', '1',
    outputPath,
  ]);

  ffmpeg.stderr.on('data', data => {
    const msg = data.toString();
    // 일반적인 디코딩 경고는 무시, 심각한 오류만 로깅
    if (!msg.includes('error while decoding') && !msg.includes('left block unavailable')) {
      console.error(`[${cam}] ffmpeg: ${msg}`);
    }
  });

  ffmpeg.on('close', (code, signal) => {
    console.log(`📴 [${cam}] ffmpeg 종료 (code:${code}, signal:${signal})`);
    delete ffmpegProcesses[cam];

    // 비정상 종료 시 자동 재시작 (최대 3회)
    if (code !== 0 && signal !== 'SIGKILL') {
      const restartKey = `restart_${cam}`;
      const restartCount = (global[restartKey] || 0) + 1;
      global[restartKey] = restartCount;

      if (restartCount <= 3) {
        console.log(`🔄 [${cam}] 재시작 예약 (${restartCount}/3)...`);
        setTimeout(() => startHlsProcess(cam), 3000);
      } else {
        console.error(`❌ [${cam}] 재시작 3회 실패, 수동 확인 필요`);
        // 10분 후 카운터 리셋
        setTimeout(() => { global[restartKey] = 0; }, 600000);
      }
    } else {
      // 정상 종료 시 카운터 리셋
      global[`restart_${cam}`] = 0;
    }
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
    }, { timeout: 5000 });
    console.log(`🚀 ${cam} 감지 요청 완료`);
  } catch (err) {
    // motion-server가 실행 중이 아닐 때는 경고만 출력
    if (err.code === 'ECONNREFUSED') {
      console.warn(`⚠️ [${cam}] motion-server 미실행 (5001 포트)`);
    } else {
      console.error(`❌ ${cam} 감지 요청 실패: ${err.message}`);
    }
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


// CCTV 스트림 전체 재시작 함수
async function restartAllHlsStreams() {
  console.log('🔄 [CCTV 재시작] 모든 HLS 스트림 재시작 시작...');

  // 1. 기존 ffmpeg 프로세스 모두 종료
  const runningCams = Object.keys(ffmpegProcesses);
  console.log(`📋 현재 실행 중인 카메라: ${runningCams.length}개 - [${runningCams.join(', ')}]`);

  for (const cam of runningCams) {
    const proc = ffmpegProcesses[cam];
    if (proc) {
      proc.kill('SIGKILL');
      console.log(`🛑 [${cam}] ffmpeg 종료`);
      delete ffmpegProcesses[cam];
    }
  }

  // 2. 잠시 대기 (프로세스 정리 시간)
  await new Promise(resolve => setTimeout(resolve, 2000));

  // 3. DB에서 활성 카메라 목록 가져오기
  try {
    const cams = await getCamerasFromDb();
    const camIds = Object.keys(cams);
    console.log(`📷 DB에서 가져온 카메라: ${camIds.length}개 - [${camIds.join(', ')}]`);

    // 4. 각 카메라에 대해 HLS 스트림 재시작
    for (const camId of camIds) {
      await startHlsProcess(camId);
      await startMotionDetect(camId);
      // 각 카메라 시작 간 약간의 딜레이
      await new Promise(resolve => setTimeout(resolve, 1000));
    }

    console.log('✅ [CCTV 재시작] 모든 HLS 스트림 재시작 완료');
  } catch (err) {
    console.error('❌ [CCTV 재시작] 카메라 목록 조회 실패:', err);
  }
}

// 수동으로 모든 CCTV 재시작하는 API
router.get('/restart-all', async (req, res) => {
  console.log('🔄 [API] 수동 CCTV 전체 재시작 요청');
  try {
    await restartAllHlsStreams();
    res.json({ success: true, message: '모든 CCTV 스트림 재시작 완료' });
  } catch (err) {
    console.error('❌ 재시작 실패:', err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// 현재 실행 중인 스트림 상태 확인 API
router.get('/status', (req, res) => {
  const runningCams = Object.keys(ffmpegProcesses);
  res.json({
    running: runningCams.length,
    cameras: runningCams,
  });
});

// ✅ export
module.exports = {
  router,
  startHlsProcess,
  startMotionDetect,
  restartAllHlsStreams,
};


// 매일 AM 6:56 (한국시간) CCTV 전체 재시작 스케줄러
schedule.scheduleJob('56 6 * * *', async () => {
  console.log('⏰ [스케줄러] 6시 56분 - CCTV 재시작 및 정리 작업 시작');

  // 1. 기존 ffmpeg 프로세스 모두 종료
  console.log('🛑 [1단계] 기존 ffmpeg 프로세스 종료...');
  for (const cam of Object.keys(ffmpegProcesses)) {
    const proc = ffmpegProcesses[cam];
    if (proc) {
      proc.kill('SIGKILL');
      console.log(`   - ${cam} 종료됨`);
      delete ffmpegProcesses[cam];
    }
  }

  // 2. .ts, .m3u8 파일 삭제 (깨끗하게 정리)
  console.log('🧹 [2단계] HLS 파일 정리...');
  fs.readdir(hlsFolder, (err, files) => {
    if (err) {
      console.error('❌ 디렉토리 읽기 오류:', err);
      return;
    }

    files
      .filter(file => file.endsWith('.ts') || file.endsWith('.m3u8'))
      .forEach(file => {
        const filePath = path.join(hlsFolder, file);
        fs.unlink(filePath, err => {
          if (err) console.error(`❌ ${file} 삭제 실패:`, err);
          else console.log(`   - ${file} 삭제됨`);
        });
      });
  });

  // 3. LastRecorded 업데이트
  console.log('📝 [3단계] LastRecorded 업데이트...');
  try {
    const now = new Date();
    now.setHours(6, 56, 0, 0);
    const formatted = now.toISOString().slice(0, 23);

    const pool = await sql.connect(dbConfig);
    await pool.request().query(`
      UPDATE CctvStatus
      SET LastRecorded = '${formatted}'
    `);
    console.log(`   ✅ LastRecorded: ${formatted}`);
  } catch (err) {
    console.error('❌ LastRecorded 업데이트 실패:', err);
  }

  // 4. PM2 재시작 (motion-server)
  console.log('🔄 [4단계] PM2 서비스 재시작...');
  exec('pm2 restart motion-server', (error2, stdout2, stderr2) => {
    if (error2) {
      console.error('❌ motion-server 재시작 실패:', stderr2);
    } else {
      console.log('   ✅ motion-server 재시작 완료');
    }
  });

  // 5. 잠시 대기 후 HLS 스트림 재시작
  console.log('⏳ [5단계] 5초 대기 후 HLS 스트림 재시작...');
  setTimeout(async () => {
    try {
      const cams = await getCamerasFromDb();
      const camIds = Object.keys(cams);
      console.log(`📷 [6단계] ${camIds.length}개 카메라 HLS 스트림 시작...`);

      for (const camId of camIds) {
        await startHlsProcess(camId);
        await startMotionDetect(camId);
        await new Promise(resolve => setTimeout(resolve, 1000));
      }

      console.log('🎉 [스케줄러] 6시 56분 작업 완료!');
    } catch (err) {
      console.error('❌ HLS 스트림 재시작 실패:', err);
    }
  }, 5000);
});