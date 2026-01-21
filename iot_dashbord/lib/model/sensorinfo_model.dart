import 'package:flutter/foundation.dart';

/// SenSorInfo 테이블 모델
class SensorInfo {
  /// DB PK (uniqueidentifier) – 응답에만 존재할 수 있음
  final String? indexKey;

  /// RID (필수)
  final String rid;

  /// 센서 라벨
  final String? label;

  /// 위도/경도
  final double? latitude;
  final double? longitude;

  /// 위치(설치 지점 설명)
  final String? location;

  /// 센서 타입 / 이벤트 타입(문자열로 관리; DB가 NVARCHAR)
  final String? sensorType;
  final String? eventType;

  /// 생성 시각 (서버 응답은 ISO(+09:00), 전송시 ISO로 보냄)
  final DateTime? createAt;

  const SensorInfo({
    required this.rid,
    this.indexKey,
    this.label,
    this.latitude,
    this.longitude,
    this.location,
    this.sensorType,
    this.eventType,
    this.createAt,
  });

  /// JSON → Model
  factory SensorInfo.fromJson(Map<String, dynamic> json) {
    DateTime? created;
    try {
      final raw = json['CreateAt'];
      if (raw != null && raw.toString().isNotEmpty) {
        created = DateTime.parse(raw.toString());
      }
    } catch (_) {}

    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    return SensorInfo(
      indexKey: json['IndexKey']?.toString(),
      rid: json['RID']?.toString() ?? '',
      label: json['Label']?.toString(),
      latitude: _toDouble(json['Latitude']),
      longitude: _toDouble(json['Longitude']),
      location: json['Location']?.toString(),
      sensorType: json['SensorType']?.toString(),
      eventType: json['EventType']?.toString(),
      createAt: created,
    );
  }

  /// Model → JSON (서버가 기대하는 키로 변환)
  Map<String, dynamic> toJson() {
    return {
      'RID': rid,
      'Label': label,
      'Latitude': latitude,
      'Longitude': longitude,
      'Location': location,
      'SensorType': sensorType,
      'EventType': eventType,
      'CreateAt': createAt?.toIso8601String(),
    };
  }

  SensorInfo copyWith({
    String? indexKey,
    String? rid,
    String? label,
    double? latitude,
    double? longitude,
    String? location,
    String? sensorType,
    String? eventType,
    DateTime? createAt,
  }) {
    return SensorInfo(
      indexKey: indexKey ?? this.indexKey,
      rid: rid ?? this.rid,
      label: label ?? this.label,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      location: location ?? this.location,
      sensorType: sensorType ?? this.sensorType,
      eventType: eventType ?? this.eventType,
      createAt: createAt ?? this.createAt,
    );
  }

  @override
  String toString() =>
      'SensorInfo(rid=$rid, label=$label, lat=$latitude, lon=$longitude, eventType=$eventType)';
}
