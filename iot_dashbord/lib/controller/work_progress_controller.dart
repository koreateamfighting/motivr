// controller/work_progress_controller.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/work_progress_model.dart';
import 'package:iot_dashboard/constants/global_constants.dart';
class WorkProgressController {


  static Future<WorkProgress> fetchProgress() async {
    final res = await http.get(Uri.parse('$baseUrl3030/progress'));
    if (res.statusCode == 200) {
      return WorkProgress.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Failed to load progress');
    }
  }

  static Future<void> saveProgress(double progress) async {
    await http.post(
      Uri.parse('$baseUrl3030/progress'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'progress': progress}),
    );
  }
}
