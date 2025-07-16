import 'package:flutter/material.dart';
import 'package:iot_dashboard/model/worktask_model.dart';
import 'package:iot_dashboard/controller/worktask_controller.dart';

class WorkTaskState extends ChangeNotifier {
  List<WorkTask> _tasks = [];

  List<WorkTask> get tasks => _tasks;

  Future<void> fetchTasks() async {
    final fetched = await WorkTaskController.fetchTasks();
    // 변경된 경우에만 반영
    if (_tasks.length != fetched.length ||
        !_tasks.asMap().entries.every((entry) =>
        entry.value.title == fetched[entry.key].title &&
            entry.value.progress == fetched[entry.key].progress)) {
      _tasks = fetched;
      notifyListeners();
    }
  }

  void clear() {
    _tasks = [];
    notifyListeners();
  }
}
