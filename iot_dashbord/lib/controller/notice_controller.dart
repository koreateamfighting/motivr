import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/notice_model.dart';

class NoticeController {
  static Future<List<Notice>> fetchNotices() async {
    final url = Uri.parse('https://hanlimtwin.kr:3030/api/notices');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Notice.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load notices: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 공지사항 로딩 오류: $e');
      return [];
    }
  }
}
