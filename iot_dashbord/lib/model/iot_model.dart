class IotItem {
  final String id;
  final String sensortype;
  final String eventtype;
  final String latitude;
  final String longitude;
  final String battery;
  final String X_MM;
  final String Y_MM;
  final String Z_MM;
  final String X_Deg;
  final String Y_Deg;
  final String Z_Deg;
  final String batteryInfo;
  final String download;
  final String createAt;

  IotItem({
    required this.id,
    required this.sensortype,
    required this.eventtype,
    required this.latitude,
    required this.longitude,
    required this.battery,
    required this.X_MM,
    required this.Y_MM,
    required this.Z_MM,
    required this.X_Deg,
    required this.Y_Deg,
    required this.Z_Deg,
    required this.batteryInfo,
    required this.download,
    required this.createAt,
  });

  factory IotItem.fromJson(Map<String, dynamic> json) {
    return IotItem(
      id: json['id'],
      sensortype: json['SensorType'],
      eventtype: json['EventType'],
      latitude: json['Latitude'], // ✅ 대소문자 일치
      longitude: json['Longitude'], // 🔧 수정 필요
      battery: json['BatteryVoltage'].toString(), // 🔧 명확하게 매핑
      X_MM: json['X_MM'].toString(),
      Y_MM: json['Y_MM'].toString(),
      Z_MM: json['Z_MM'].toString(),
      X_Deg: json['X_Deg'].toString(),
      Y_Deg: json['Y_Deg'].toString(),
      Z_Deg: json['Z_Deg'].toString(),
      batteryInfo: json['BatteryLevel'].toString(), // 🔧 명확하게 매핑
      download: json['download'] ?? '',
      createAt: json['CreateAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    String eventtypeCode;
    switch (eventtype) {
      case '주기데이터':
        eventtypeCode = '2';
        break;
      case 'Alert':
        eventtypeCode = '4';
        break;
      case 'GPS':
        eventtypeCode = '5';
        break;
      default:
        eventtypeCode = '0';
    }

    final Map<String, dynamic> json = {
      'RID': id,
      'SensorType': sensortype,
      'EventType': eventtypeCode,
      'BatteryVoltage': double.tryParse(battery) ?? 0.0,
      'BatteryLevel': double.tryParse(batteryInfo) ?? 0.0,
      'X_Deg': double.tryParse(X_Deg) ?? 0.0,
      'Y_Deg': double.tryParse(Y_Deg) ?? 0.0,
      'Z_Deg': double.tryParse(Z_Deg) ?? 0.0,
      'X_MM': double.tryParse(X_MM) ?? 0.0,
      'Y_MM': double.tryParse(Y_MM) ?? 0.0,
      'Z_MM': double.tryParse(Z_MM) ?? 0.0,
      'Latitude': double.tryParse(latitude) ?? 0.0,
      'Longitude': double.tryParse(longitude) ?? 0.0,
    };

    // ✅ 수동 시간 입력이 있을 경우만 포함
    if (createAt.isNotEmpty) {
      json['CreateAt'] = createAt;
    }

    return json;
  }

}
