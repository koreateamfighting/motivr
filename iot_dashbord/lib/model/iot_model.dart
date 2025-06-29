import 'package:intl/intl.dart';

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

  IotItem copyWith({
    String? id,
    String? sensortype,
    String? eventtype,
    String? latitude,
    String? longitude,
    String? battery,
    String? X_MM,
    String? Y_MM,
    String? Z_MM,
    String? X_Deg,
    String? Y_Deg,
    String? Z_Deg,
    String? batteryInfo,
    String? download,
    String? createAt,
  }) {
    return IotItem(
      id: id ?? this.id,
      sensortype: sensortype ?? this.sensortype,
      eventtype: eventtype ?? this.eventtype,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      battery: battery ?? this.battery,
      X_MM: X_MM ?? this.X_MM,
      Y_MM: Y_MM ?? this.Y_MM,
      Z_MM: Z_MM ?? this.Z_MM,
      X_Deg: X_Deg ?? this.X_Deg,
      Y_Deg: Y_Deg ?? this.Y_Deg,
      Z_Deg: Z_Deg ?? this.Z_Deg,
      batteryInfo: batteryInfo ?? this.batteryInfo,
      download: download ?? this.download,
      createAt: createAt ?? this.createAt,
    );
  }



  factory IotItem.fromJson(Map<String, dynamic> json) {
    // 🔧 RID 포맷 보정 (S1_1 → S1_001)
    String rawId = json['RID']?.toString() ?? '';
    String paddedId = rawId;
    if (rawId.startsWith('S1_')) {
      final suffix = rawId.substring(3);
      if (int.tryParse(suffix) != null) {
        paddedId = 'S1_${suffix.padLeft(3, '0')}';
      }
    }

    // 🕒 CreateAt 포맷 보정
    final rawTime = json['CreateAt']?.toString() ?? '';
    String formattedTime = rawTime;
    try {
      final dt = DateTime.parse(rawTime).toLocal();
      formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(dt);
    } catch (e) {
      formattedTime = rawTime;
    }

    return IotItem(
      id: paddedId,
      sensortype: json['SensorType']?.toString() ?? '',
      eventtype: json['EventType']?.toString() ?? '',
      latitude: json['Latitude']?.toString() ?? '',
      longitude: json['Longitude']?.toString() ?? '',
      battery: json['BatteryVoltage']?.toString() ?? '',
      X_MM: json['X_MM']?.toString() ?? '',
      Y_MM: json['Y_MM']?.toString() ?? '',
      Z_MM: json['Z_MM']?.toString() ?? '',
      X_Deg: json['X_Deg']?.toString() ?? '',
      Y_Deg: json['Y_Deg']?.toString() ?? '',
      Z_Deg: json['Z_Deg']?.toString() ?? '',
      batteryInfo: json['BatteryLevel']?.toString() ?? '',
      download: '',
      createAt: formattedTime,
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

    // ✅ 시간 문자열이 있을 경우만 포함
    if (createAt.isNotEmpty) {
      json['CreateAt'] = createAt;
    }

    return json;
  }
}
