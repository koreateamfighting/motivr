import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/field_info_model.dart';
import 'package:iot_dashboard/constants/global_constants.dart';
class FieldInfoController {


  // ✅ 최신 1건 조회
  static Future<FieldInfo?> fetchLatestFieldInfo() async {
    final url = Uri.parse('$baseUrl3030/fieldinfo');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return FieldInfo.fromJson(data);
      } else {
        print('❌ 현장 정보 조회 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ 오류 발생: $e');
      return null;
    }
  }

  // ✅ 등록
  static Future<bool> insertFieldInfo(FieldInfo info) async {
    final url = Uri.parse('$baseUrl3030/fieldinfo');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(info.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('❌ 등록 실패: $e');
      return false;
    }
  }
}
