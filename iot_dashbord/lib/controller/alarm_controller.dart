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
}
