import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iot_dashboard/model/iot_model.dart';
import 'package:iot_dashboard/component/timeseries/graph_view.dart';
import 'package:intl/intl.dart';


class IotController extends ChangeNotifier {



  // 🔧 BASE URL 분리
  static const String _baseUrl = 'https://hanlimtwin.kr:3030/api';

  final List<IotItem> _items = [];
  int normal = 0, caution = 0, danger = 0, inspection = 0, total = 0;
  List<IotItem> get items => _items;

  final Map<String, IotItem> editedItems = {};

  void onFieldChanged(String id, String createAt, String field, String value) {
    final key = '${id}_$createAt';
    final existing = _items.firstWhere(
          (item) => item.id == id && item.createAt == createAt,
      orElse: () => IotItem(
        id: id,
        sensortype: '',
        eventtype: '',
        latitude: '',
        longitude: '',
        battery: '',
        X_MM: '',
        Y_MM: '',
        Z_MM: '',
        X_Deg: '',
        Y_Deg: '',
        Z_Deg: '',
        batteryInfo: '',
        download: '',
        createAt: createAt,
      ),
    );

    final updated = existing.copyWith(
      X_Deg: field == 'x_deg' ? value : existing.X_Deg,
      Y_Deg: field == 'y_deg' ? value : existing.Y_Deg,
      Z_Deg: field == 'z_deg' ? value : existing.Z_Deg,
      X_MM: field == 'x_mm' ? value : existing.X_MM,
      Y_MM: field == 'y_mm' ? value : existing.Y_MM,
      Z_MM: field == 'z_mm' ? value : existing.Z_MM,
      battery: field == 'battery' ? value : existing.battery,
      batteryInfo: field == 'batteryInfo' ? value : existing.batteryInfo,
    );

    editedItems[key] = updated;

    debugPrint('✅ 필드 변경됨 → $field = $value');
    debugPrint('→ 저장 전: X_Deg=${updated.X_Deg}, Y_Deg=${updated.Y_Deg}, Z_Deg=${updated.Z_Deg}');
  }

// 🔍 ID 기준으로 필터된 리스트 반환
  List<IotItem> filterItems(String query) {
    final q = query.toLowerCase().trim();
    return _items.where((item) => item.id.toLowerCase().contains(q)).toList();
  }

  List<DisplacementGroup> getTodayDisplacementGroups() {
    final grouped = <String, List<IotItem>>{};

    for (final item in _items) {
      final dt = DateTime.tryParse(item.createAt);
      if (dt == null || dt.year != DateTime.now().year || dt.month != DateTime.now().month || dt.day != DateTime.now().day) continue;

      grouped.putIfAbsent(item.id, () => []).add(item);
    }

    return grouped.entries.map((entry) {
      final x = <DisplacementData>[];
      final y = <DisplacementData>[];
      final z = <DisplacementData>[];

      for (final i in entry.value) {
        final time = DateTime.tryParse(i.createAt);
        if (time != null) {
          x.add(DisplacementData(time, double.tryParse(i.X_Deg) ?? 0.0));
          y.add(DisplacementData(time, double.tryParse(i.Y_Deg) ?? 0.0));
          z.add(DisplacementData(time, double.tryParse(i.Z_Deg) ?? 0.0));
        }
      }

      return DisplacementGroup(rid: entry.key, x: x, y: y, z: z);
    }).toList();
  }

  Future<void> fetchSensorDataByTimeRange(DateTime startDate, DateTime endDate) async {
    final formattedStartDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(startDate);
    final formattedEndDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(endDate);

    final uri = Uri.parse('$_baseUrl/sensor-data-by-period?startDate=$formattedStartDate&endDate=$formattedEndDate');
    debugPrint('📡 기간 선택 센서 데이터 조회 시작: $uri');

    try {
      final response = await http.get(uri);
      debugPrint('📥 응답 상태코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        _items.clear();
        _items.addAll(data.map((e) => IotItem.fromJson(e)));
        notifyListeners();

        debugPrint('✅ ${data.length}건의 시간 범위 센서 데이터 불러옴');
      } else {
        debugPrint('❌ 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ 조회 중 예외 발생: $e');
    }
  }





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

    // ✅ 포맷을 DB와 일치시키기 (yyyy-MM-dd HH:mm:ss)
    final formattedCreateAt = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(createAt));

    final body = jsonEncode({
      'RID': rid,
      'CreateAt': formattedCreateAt,
    });

    try {
      final response = await http.post(uri, headers: headers, body: body);
      debugPrint('🔥 삭제 응답: ${response.statusCode}, ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ 삭제 실패: $rid, $createAt, $e');
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






