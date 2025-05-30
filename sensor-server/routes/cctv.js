// routes/cctv.js
const express = require('express');
const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

const router = express.Router();
const ffmpegProcesses = {};

const camConfigs = {
  cam1: 'rtsp://admin:admin1234!@218.149.187.159:40551/unicast/c1/s0/live',
  cam2: 'rtsp://admin:admin1234!@218.149.187.159:40551/unicast/c2/s0/live',
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

// 👉 기존 API 유지
router.get('/start-hls/:cam', (req, res) => {
  const cam = req.params.cam;
  startHlsProcess(cam);
  res.send(`✅ ${cam} HLS 스트림 시작 요청됨`);
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

// ✅ export
module.exports = {
  router,
  startHlsProcess,
};
