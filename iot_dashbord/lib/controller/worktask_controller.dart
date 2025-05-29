import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/worktask_model.dart';

class WorkTaskController {
  static const String _baseUrl = 'https://hanlimtwin.kr:3030/api';

  static Future<List<WorkTask>> fetchTasks() async {
    final response = await http.get(Uri.parse('$_baseUrl/work-tasks'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => WorkTask.fromJson(json)).toList();
    } else {
      throw Exception('작업 데이터를 불러오는 데 실패했습니다.');
    }
  }
}
