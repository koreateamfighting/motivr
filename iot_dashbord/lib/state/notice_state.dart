import 'package:flutter/material.dart';
import 'package:iot_dashboard/model/notice_model.dart';
import 'package:iot_dashboard/controller/notice_controller.dart';

class NoticeState extends ChangeNotifier {
  List<Notice> _notices = [];

  List<Notice> get notices => _notices;

  Future<void> fetchAndNotify() async {
    final fetched = await NoticeController.fetchNotices();

    // 기존과 다를 경우에만 notify
    if (_notices.length != fetched.length ||
        !_notices.asMap().entries.every((entry) =>
        entry.value.content == fetched[entry.key].content)) {
      _notices = fetched;
      notifyListeners();
    }
  }

  void clear() {
    _notices = [];
    notifyListeners();
  }
}
