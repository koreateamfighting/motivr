// routes/cctv/onvif.js
const express = require('express');
const Onvif = require('node-onvif');
const { getCamerasFromDb } = require('./database');

const router = express.Router();

// ONVIF 탐색
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

// 특정 카메라의 ONVIF 정보 가져오기
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

module.exports = router;