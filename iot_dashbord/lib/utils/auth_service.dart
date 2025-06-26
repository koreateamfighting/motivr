import 'dart:convert';
import 'dart:html' as html;

class AuthService {
  static void saveTokens(String accessToken, String refreshToken, String userID) {
    html.window.localStorage['accessToken'] = accessToken;
    html.window.localStorage['refreshToken'] = refreshToken;
    html.window.localStorage['userID'] = userID;

    // ✅ JWT에서 role 파싱해서 저장
    try {
      final parts = accessToken.split('.');
      if (parts.length == 3) {
        final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
        final data = json.decode(payload);
        final role = data['role'];
        if (role != null) {
          html.window.localStorage['role'] = role;
          print('🛂 사용자 권한: $role');
        }
      }
    } catch (e) {
      print('❌ JWT 디코딩 오류: $e');
      html.window.localStorage.remove('role');
    }
  }

  static bool isAuthenticated() {
    return html.window.localStorage['accessToken'] != null;
  }

  static bool isAdmin() {
    return html.window.localStorage['role'] == 'admin';
  }

  static bool isRoot() {
    return html.window.localStorage['role'] == 'root';
  }

  static String? getUserID() {
    return html.window.localStorage['userID'];
  }

  static String? getAccessToken() {
    return html.window.localStorage['accessToken'];
  }

  static void clearTokens() {
    html.window.localStorage.remove('accessToken');
    html.window.localStorage.remove('refreshToken');
    html.window.localStorage.remove('userID');
    html.window.localStorage.remove('role'); // ✅ 같이 제거
  }
}
