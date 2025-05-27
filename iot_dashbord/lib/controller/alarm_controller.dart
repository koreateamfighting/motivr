import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/alarm_model.dart';

class AlarmController {
  static const String _baseUrl = 'https://hanlimtwin.kr:3030/api';

  static Future<List<Alarm>> fetchAlarms() async {
    final response = await http.get(Uri.parse('$_baseUrl/alarms'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Alarm.fromJson(json)).toList();
    } else {
      throw Exception('알람 데이터를 불러오는 데 실패했습니다.');
    }
  }
}
