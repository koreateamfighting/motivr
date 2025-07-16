import 'package:flutter/foundation.dart';

class AlarmHistoryState extends ChangeNotifier {
  int _cctvLogRefreshCount = 0;

  int get refreshCount => _cctvLogRefreshCount;

  void triggerRefresh() {
    _cctvLogRefreshCount++;
    notifyListeners();
  }
}
