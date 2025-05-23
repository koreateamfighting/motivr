import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/user_model.dart';

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
}