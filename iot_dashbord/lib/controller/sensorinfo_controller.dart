import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:iot_dashboard/model/sensorinfo_model.dart';
import 'package:iot_dashboard/constants/global_constants.dart';

/// SenSorInfo CRUD 컨트롤러 (alarmhistory 스타일과 동일한 정적 메서드 구성)
class SensorInfoController {
  static String get _base => '$baseUrl3030/api';

  /// 전체 조회 (최신순)
  static Future<List<SensorInfo>> fetchAll() async {
    final res = await http.get(Uri.parse('$_base/sensorinfo'));
    if (res.statusCode != 200) {
      throw Exception('SensorInfo 목록 조회 실패 (${res.statusCode})');
    }
    final decoded = jsonDecode(res.body);
    final List list = decoded['data'] ?? [];
    return list.map((e) => SensorInfo.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// 단건 조회 (RID)
  static Future<SensorInfo?> fetchByRid(String rid) async {
    final res = await http.get(Uri.parse('$_base/sensorinfo/$rid'));
    if (res.statusCode == 404) return null;
    if (res.statusCode != 200) {
      throw Exception('SensorInfo 단건 조회 실패 (${res.statusCode})');
    }
    final decoded = jsonDecode(res.body);
    return SensorInfo.fromJson(decoded['data'] as Map<String, dynamic>);
  }

  /// 행 추가 (INSERT)
  /// - 서버는 중복 RID면 409 반환
  static Future<SensorInfo> create({
    required String rid,
    String? label,
    double? latitude,
    double? longitude,
    String? location,
    String? sensorType,
    String? eventType,
    DateTime? createAt,
  }) async {
    final body = <String, dynamic>{
      'RID': rid,
      if (label != null) 'Label': label,
      if (latitude != null) 'Latitude': latitude,
      if (longitude != null) 'Longitude': longitude,
      if (location != null) 'Location': location,
      if (sensorType != null) 'SensorType': sensorType,
      if (eventType != null) 'EventType': eventType,
      if (createAt != null) 'CreateAt': createAt.toIso8601String(),
    };

    final res = await http.post(
      Uri.parse('$_base/sensorinfo'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (res.statusCode == 409) {
      throw Exception('이미 존재하는 RID입니다.');
    }
    if (res.statusCode != 200) {
      throw Exception('SensorInfo 생성 실패 (${res.statusCode})');
    }

    final decoded = jsonDecode(res.body);
    return SensorInfo.fromJson(decoded['data'] as Map<String, dynamic>);
  }

  /// 부분 업데이트 (PUT /sensorinfo/:rid)
  /// - 전달한 필드만 갱신 (COALESCE)
  static Future<SensorInfo> updateByRid(
      String rid, {
        String? label,
        double? latitude,
        double? longitude,
        String? location,
        String? sensorType,
        String? eventType,
        DateTime? createAt,
      }) async {
    final body = <String, dynamic>{
      // 보낸 키만 서버에서 COALESCE로 업데이트됨
      if (label != null) 'Label': label,
      if (latitude != null) 'Latitude': latitude,
      if (longitude != null) 'Longitude': longitude,
      if (location != null) 'Location': location,
      if (sensorType != null) 'SensorType': sensorType,
      if (eventType != null) 'EventType': eventType,
      if (createAt != null) 'CreateAt': createAt.toIso8601String(),
    };

    final res = await http.put(
      Uri.parse('$_base/sensorinfo/$rid'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (res.statusCode == 404) {
      throw Exception('수정 대상 RID가 없습니다.');
    }
    if (res.statusCode != 200) {
      throw Exception('SensorInfo 수정 실패 (${res.statusCode})');
    }

    final decoded = jsonDecode(res.body);
    return SensorInfo.fromJson(decoded['data'] as Map<String, dynamic>);
  }

  /// 삭제 (DELETE /sensorinfo/:rid)
  static Future<bool> deleteByRid(String rid) async {
    final res = await http.delete(Uri.parse('$_base/sensorinfo/$rid'));
    if (res.statusCode == 404) return false;
    if (res.statusCode != 200) {
      throw Exception('SensorInfo 삭제 실패 (${res.statusCode})');
    }
    return true;
  }
}
