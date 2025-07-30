import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/user_model.dart';
import 'package:iot_dashboard/utils/auth_service.dart';
import 'package:iot_dashboard/constants/global_constants.dart';
class UserController {
  static UserModel? currentUser; // ✅ 로그인한 사용자 정보 보관
  static Future<String?> registerUser(UserModel user, BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl3030/register'),
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
      final uri = Uri.parse('$baseUrl3030/check-id?userID=$userID');
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
      final uri = Uri.parse('$baseUrl3030/recover-password');
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
        Uri.parse('$baseUrl3030/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userID': userID, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['role'] == 'disabled') {
          return '회원 승인 요청이 필요합니다. 관리자에게 문의하세요.';
        }

        final accessToken = data['accessToken'];
        final refreshToken = data['refreshToken'];
        final role = data['role'];
        final name = data['name'];
        print('🎯 로그인 성공: role=$role');
        // ✅ 사용자 정보 저장
        currentUser = UserModel(
          userID: userID,
          password: '', // 실제 비밀번호는 저장하지 않음
          email: '', // 필요 시 추가 요청으로 받아올 수 있음
          name: name ?? '',
          role: role ?? 'disabled',
        );

        AuthService.saveTokens(accessToken, refreshToken, userID);
        return null;
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
        Uri.parse('$baseUrl3030/logout'),
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
      final response = await http.get(Uri.parse('$baseUrl3030/find-id?name=$name'));

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
    final uri = Uri.parse('$baseUrl3030/change-password');

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

  static Future<Map<String, String>> getAllUsersAndRoles() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl3030/users/all'));
      debugPrint('🌐 응답 상태: ${response.statusCode}');
      debugPrint('📦 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          // 👉 리스트일 경우 (서버가 배열로 보낼 때)
          return {
            for (var item in data)
              item['userID'].toString(): item['role'].toString()
          };
        } else if (data is Map<String, dynamic>) {
          // 👉 서버가 Map으로 줄 경우
          return data.map((key, value) => MapEntry(key, value.toString()));
        } else {
          debugPrint('⚠️ 예기치 않은 형식의 응답');
          return {};
        }
      } else {
        return {};
      }
    } catch (e) {
      debugPrint('❌ 전체 유저 조회 오류: $e');
      return {};
    }
  }



  static Future<List<String>> getUsersByRole({List<String>? includeRoles, List<String>? excludeRoles}) async {
    try {
      final uri = Uri.parse(
        '$baseUrl3030/users/by-role'
            '?includeRoles=${includeRoles?.join(',') ?? ''}&excludeRoles=${excludeRoles?.join(',') ?? ''}',
      );

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map<String>((e) => e['UserID'].toString()).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('❌ 사용자 권한 조회 오류: $e');
      return [];
    }
  }

  static Future<bool> updateUserRoles(List<String> userIDs, String newRole) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl3030/users/update-role'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userIDs': userIDs,
          'newRole': newRole,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ 역할 변경 오류: $e');
      return false;
    }
  }
}



