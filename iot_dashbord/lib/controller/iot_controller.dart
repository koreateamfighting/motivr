import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iot_dashboard/model/iot_model.dart';

class IotController extends ChangeNotifier {
  final List<IotItem> _items = [];
  int normal = 0, caution = 0, danger = 0, inspection = 0, total = 0;
  List<IotItem> get items => _items;
// 🔍 ID 기준으로 필터된 리스트 반환
  List<IotItem> filterItems(String query) {
    final q = query.toLowerCase().trim();
    return _items.where((item) => item.id.toLowerCase().contains(q)).toList();
  }

  // 🔧 BASE URL 분리
  static const String _baseUrl = 'https://hanlimtwin.kr:3030/api';

  // ✅ 전체 센서 데이터 조회 (limit 기본 1000)
  Future<void> fetchAllSensorData({int limit = 10000}) async {
    final uri = Uri.parse('$_baseUrl/sensor-data?limit=$limit');
    debugPrint('📡 전체 센서 데이터 조회 시작: $uri');

    try {
      final response = await http.get(uri);
      debugPrint('📥 응답 상태코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        _items.clear();
        _items.addAll(data.map((e) => IotItem.fromJson(e)));
        notifyListeners();

        debugPrint('✅ 전체 데이터 로드 완료 (${data.length}건)');
      } else {
        debugPrint('❌ 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ 전체 조회 중 예외 발생: $e');
    }
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


  // ✅ 수정 (PUT)
  Future<bool> updateIotItem(IotItem item) async {
    final uri = Uri.parse('$_baseUrl/sensor');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(item.toJson());

    try {
      final response = await http.put(uri, headers: headers, body: body);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ 수정 실패: $e');
      return false;
    }
  }

  // ✅ 삭제 (POST /sensor/delete)
  Future<bool> deleteIotItem(String rid, String createAt) async {
    final uri = Uri.parse('$_baseUrl/sensor/delete');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'RID': rid,
      'CreateAt': createAt,
    });

    try {
      final response = await http.post(uri, headers: headers, body: body);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ 삭제 실패: $e');
      return false;
    }
  }
  //rid의 개수 파악
  Future<int?> fetchRidCount() async {
    final uri = Uri.parse('$_baseUrl/rid-count');
    debugPrint('📡 RID 개수 조회 시작: $uri');

    try {
      final response = await http.get(uri);
      debugPrint('📥 응답 상태코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('✅ RID 개수: ${data['count']}');
        return data['count'];
      } else {
        debugPrint('❌ 조회 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ RID 개수 조회 중 예외 발생: $e');
      return null;
    }
  }

  Future<void> fetchSensorStatusSummary() async {
    final uri = Uri.parse('$_baseUrl/sensor-status-summary');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 디버깅을 위한 로그 출력
        debugPrint('Response Data: $data');

        normal = data['normal'] ?? 0;
        caution = data['caution'] ?? 0;
        danger = data['danger'] ?? 0;
        inspection = data['needInspection'] ?? 0; // 점검 필요는 서버에서 계산되어 있음
        total = data['total'] ?? 0;

        // 각 상태 값들을 출력
        debugPrint('Normal: $normal');
        debugPrint('Caution: $caution');
        debugPrint('Danger: $danger');
        debugPrint('Inspection: $inspection');
        debugPrint('Total: $total');

        // 상태가 갱신될 때마다 notifyListeners 호출
        notifyListeners();
      } else {
        debugPrint('❌ 센서 상태 요약 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ 예외 발생: $e');
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

  // 상태 변수들에 접근할 getter
  int get getNormal => normal;
  int get getCaution => caution;
  int get getDanger => danger;
  int get getInspection => inspection;
  int get getTotal => total;
}






