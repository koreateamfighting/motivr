class IotItem {
  final String id;
  final String type;
  final String location;
  final String status;
  final String battery;        // → BatteryVoltage
  final String lastUpdated;
  final String X_MM;
  final String Y_MM;
  final String Z_MM;
  final String X_Deg;
  final String Y_Deg;
  final String Z_Deg;
  final String batteryInfo;    // → BatteryLevel
  final String download;

  IotItem({
    required this.id,
    required this.type,
    required this.location,
    required this.status,
    required this.battery,
    required this.lastUpdated,
    required this.X_MM,
    required this.Y_MM,
    required this.Z_MM,
    required this.X_Deg,
    required this.Y_Deg,
    required this.Z_Deg,
    required this.batteryInfo,
    required this.download,
  });

  /// ✅ 클라이언트 ↔ Flutter 내부용 JSON 변환
  factory IotItem.fromJson(Map<String, dynamic> json) {
    return IotItem(
      id: json['id'],
      type: json['type'],
      location: json['location'],
      status: json['status'],
      battery: json['battery'],
      lastUpdated: json['lastUpdated'],
      X_MM: json['X(mm)'].toString(),
      Y_MM: json['Y(mm)'].toString(),
      Z_MM: json['Z(mm)'].toString(),
      X_Deg: json['X_Deg'].toString(),
      Y_Deg: json['Y_Deg'].toString(),
      Z_Deg: json['Z_Deg'].toString(),
      batteryInfo: json['batteryInfo'],
      download: json['download'],
    );
  }

  /// ✅ 서버 전송용 JSON 변환 (필드명 매핑)
  Map<String, dynamic> toJson() {
    return {
      'RID': id,
      'SensorType': type,
      'EventType': status,
      'Location': location,
      'BatteryVoltage': double.tryParse(battery) ?? 0.0,
      'BatteryLevel': double.tryParse(batteryInfo) ?? 0.0,
      'X_Deg': double.tryParse(X_Deg) ?? 0.0,
      'Y_Deg': double.tryParse(Y_Deg) ?? 0.0,
      'Z_Deg': double.tryParse(Z_Deg) ?? 0.0,
      'X_MM': double.tryParse(X_MM) ?? 0.0,
      'Y_MM': double.tryParse(Y_MM) ?? 0.0,
      'Z_MM': double.tryParse(Z_MM) ?? 0.0,
      'Latitude': 0.0,     // 필요 시 별도 필드로 추가
      'Longitude': 0.0,    // 필요 시 별도 필드로 추가
    };
  }
}
