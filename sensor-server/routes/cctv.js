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

const camConfigs = {
  cam1: 'rtsp://admin:admin1234!@218.149.187.159:40551/unicast/c1/s0/live',
  cam2: 'rtsp://admin:admin1234!@218.149.187.159:40551/unicast/c2/s0/live',
};
const camOnvifConfig = {
  cam1: {
    xaddr: 'http://218.149.187.159:40081/onvif/device_service',
    user: 'admin',
    pass: 'admin1234!'
  },
  cam2: {
    xaddr: 'http://218.149.187.159:40082/onvif/device_service',
    user: 'admin',
    pass: 'admin1234!'
  }
};


function startHlsProcess(cam) {
  if (!camConfigs[cam]) {
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
  const rtspUrl = camConfigs[cam];

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
  const streamUrl = camConfigs[cam]; // ✅ RTSP URL을 전달

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
router.get('/start-hls/:cam', (req, res) => {
  const cam = req.params.cam;
  startHlsProcess(cam);
  res.send(`✅ ${cam} HLS 스트림 시작 요청됨`);
  startMotionDetect(cam);
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
  const {
    camID,
    location,
    isConnected,
    eventState,
    imageAnalysis,
    streamUrl,
    recordPath
  } = req.body;

  if (!camID || !streamUrl) {
    return res.status(400).json({ error: 'camID와 streamUrl은 필수입니다.' });
  }

  try {
    const pool = await sql.connect(dbConfig);
    await pool.request()
      .input('CamID', sql.NVarChar, camID)
      .input('Location', sql.NVarChar, location || null)
      .input('IsConnected', sql.Bit, isConnected ?? 1)
      .input('EventState', sql.NVarChar, eventState || '정상')
      .input('ImageAnalysis', sql.Float, imageAnalysis ?? 0)
      .input('StreamURL', sql.NVarChar, streamUrl)
      .input('RecordPath', sql.NVarChar, recordPath || null)
      .query(`
        INSERT INTO CctvStatus (CamID, Location, IsConnected, EventState, ImageAnalysis, StreamURL, RecordPath)
        VALUES (@CamID, @Location, @IsConnected, @EventState, @ImageAnalysis, @StreamURL, @RecordPath)
      `);

    res.status(201).json({ message: 'CCTV 등록 완료' });
  } catch (err) {
    console.error('❌ CCTV 등록 실패:', err);
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
  const config = camOnvifConfig[cam];

  if (!config) {
    return res.status(400).json({ error: `알 수 없는 카메라 ID: ${cam}` });
  }

  try {
    const device = new Onvif.OnvifDevice({
      xaddr: config.xaddr,
      user: config.user,
      pass: config.pass
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
  exec('pm2 restart 1', (error, stdout, stderr) => {
    if (error) {
      console.error('❌ PM2 재시작 실패:', stderr);
    } else {
      console.log('✅ PM2 재시작 완료:', stdout);
    }
  });
});