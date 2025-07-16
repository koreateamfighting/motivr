import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iot_dashboard/model/iot_model.dart';
import 'package:iot_dashboard/component/timeseries/graph_view.dart';
import 'package:intl/intl.dart';
import 'dart:html' as html; // Flutter Web 전용

class IotController extends ChangeNotifier {



  // 🔧 BASE URL 분리
  static const String _baseUrl = 'https://hanlimtwin.kr:3030/api';

  final List<IotItem> _items = [];
  int normal = 0, caution = 0, danger = 0, inspection = 0, total = 0;
  List<IotItem> get items => _items;

  final Map<String, IotItem> editedItems = {};

  void onFieldChanged(String id, String createAtStr, String field, String value) {
    final createAt = DateTime.tryParse(createAtStr);
    if (createAt == null) {
      debugPrint('❌ 잘못된 createAt 형식: $createAtStr');
      return;
    }

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
        debugPrint('❌ IOT Controller 센서 시간별 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ 조회 중 예외 발생: $e');
    }
  }



  List<DisplacementGroup> getFilteredDisplacementGroups() {
    final grouped = <String, List<IotItem>>{};

    debugPrint('📋 전체 _items 개수: ${_items.length}');

    for (final item in _items) {
      final eventType = item.eventtype.trim();
      final minute = item.createAt.minute;

      if (eventType != '2') continue;
      if (minute != 9 && minute != 39) continue;

      grouped.putIfAbsent(item.id, () => []).add(item);
    }

    debugPrint('✅ 필터링 후 그룹 개수: ${grouped.length}');
    for (final entry in grouped.entries) {
      debugPrint('📌 RID=${entry.key}, 데이터 개수: ${entry.value.length}');
      for (final i in entry.value) {
        //debugPrint('  ↳ time=${i.createAt}, X=${i.X_Deg}, Y=${i.Y_Deg}, Z=${i.Z_Deg}');
      }
    }

    return grouped.entries.map((entry) {
      final x = <DisplacementData>[];
      final y = <DisplacementData>[];
      final z = <DisplacementData>[];

      for (final i in entry.value) {
        final time = i.createAt;
        x.add(DisplacementData(time, double.tryParse(i.X_Deg) ?? 0.0));
        y.add(DisplacementData(time, double.tryParse(i.Y_Deg) ?? 0.0));
        z.add(DisplacementData(time, double.tryParse(i.Z_Deg) ?? 0.0));
      }

      return DisplacementGroup(rid: entry.key, x: x, y: y, z: z);
    }).toList();
  }





  // ✅ 전체 센서 데이터 조회 (limit 기본 500)
  Future<void> fetchAllSensorData({int limit = 500}) async {
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
        debugPrint('❌ 전체 센서 데이터 최신 500개 조회 실패: ${response.statusCode}');
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
        debugPrint('❌ rid 개수 파악 조회 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ RID 개수 조회 중 예외 발생: $e');
      return null;
    }
  }

  bool isLoading = false;
  bool hasError = false;

  Future<void> fetchSensorStatusSummary() async {
    final uri = Uri.parse('$_baseUrl/sensor-status-summary');
    debugPrint('[IotController] ▶️ fetchSensorStatusSummary 호출: $uri');

    isLoading = true;
    hasError = false;
    notifyListeners(); // 🔁 상태 갱신 반영

    try {
      final response = await http.get(uri);

      debugPrint('[IotController] 📡 응답 수신: statusCode = ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is! Map<String, dynamic>) {
          debugPrint('❌ 응답 형식 오류: Map<String, dynamic> 아님 → $data');
          hasError = true;
          return;
        }

        normal = data['normal'] ?? 0;
        caution = data['caution'] ?? 0;
        danger = data['danger'] ?? 0;
        inspection = data['needInspection'] ?? 0;
        total = data['total'] ?? 0;

        debugPrint('[IotController] ✅ 정상 처리됨');
        debugPrint('  - Normal     : $normal');
        debugPrint('  - Caution    : $caution');
        debugPrint('  - Danger     : $danger');
        debugPrint('  - Inspection : $inspection');
        debugPrint('  - Total      : $total');
      } else {
        debugPrint('❌ IOT Status 서버 오류: ${response.statusCode} ${response.reasonPhrase}');
        hasError = true;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ 예외 발생: $e');
      debugPrint('$stackTrace');
      hasError = true;
    } finally {
      isLoading = false;
      notifyListeners(); // 🔁 로딩 종료 후 상태 갱신
    }
  }


  Future<void> fetchRecentSensorData({int days = 1}) async {
    final uri = Uri.parse('$_baseUrl/recent-sensor-data?days=$days');
    debugPrint('📡 최근 센서 데이터 조회 시작: $uri');

    try {
      final response = await http.get(uri);

      debugPrint('📥 응답 상태코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];

        // ✅ 로그 추가 시작
        debugPrint('📊 서버에서 수신된 레코드 수: ${data.length}');
        if (data.isNotEmpty) {
          debugPrint('📊 첫 번째 레코드 createAt: ${data.first['CreateAt']}');
        }
        // ✅ 로그 추가 끝

        _items.clear();
        _items.addAll(data.map((e) => IotItem.fromJson(e)));

        // ✅ 추가 로그: 파싱 후 확인
        debugPrint('📋 파싱된 IotItem 개수: ${_items.length}');
        if (_items.isNotEmpty) {
          debugPrint('📋 첫 번째 IotItem createAt: ${_items.first.createAt}');
        }

        notifyListeners();

        debugPrint('✅ ${data.length}건의 센서 데이터 불러옴');
      } else {
        debugPrint('❌ 하루 최신 데이터 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ 조회 중 예외 발생: $e');
    }
  }


  Future<void> downloadExcelFile(DateTime startDate, DateTime endDate, List<String> ridList) async {
    final formattedStart = DateFormat('yyyy-MM-dd HH:mm:ss').format(startDate);
    final formattedEnd = DateFormat('yyyy-MM-dd HH:mm:ss').format(endDate);
    final rids = ridList.join(',');

    final url = '$_baseUrl/download-excel?startDate=$formattedStart&endDate=$formattedEnd&rids=$rids';

    try {
      // ✅ 웹 다운로드: <a href="url" download> 트리거
      final anchor = html.AnchorElement(href: url)
        ..target = 'blank'
        ..download = ''
        ..click();

      debugPrint('📥 다운로드 요청 URL: $url');
    } catch (e) {
      debugPrint('❌ 엑셀 다운로드 요청 실패: $e');
    }
  }

  Future<void> downloadExcelByRid(String rid) async {
    final encodedRid = Uri.encodeComponent(rid);
    final url = '$_baseUrl/download-excel-rid-only?rid=$encodedRid';

    try {
      final anchor = html.AnchorElement(href: url)
        ..target = 'blank'
        ..download = ''
        ..click();

      debugPrint('📥 단일 RID 다운로드 요청 URL: $url');
    } catch (e) {
      debugPrint('❌ RID별 엑셀 다운로드 실패: $e');
    }
  }


  List<IotItem> filterItems(String query) {
    final q = query.toLowerCase().trim();
    return _items.where((item) => item.id.toLowerCase().contains(q)).toList();
  }

  // 상태 변수들에 접근할 getter
  int get getNormal => normal;
  int get getCaution => caution;
  int get getDanger => danger;
  int get getInspection => inspection;
  int get getTotal => total;
}






