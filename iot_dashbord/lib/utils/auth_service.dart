import 'dart:html' as html;

class AuthService {
  static void saveTokens(String accessToken, String refreshToken, String userID) {
    html.window.localStorage['accessToken'] = accessToken;
    html.window.localStorage['refreshToken'] = refreshToken;
    html.window.localStorage['userID'] = userID;
  }

  static bool isAuthenticated() {
    return html.window.localStorage['accessToken'] != null;
  }


  static void clearTokens() { //로그아웃시
    html.window.localStorage.remove('accessToken');
    html.window.localStorage.remove('refreshToken');
    html.window.localStorage.remove('userID');
  }

  static String? getAccessToken() {
    return html.window.localStorage['accessToken'];
  }

  static String? getUserID() {
    return html.window.localStorage['userID'];
  }

}
