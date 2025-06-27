import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iot_dashboard/model/iot_model.dart';

class IotController extends ChangeNotifier {
  final List<IotItem> _items = [];

  List<IotItem> get items => _items;

  // 🔧 BASE URL 분리
  static const String _baseUrl = 'https://hanlimtwin.kr:3030/api';

  // ✅ 샘플 데이터 로딩
  Future<void> fetchSampleIotItems() async {
    const String jsonString = '''[
      {
        "id": "001",
        "type": "변위",
        "location": "Zone A-3",
        "status": "경고",        
        "lastUpdated": "2025-01-20 14:30",
        "X(mm)": 0.12,
        "Y(mm)": -0.03,
        "Z(mm)": 0.04,
        "X_Deg": 0,
        "Y_Deg": 45,
        "Z_Deg": 45,
            'BatteryVoltage': double.tryParse(battery) ?? 0.0,
    'BatteryLevel': double.tryParse(batteryInfo) ?? 0.0,
        "download": "다운로드"
      }
    ]'''; // ✂️ 테스트용 JSON 1개만 남김. 실제 사용 시 파일/서버에서 불러오기 권장

    final List<dynamic> decoded = jsonDecode(jsonString);
    _items.clear(); // 기존 데이터 초기화
    _items.addAll(decoded.map((e) => IotItem.fromJson(e)));
    notifyListeners();
  }

  // ✅ 센서 데이터 수동 제출
  Future<bool> submitIotItem(IotItem item) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sensor'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(item.toJson()),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ 전송 성공: ${item.id}');
        return true;
      } else {
        debugPrint('❌ 전송 실패: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ 예외 발생: $e');
      return false;
    }
  }

  // 🆕 (선택) 최근 센서 데이터 불러오기
  Future<void> fetchRecentSensorData({int days = 1}) async {
    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/recent-sensor-data?days=$days'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        _items.clear();
        _items.addAll(data.map((e) => IotItem.fromJson(e)));
        notifyListeners();
      } else {
        debugPrint('❌ 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ 조회 중 예외 발생: $e');
    }
  }
}
