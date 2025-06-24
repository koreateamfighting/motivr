import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/alarm_model.dart';

class AlarmController {
  static const String _baseUrl = 'https://hanlimtwin.kr:3030/api';

  static Future<List<Alarm>> fetchAlarms() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/alarms'))
          .timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Alarm.fromJson(json)).toList();
      } else {
        throw Exception('서버 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      // 재시도
      try {
        await Future.delayed(Duration(milliseconds: 500));
        final retryResponse = await http
            .get(Uri.parse('$_baseUrl/alarms'))
            .timeout(Duration(seconds: 5));
        if (retryResponse.statusCode == 200) {
          final List<dynamic> jsonList = json.decode(retryResponse.body);
          return jsonList.map((json) => Alarm.fromJson(json)).toList();
        } else {
          throw Exception('재시도 실패: ${retryResponse.statusCode}');
        }
      } catch (retryError) {
        throw Exception('알람 데이터를 불러오는 데 실패했습니다.\n원인: $retryError');
      }
    }
  }

  static Future<bool> addAlarm({
    required DateTime timestamp,
    required String level,
    required String message,
    String? sensorId, // ← optional
  }) async {
    final url = Uri.parse('$_baseUrl/alarms');

    final body = jsonEncode({
      'timestamp': timestamp.toIso8601String().substring(0, 16).replaceFirst('T', ' '),
      'level': level,
      'message': message,
      if (sensorId != null) 'sensor_id': sensorId,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    return response.statusCode == 200;
  }

}
