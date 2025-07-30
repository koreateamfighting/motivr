import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iot_dashboard/model/duty_model.dart';
import 'package:iot_dashboard/constants/global_constants.dart';
class DutyController {

  // ✅ 가장 최근 Duty 1개 조회
  static Future<Duty?> fetchLatestDuty() async {
    final response = await http.get(Uri.parse('$baseUrl3030/duties/latest'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Duty.fromJson(data);
    } else if (response.statusCode == 404) {
      return null; // Duty 항목이 없는 경우
    } else {
      throw Exception('최근 작업 불러오기 실패');
    }
  }



  // ✅ 최근 항목을 수정하는 함수로 변경
  static Future<bool> updateLatestDuty(Duty duty) async {
    final response = await http.patch(
      Uri.parse('$baseUrl3030/duties/latest'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'DutyName': duty.dutyName,
        'StartDate': duty.startDate.toIso8601String().split('T')[0],
        'EndDate': duty.endDate.toIso8601String().split('T')[0],
        'Progress': duty.progress,
      }),
    );

    return response.statusCode == 200;
  }

}
