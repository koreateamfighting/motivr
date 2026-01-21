// routes/cctv/video.js
const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');
const axios = require('axios');
const { getCamerasFromDb } = require('./util');
const express = require('express');
const router = express.Router(); // ✅ 추가


const ffmpegProcesses = {};
const restarting = {}; // 중복 재시작 방지
async function startHlsProcess(cam) {
  try {
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
    fs.mkdirSync(outputDir, { recursive: true });

    const outputPath = path.join(outputDir, `${cam}.m3u8`);
    const rtspUrl = camInfo.rtsp;

    if (!rtspUrl) {
      console.error(`❌ ${cam}의 RTSP URL이 설정되지 않았습니다.`);
      return;
    }

    console.log(`🎬 [${cam}] HLS 스트림 시작`);

    const ffmpeg = spawn('ffmpeg', [
      '-loglevel', 'warning',           // ✅ 로그량 줄이기(중요)
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
    ], { windowsHide: true });

    ffmpegProcesses[cam] = ffmpeg;

    ffmpeg.stderr.on('data', (data) => {
      const msg = data.toString();
      // ✅ 진짜 에러성 메시지만 남기고 싶으면 필터
      if (msg.includes('error') || msg.includes('Invalid') || msg.includes('Connection')) {
        console.error(`[${cam}] ffmpeg: ${msg.trim()}`);
      }
    });

    ffmpeg.on('error', (err) => {
      console.error(`[${cam}] ffmpeg spawn error:`, err);
      cleanupAndRestart(cam, 'spawn-error');
    });

    ffmpeg.on('close', (code, signal) => {
      console.warn(`📴 [${cam}] ffmpeg 종료 (code:${code}, signal:${signal})`);
      cleanupAndRestart(cam, `close-${code}`);
    });

  } catch (e) {
    // ✅ 여기서 잡아야 unhandled rejection 방지
    console.error(`[${cam}] startHlsProcess 실패:`, e);
    // DB가 잠깐 죽었을 수도 있으니 재시도
    setTimeout(() => startHlsProcess(cam), 3000);
  }
}

function cleanupAndRestart(cam, reason) {
  if (ffmpegProcesses[cam]) {
    delete ffmpegProcesses[cam];
  }
  if (restarting[cam]) return; // 중복 방지
  restarting[cam] = true;

  console.log(`🔁 [${cam}] 재시작 예약 (${reason})`);
  setTimeout(() => {
    restarting[cam] = false;
    startHlsProcess(cam);
  }, 3000);
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