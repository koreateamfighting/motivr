import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iot_dashboard/model/alarm_history_model.dart';

class AlarmHistoryController {
  static const String baseUrl = 'https://hanlimtwin.kr:3030/api';

  // ✅ 알람 히스토리 추가 또는 수정
  static Future<bool> upsertAlarm(AlarmHistory alarm) async {
    final response = await http.post(
      Uri.parse('$baseUrl/alarmhistory'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(alarm.toJson()),
    );

    if (response.statusCode == 200) {
      print('✅ 알람 업서트 성공: ${response.body}');
      return true;
    } else {
      print('⚠️ 알람 업서트 실패: ${response.body}');
      return false;
    }
  }

  // ✅ 알람 히스토리 조회 (최신 100개)
  static Future<List<AlarmHistory>> fetchAlarmHistory() async {
    final response = await http.get(Uri.parse('$baseUrl/alarmhistory'));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> records = decoded['data'];
      return records.map((e) => AlarmHistory.fromJson(e)).toList();
    } else {
      throw Exception('알람 히스토리 조회 실패: ${response.body}');
    }
  }
}
