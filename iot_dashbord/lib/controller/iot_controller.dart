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
        "SensorType": "변위",
        "EventType": "경고",
        "Latitude": "37.12345",
        "Longitude": "127.12345",
        "BatteryVoltage": 3.7,
        "BatteryLevel": 82.0,
        "X_MM": 0.12,
        "Y_MM": -0.03,
        "Z_MM": 0.04,
        "X_Deg": 0,
        "Y_Deg": 45,
        "Z_Deg": 45,
        "download": "다운로드",
        "CreateAt": "2025-01-20T14:30:00"
      }
    ]''';

    debugPrint('📦 샘플 IoT 데이터 로드 시작');

    final List<dynamic> decoded = jsonDecode(jsonString);
    _items.clear();
    _items.addAll(decoded.map((e) => IotItem.fromJson(e)));
    notifyListeners();

    debugPrint('✅ 샘플 데이터 로드 완료 (${_items.length}건)');
  }

  // ✅ 센서 데이터 수동 제출
  Future<bool> submitIotItem(IotItem item) async {
    final uri = Uri.parse('$_baseUrl/sensor');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(item.toJson());

    debugPrint('📤 센서 데이터 전송 시작 → $uri');
    debugPrint('📦 전송 데이터:\n$body');

    try {
      final response = await http.post(uri, headers: headers, body: body);

      debugPrint('📥 서버 응답 상태코드: ${response.statusCode}');
      debugPrint('📥 서버 응답 내용: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('✅ 전송 성공: ${item.id}');
        return true;
      } else {
        debugPrint('❌ 전송 실패: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ 예외 발생: $e');
      return false;
    }
  }

  // 🆕 최근 센서 데이터 불러오기
  Future<void> fetchRecentSensorData({int days = 1}) async {
    final uri = Uri.parse('$_baseUrl/recent-sensor-data?days=$days');
    debugPrint('📡 최근 센서 데이터 조회 시작: $uri');

    try {
      final response = await http.get(uri);

      debugPrint('📥 응답 상태코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        _items.clear();
        _items.addAll(data.map((e) => IotItem.fromJson(e)));
        notifyListeners();

        debugPrint('✅ ${data.length}건의 센서 데이터 불러옴');
      } else {
        debugPrint('❌ 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ 조회 중 예외 발생: $e');
    }
  }
}
