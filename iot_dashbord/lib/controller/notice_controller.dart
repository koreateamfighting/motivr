import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/notice_model.dart';
import 'package:iot_dashboard/constants/global_constants.dart';
class NoticeController {

  /// ✅ 공지 목록 불러오기
  static Future<List<Notice>> fetchNotices() async {
    final url = Uri.parse('$baseUrl3030/api/notices');

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
  /// ✅ 공지 수정
  static Future<bool> updateNotice(int id, String newContent) async {
    final url = Uri.parse('$baseUrl3030/api/notices/$id');

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'content': newContent}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ 공지사항 수정 오류: $e');
      return false;
    }
  }

  /// ✅ 공지 추가
  static Future<bool> addNotice(String content, String createdAt) async {
    final url = Uri.parse('$baseUrl3030/api/notices');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'content': content,
          'createdAt': createdAt, // ⬅️ 시간 추가
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ 공지사항 등록 오류: $e');
      return false;
    }
  }


  /// ✅ 공지 일괄 수정
  static Future<bool> updateNotices(List<Notice> notices) async {
    final url = Uri.parse('$baseUrl3030/api/bulk-update-notices');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(notices.map((n) => {
          'id': n.id,
          'content': n.content,
        }).toList()),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('❌ 공지사항 일괄 수정 실패: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ 공지사항 일괄 수정 중 오류: $e');
      return false;
    }
  }


  /// ✅ 공지 삭제 (여러 개 동시에)
  static Future<bool> deleteNotices(List<int> ids) async {
    final url = Uri.parse('$baseUrl3030/api/delete-notices');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'ids': ids}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ 공지사항 삭제 오류: $e');
      return false;
    }
  }


}
