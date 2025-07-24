import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class IotItem {
  final String? indexKey;
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
  final DateTime createAt;
  final String label;

  IotItem({
    this.indexKey,
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
    required this.label
  });

  IotItem copyWith({
    String? indexKey,
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
    DateTime? createAt,
    String? label,

  }) {
    return IotItem(
      indexKey: indexKey?? this.indexKey,
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
      label: label ?? this.label,
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

    final rawTime = json['CreateAt']?.toString() ?? '';
    DateTime parsedTime = DateTime.now();
    try {
      final trimmed = rawTime.replaceFirst('Z', '');
      parsedTime = DateTime.parse(trimmed).toLocal(); // ✅ UTC → KST 변환
    } catch (e) {
      debugPrint('❌ [IotItem.fromJson] 시간 파싱 실패: $rawTime, 에러: $e');
    }


    final item = IotItem(
      indexKey: json['IndexKey']?.toString() ?? '',
      label : json['Label']?.toString() ?? '',
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
      createAt: parsedTime,

    );
    // // ✅ 상세 로그
    // debugPrint('📥 [fromJson] RID=$paddedId, IndexKey=${item.indexKey}, X_MM=${item.X_MM}, Y_MM=${item.Y_MM}, Z_MM=${item.Z_MM}, '
    //     'X_Deg=${item.X_Deg}, Y_Deg=${item.Y_Deg}, Z_Deg=${item.Z_Deg}');

    return item;
  }






  Map<String, dynamic> toJson() {
    String eventtypeCode;
    switch (eventtype) {
      case '주기데이터':
        eventtypeCode = '2';
        break;
      case '주의':
        eventtypeCode = '67';
        break;
      case '경고':
        eventtypeCode = '68';
        break;
      case 'GPS':
        eventtypeCode = '5';
        break;
      default:
        eventtypeCode = eventtype; // 이미 숫자인 경우 유지
    }


    final Map<String, dynamic> json = {
      'IndexKey': indexKey,
      'RID': id,
      'SensorType': sensortype,
      'EventType': eventtypeCode,
      'BatteryVoltage': double.tryParse(battery) ?? 0.0,
      'BatteryLevel': double.tryParse(batteryInfo) ?? 0.0,
      'X_Deg': double.tryParse(X_Deg?.trim() ?? '') ?? 0.0,
      'Y_Deg': double.tryParse(Y_Deg?.trim() ?? '') ?? 0.0,
      'Z_Deg': double.tryParse(Z_Deg?.trim() ?? '') ?? 0.0,

      'X_MM': double.tryParse(X_MM?.trim() ?? '') ?? 0.0,
      'Y_MM': double.tryParse(Y_MM?.trim() ?? '') ?? 0.0,
      'Z_MM': double.tryParse(Z_MM?.trim() ?? '') ?? 0.0,

      'Label': label,
      'CreateAt': createAt.toIso8601String(),

// → 예: "2025-07-23T22:09:00Z"



    };

    // 위도, 경도는 비어있지 않은 경우에만 포함
    if (latitude.trim().isNotEmpty) {
      json['Latitude'] = double.tryParse(latitude);
    }
    if (longitude.trim().isNotEmpty) {
      json['Longitude'] = double.tryParse(longitude);
    }



    return json;
  }
}
