// routes/cctv/video.js
const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');
const axios = require('axios');
const { getCamerasFromDb } = require('./util');
const express = require('express');
const router = express.Router(); // ✅ 추가


const ffmpegProcesses = {};

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

  const outputDir = path.join(__dirname, '../..', 'public', 'hls');
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

    '-an',
    '-c:v', 'libx264',
    '-preset', 'ultrafast',
    '-tune', 'zerolatency',
    '-f', 'hls',
    '-hls_time', '2',
    '-hls_list_size', '6',
    '-hls_flags', 'delete_segments+omit_endlist',
    '-hls_delete_threshold', '1',
    outputPath,
  ]);
// const ffmpeg = spawn('ffmpeg', [
//     '-rtsp_transport', 'tcp',
//     '-fflags', 'nobuffer',
//     '-flags', 'low_delay',
//     '-max_delay', '500000',
//     '-i', rtspUrl,
//     '-an', // 오디오 제거
//     '-c:v', 'libx264',
//     '-preset', 'ultrafast', // veryfast → ultrafast (속도 우선)
//     '-tune', 'zerolatency',
//     '-g', '10',               // GOP = FPS = 10 (카메라 기준 맞추기)
//     '-keyint_min', '10',      // 최소 키프레임 간격도 동일하게
//     '-sc_threshold', '0',
//     '-force_key_frames', 'expr:gte(t,n_forced*1)',
//     '-f', 'hls',
//     '-hls_time', '1',
//     '-hls_list_size', '5',    // 4보다 조금 넉넉하게
//     '-hls_flags', 'program_date_time+delete_segments+omit_endlist',
//     '-hls_allow_cache', '0',
//     '-hls_delete_threshold', '1',
//     outputPath,
//   ]);
  
  
  
  
  ffmpeg.stderr.on('data', data => {
    console.error(`[${cam}] ★ ffmpeg stderr: ${data}`);
  });

  ffmpeg.on('close', code => {
    console.log(`📴 [${cam}] ffmpeg 종료 (code: ${code})`);
    delete ffmpegProcesses[cam];
  });

  ffmpegProcesses[cam] = ffmpeg;
}

function stopHlsProcess(cam) {
  const proc = ffmpegProcesses[cam];
  if (!proc) return false;

  proc.kill('SIGKILL');
  delete ffmpegProcesses[cam];
  return true;
}

function stopAllHlsProcesses() {
  Object.entries(ffmpegProcesses).forEach(([cam, proc]) => {
    proc.kill('SIGKILL');
    console.log(`🛑 ${cam} 종료됨`);
  });
  Object.keys(ffmpegProcesses).forEach(cam => delete ffmpegProcesses[cam]);
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

module.exports = {
   
  startHlsProcess,
  stopHlsProcess,
  stopAllHlsProcesses,
  startMotionDetect,
};