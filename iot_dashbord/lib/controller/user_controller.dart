import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/user_model.dart';
import 'package:iot_dashboard/utils/auth_service.dart';

class UserController {
  static Future<String?> registerUser(UserModel user, BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('https://hanlimtwin.kr:3030/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 201) {
        return null; // 성공
      } else {
        return jsonDecode(response.body)['error'] ?? '회원가입 실패';
      }
    } catch (e) {
      return '네트워크 오류: $e';
    }
  }


  /// ✅ 아이디 중복 체크 메서드
  static Future<bool> checkDuplicateUserID(String userID) async {
    try {
      final uri = Uri.parse('https://hanlimtwin.kr:3030/api/check-id?userID=$userID');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['isAvailable'] == true;
      } else {
        debugPrint('⚠️ 중복체크 실패: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ 중복체크 에러: $e');
      return false;
    }
  }

  static Future<String?> recoverPassword(String userID, String email) async {
    try {
      final uri = Uri.parse('https://hanlimtwin.kr:3030/api/recover-password');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userID': userID, 'email': email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['tempPassword'];
      } else {
        final data = jsonDecode(response.body);
        return Future.error(data['error'] ?? '서버 오류');
      }
    } catch (e) {
      return Future.error('통신 오류');
    }
  }


  static Future<String?> login(String userID, String password) async {
    try {
      final response = await http.post(
        Uri.parse('https://hanlimtwin.kr:3030/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userID': userID,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['accessToken'];
        final refreshToken = data['refreshToken'];
        AuthService.saveTokens(accessToken, refreshToken,userID);
        return null; // 로그인 성공
      } else {
        return jsonDecode(response.body)['error'] ?? '로그인 실패';
      }
    } catch (e) {
      return '네트워크 오류: $e';
    }
  }

  static Future<void> logout(String userID) async {
    try {
      final response = await http.post(
        Uri.parse('https://hanlimtwin.kr:3030/api/logout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userID': userID}),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ 로그아웃 성공');
      } else {
        debugPrint('⚠️ 로그아웃 실패: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ 로그아웃 중 오류 발생: $e');
    } finally {
      AuthService.clearTokens(); // 저장된 토큰 제거
    }
  }
  static Future<List<String>> findUserIDsByName(String name) async {
    try {
      final response = await http.get(Uri.parse('https://hanlimtwin.kr:3030/api/find-id?name=$name'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> ids = data['userIDs'];
        return ids.map((e) => e.toString()).toList();
      } else {
        return []; // 없는 경우도 빈 리스트로 처리
      }
    } catch (e) {
      debugPrint('❌ 아이디 찾기 오류: $e');
      return [];
    }
  }

  static Future<bool> changePassword(String userID, String currentPw, String newPw) async {
    final uri = Uri.parse('https://hanlimtwin.kr:3030/api/change-password');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userID': userID,
        'currentPassword': currentPw,
        'newPassword': newPw,
      }),
    );

    return response.statusCode == 200;
  }




}