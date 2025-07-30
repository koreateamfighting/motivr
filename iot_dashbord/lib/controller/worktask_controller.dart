import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/worktask_model.dart';
import 'package:iot_dashboard/constants/global_constants.dart';
class WorkTaskController {


  static Future<List<WorkTask>> fetchTasks() async {
    final response = await http.get(Uri.parse('$baseUrl3030/work-tasks'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => WorkTask.fromJson(json)).toList();
    } else {
      throw Exception('작업 데이터를 불러오는 데 실패했습니다.');
    }
  }

  static Future<bool> updateTask(WorkTask task) async {
    final url = Uri.parse('$baseUrl3030/work-tasks/${task.id}');
    final body = {
      'title': task.title,
      'progress': task.progress,
      'start_date': task.startDate,
      'end_date': task.endDate,
    };

    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('❌ 작업 수정 실패: ${response.statusCode}, ${response.body}');
      return false;
    }
  }
  static Future<bool> updateTasks(List<WorkTask> tasks) async {
    final url = Uri.parse('$baseUrl3030/bulk-update');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(tasks.map((task) => task.toJson()).toList()),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('작업 저장 실패: ${response.body}');
    }
  }

  static Future<bool> deleteTasks(List<int> ids) async {
    final response = await http.post(
      Uri.parse('$baseUrl3030/delete-tasks'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'ids': ids}),
    );
    return response.statusCode == 200;
  }




}
