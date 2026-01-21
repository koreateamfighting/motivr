function parseHexData(hex, group, number) {
    hex = hex.trim().toUpperCase().replace(/[^0-9A-F]/g, '');
  
    const DeviceId = parseInt(hex.slice(4, 6), 16);
    const type = hex.slice(12, 14); // 데이터 타입 (e.g. 02, 04, 05)
    const now = new Date();
  
    const result = {
      DeviceId,
      EventType: null,
      X: null,
      Y: null,
      Z: null,
      Battery: null,
      Lat: null,
      Lon: null,
      AlertType: null,
      Status: 'OK',
    };
  
    if (type === '02' || type === '04') {
      const x = parseSigned(hex.slice(14, 18)) / 10;
      const y = parseSigned(hex.slice(18, 22)) / 10;
      const z = parseSigned(hex.slice(22, 26)) / 10;
      const batteryStr = hex.slice(28, 30); // 예: "41"

      // 🔄 이걸 숫자로 변환 후 /10
      const battery = parseFloat(batteryStr) / 10; // "41" → 4.1
  
      result.X = x;
      result.Y = y;
      result.Z = z;
      result.Battery = battery;
      result.EventType = type === '04' ? 'Alert' : 'Periodic';
    } else if (type === '05') {
      result.EventType = 'GPS';
      result.Lat = parseGps(hex.slice(14, 24));
      result.Lon = parseGps(hex.slice(24, 34));
    }
  
    return result;
  }
  
  function parseSigned(hexStr) {
    const intVal = parseInt(hexStr, 16);
    return intVal >= 0x8000 ? intVal - 0x10000 : intVal;
  }
  
  function parseGps(gpsHex) {
    const [a, b, c, d, e] = [
      parseInt(gpsHex.slice(0, 2), 16),
      parseInt(gpsHex.slice(2, 4), 16),
      parseInt(gpsHex.slice(4, 6), 16),
      parseInt(gpsHex.slice(6, 8), 16),
      parseInt(gpsHex.slice(8, 10), 16),
    ];
    return a + b / 100 + c / 10000 + d / 1000000 + e / 100000000;
  }
  
  module.exports = { parseHexData };
  