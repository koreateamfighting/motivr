// 예시 카메라 설정 (필요에 따라 DB에서 불러오게 개선 가능)
function generateCameraConfig(camID) {
    const map = {
      cam1: {
        rtspUrl: 'rtsp://192.168.0.101:554/stream',
        onvifXaddr: 'http://192.168.0.101:8000/onvif/device_service',
        onvifUser: 'admin',
        onvifPass: '12345'
      },
      cam2: {
        rtspUrl: 'rtsp://192.168.0.102:554/stream',
        onvifXaddr: 'http://192.168.0.102:8000/onvif/device_service',
        onvifUser: 'admin',
        onvifPass: '12345'
      },
      // 추가 가능
    };
  
    return map[camID] || null;
  }
  
  // 영상 처리용 JSON 변환 예시 (선택사항)
  async function getCamerasFromDb() {
    const sql = require('mssql');
    const { poolConnect } = require('../../db');
  
    const pool = await poolConnect;
    const result = await pool.request().query('SELECT * FROM CctvStatus');
  
    const cams = {};
    for (const row of result.recordset) {
      cams[row.CamID] = {
        rtsp: row.RtspUrl,
        onvif: {
          xaddr: row.OnvifXaddr,
          user: row.OnvifUser,
          pass: row.OnvifPass
        }
      };
    }
    return cams;
  }
  
  module.exports = {
    generateCameraConfig,
    getCamerasFromDb
  };
  