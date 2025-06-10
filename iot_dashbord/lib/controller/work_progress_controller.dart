// controller/work_progress_controller.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/work_progress_model.dart';

class WorkProgressController {
  static const String baseUrl = 'https://hanlimtwin.kr:3030/api';

  static Future<WorkProgress> fetchProgress() async {
    final res = await http.get(Uri.parse('$baseUrl/progress'));
    if (res.statusCode == 200) {
      return WorkProgress.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Failed to load progress');
    }
  }

  static Future<void> saveProgress(double progress) async {
    await http.post(
      Uri.parse('$baseUrl/progress'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'progress': progress}),
    );
  }
}
