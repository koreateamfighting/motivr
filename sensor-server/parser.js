
const { DateTime } = require('luxon');
const nowKST = DateTime.now().setZone('Asia/Seoul').toJSDate();
function parseHexData(hex, group, number) {
    console.log('📩 [parseHexData] 호출됨');
    console.log('  └ hex:', hex);
  
    const parsed = {
      RID: `${group}${number}`,
      SensorType: null,
      EventType: null,
      X_Deg: null,
      Y_Deg: null,
      Z_Deg: null,
      X_MM: null,
      Y_MM: null,
      Z_MM: null,      
      Latitude: null,
      Longitude: null,
      BatteryLevel: null,
      BatteryVoltage: null,
      CreateAt: DateTime.now().setZone('Asia/Seoul').toISO(),
    };
  
    // 기본 정보
    const sensorTypeId = hex.slice(8, 10); // 센서 종류 ID

    const sensorTypeMap = {
      '01': '위험알리미S+',
      '02': '위험알리미G',
      '03': '위험알리미G+',
      '04': '체결지키미(+)',
      '05': '위험알리미C+',
      '06': '위험알리미Dx',
      'C8': '스마트폰App',
    }; //센서 타입 매핑
    
    const type = hex.slice(12, 14);        // 데이터 종류
    const d0 = hex.slice(14, 16);          // D0 상태값
    


    parsed.SensorType =  sensorTypeMap[sensorTypeId] || `Unknown(${sensorTypeId})`;
    
  
    // 🛰️ GPS 데이터
    if (type === '05') {
      parsed.EventType = 5;
  
      const latRaw = hex.slice(14, 24);
      const lonRaw = hex.slice(24, 34);
      console.log('📍 GPS → latRaw:', latRaw, 'lonRaw:', lonRaw);
  
      const parseGps = (str) => {
        const decimal = str.slice(0, 3);
        const fraction = str.slice(3);
        return parseFloat(`${decimal}.${fraction}`);
      };
  
      parsed.Latitude = parseGps(latRaw);
      parsed.Longitude = parseGps(lonRaw);
  
      console.log('📍 위도:', parsed.Latitude, '경도:', parsed.Longitude);
    }
  
    // ⚙️ 주기 or 알림 데이터
    else if (type === '02' || type === '04') {
      const eventTypeCode = hex.slice(14, 16).toUpperCase(); // D0
      const eventTypeMap = {
        'E1': '안전고리 미체결',
        'E0': '안전고리 체결',
        'E2': '작업구역 진입',
        'E3': '작업구역 진출',
        '00': 'Don\'t Care',
        '43': '붕괴주의',
        '44': '붕괴경고',
        '45': '복합주의',
        '46': '시계열주의'
      };
      parsed.EventType = eventTypeMap[eventTypeCode] || `Unknown(${eventTypeCode})`;
  
      if (['E1', 'E0', 'E2', 'E3'].includes(d0.toUpperCase())) {
        // 🔹 상태 알림 이벤트
        parsed.EventType = d0;
        const batteryRaw = hex.slice(16, 18); // D1
        parsed.BatteryVoltage = parseInt(batteryRaw, 16) / 10.0;
        console.log('🔋 상태 이벤트 배터리:', parsed.BatteryVoltage);
      } else {
        // 🔹 각도 + 배터리
        const parseAngle = (msb, lsb) => {
          const msbVal = parseInt(msb, 16);
          const lsbVal = parseInt(lsb, 16);
          const sign = (msbVal & 0x80) ? -1 : 1;
          const angleInt = ((msbVal & 0x7F) << 4) | (lsbVal >> 4);
          const angleDecimal = (lsbVal & 0x0F) / 10;
          return sign * (angleInt + angleDecimal);
        };
  
        const x = parseAngle(hex.slice(16, 18), hex.slice(18, 20)); // D1-D2
        const y = parseAngle(hex.slice(20, 22), hex.slice(22, 24)); // D3-D4
        const z = parseAngle(hex.slice(24, 26), hex.slice(26, 28)); // D5-D6
  
        const batt = hex.slice(28, 30); // D7

        parsed.X_Deg = x;
        parsed.Y_Deg = y;
        parsed.Z_Deg = z;
   
        const battInt = parseInt(batt[0], 16);
        const battDec = parseInt(batt[1], 16);
        parsed.BatteryVoltage = `${battInt}.${battDec}V`; // 문자열로 저장
        
        console.log(`📐 각도 → X: ${x}, Y: ${y}, Z: ${z}`);
        console.log(`🔋 배터리: ${parsed.BatteryVoltage}`);
        
      }
    }
  
    return parsed;
  }
  
  module.exports = { parseHexData };
  

