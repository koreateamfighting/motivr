import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iot_dashboard/state/alarm_history_state.dart';
import 'package:iot_dashboard/model/alarm_history_model.dart';

class AlarmHistoryController {
  static const String baseUrl = 'https://hanlimtwin.kr:3030/api';


// ✅ IoT 알람 히스토리 저장 (Label + RID 조합)
  static Future<bool> insertIotAlarm({
    required String rid,
    required String label,
    required DateTime timestamp,
    required String event,
    required String log,
    double? latitude,
    double? longitude,
  }) async {
    final url = Uri.parse('$baseUrl/alarmhistory/iot');

    final body = {
      'DeviceID': rid,
      'Label': label,
      'Timestamp': timestamp.toIso8601String(),
      'Event': event,
      'Log': log,
      'Latitude': latitude,
      'Longitude': longitude,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('✅ IoT 알람 저장 성공');
        return true;
      } else {
        print('⚠️ IoT 알람 저장 실패: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ IoT 알람 저장 예외 발생: $e');
      return false;
    }
  }

// ✅ CCTV 알람 히스토리 저장
  static Future<bool> insertCctvAlarm({
    required String deviceId,
    required DateTime timestamp,
    required String event,
    required String log,
    required String location,
  }) async {
    final url = Uri.parse('$baseUrl/alarmhistory/cctv');

    final body = {
      'DeviceID': deviceId,
      'Timestamp': timestamp.toIso8601String(),
      'Event': event,
      'Log': log,
      'Location': location,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('✅ CCTV 알람 저장 성공');
        return true;
      } else {
        print('⚠️ CCTV 알람 저장 실패: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ CCTV 알람 저장 예외 발생: $e');
      return false;
    }
  }

  // ✅ 알람 히스토리 조회 - IOT 전용
  static Future<List<AlarmHistory>> fetchIotAlarmHistory() async {
    final response = await http.get(Uri.parse('$baseUrl/alarmhistory/iot'));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> records = decoded['data'];
      return records.map((e) => AlarmHistory.fromJson(e)).toList();
    } else {
      throw Exception('IOT 알람 히스토리 조회 실패: ${response.body}');
    }
  }

  // ✅ 알람 히스토리 조회 - CCTV 전용
  static Future<List<AlarmHistory>> fetchCctvAlarmHistory() async {
    final response = await http.get(Uri.parse('$baseUrl/alarmhistory/cctv'));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> records = decoded['data'];
      return records.map((e) => AlarmHistory.fromJson(e)).toList();
    } else {
      throw Exception('CCTV 알람 히스토리 조회 실패: ${response.body}');
    }
  }// 알람 수정
  static Future<bool> updateAlarms(List<AlarmHistory> alarms) async {
    final url = Uri.parse('$baseUrl/alarmhistory/update');

    final body = alarms.map((a) => {
      'Id': a.id,
      'Timestamp': a.timestamp.toIso8601String(),
      'Event': a.event,
      'Log': a.log ?? '',
    }).toList();

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('✅ 알람 수정 성공');
        return true;
      } else {
        print('⚠️ 알람 수정 실패: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ 알람 수정 예외 발생: $e');
      return false;
    }
  }

// 알람 삭제
  static Future<bool> deleteAlarms(List<int> ids) async {
    final url = Uri.parse('$baseUrl/alarmhistory/delete');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'ids': ids}),
      );

      if (response.statusCode == 200) {
        print('✅ 알람 삭제 성공');
        return true;
      } else {
        print('⚠️ 알람 삭제 실패: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ 알람 삭제 예외 발생: $e');
      return false;
    }
  }


  // ✅ CCTV 로그 저장용 API 호출
  static Future<bool> logCctvStatus({
    required String camId,
    required bool isConnected,
    AlarmHistoryState? alarmState, // 💡 optional 전달
  }) async {
    final url = Uri.parse('$baseUrl/alarmhistory/cctvlog');

    final body = {
      'camId': camId,
      'isConnected': isConnected,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('✅ CCTV 로그 저장 성공: ${response.body}');
        return true;
      } else {
        print('⚠️ CCTV 로그 저장 실패: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ CCTV 로그 저장 예외 발생: $e');
      return false;
    }
  }
  // ✅ 각 DeviceID별 최신 CCTV 알람 조회
  static Future<List<AlarmHistory>> fetchLatestCctvLogs() async {
    final url = Uri.parse('$baseUrl/alarmhistory/cctv/latest');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> records = decoded['data'];


        return records.map((e) {
          final parsed = AlarmHistory.fromJson(e);

          return parsed;
        }).toList();
      } else {
        print('⚠️ 최신 CCTV 알람 조회 실패: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ 최신 CCTV 알람 조회 예외 발생: $e');
      return [];
    }
  }





}
