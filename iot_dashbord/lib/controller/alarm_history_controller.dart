import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iot_dashboard/state/alarm_history_state.dart';
import 'package:iot_dashboard/model/alarm_history_model.dart';
import 'dart:html' as html; // 웹 전용
import 'dart:typed_data';
import 'package:iot_dashboard/constants/global_constants.dart';
import 'package:intl/intl.dart';
class AlarmHistoryController {



// ✅ IoT 알람 히스토리 저장 (Label + RID 조합)
  static Future<bool> insertIotAlarm({
    required String rid,
    required String label,
    required DateTime timestamp,
    required String event,
    required String log,
    double? latitude,
    double? longitude,
  }) async {
    final url = Uri.parse('$baseUrl3030/api/alarmhistory/iot');

    final body = {
      'DeviceID': rid,
      'Label': label,
      'Timestamp': timestamp.toIso8601String(),
      'Event': event,
      'Log': log,
      'Latitude': latitude,
      'Longitude': longitude,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('✅ IoT 알람 저장 성공');
        return true;
      } else {
        print('⚠️ IoT 알람 저장 실패: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ IoT 알람 저장 예외 발생: $e');
      return false;
    }
  }

// ✅ CCTV 알람 히스토리 저장
  static Future<bool> insertCctvAlarm({
    required String deviceId,
    required DateTime timestamp,
    required String event,
    required String log,
    required String location,
  }) async {
    final url = Uri.parse('$baseUrl3030/api/alarmhistory/cctv');

    final body = {
      'DeviceID': deviceId,
      'Timestamp': timestamp.toIso8601String(),
      'Event': event,
      'Log': log,
      'Location': location,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('✅ CCTV 알람 저장 성공');
        return true;
      } else {
        print('⚠️ CCTV 알람 저장 실패: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ CCTV 알람 저장 예외 발생: $e');
      return false;
    }
  }

  // ✅ 알람 히스토리 조회 - IOT 전용
  static Future<List<AlarmHistory>> fetchIotAlarmHistory() async {
    final response = await http.get(Uri.parse('$baseUrl3030/api/alarmhistory/iot'));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> records = decoded['data'];
      return records.map((e) => AlarmHistory.fromJson(e)).toList();
    } else {
      throw Exception('IOT 알람 히스토리 조회 실패: ${response.body}');
    }
  }

  // ✅ 알람 히스토리 조회 - CCTV 전용
  static Future<List<AlarmHistory>> fetchCctvAlarmHistory() async {
    final response = await http.get(Uri.parse('$baseUrl3030/api/alarmhistory/cctv'));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> records = decoded['data'];
      return records.map((e) => AlarmHistory.fromJson(e)).toList();
    } else {
      throw Exception('CCTV 알람 히스토리 조회 실패: ${response.body}');
    }
  }// 알람 수정
  static Future<bool> updateAlarms(List<AlarmHistory> alarms) async {
    final url = Uri.parse('$baseUrl3030/api/alarmhistory/update');

    final body = alarms.map((a) => {
      'Id': a.id,
      'Timestamp': a.timestamp.toIso8601String(),
      'Event': a.event,
      'Log': a.log ?? '',
    }).toList();

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('✅ 알람 수정 성공');
        return true;
      } else {
        print('⚠️ 알람 수정 실패: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ 알람 수정 예외 발생: $e');
      return false;
    }
  }

// 알람 삭제
  static Future<bool> deleteAlarms(List<int> ids) async {
    final url = Uri.parse('$baseUrl3030/api/alarmhistory/delete');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'ids': ids}),
      );

      if (response.statusCode == 200) {
        print('✅ 알람 삭제 성공');
        return true;
      } else {
        print('⚠️ 알람 삭제 실패: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ 알람 삭제 예외 발생: $e');
      return false;
    }
  }


  // ✅ CCTV 로그 저장용 API 호출
  static Future<bool> logCctvStatus({
    required String camId,
    required bool isConnected,
    AlarmHistoryState? alarmState, // 💡 optional 전달
  }) async {
    final url = Uri.parse('$baseUrl3030/api/alarmhistory/cctvlog');

    final body = {
      'camId': camId,
      'isConnected': isConnected,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('✅ CCTV 로그 저장 성공: ${response.body}');
        return true;
      } else {
        print('⚠️ CCTV 로그 저장 실패: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ CCTV 로그 저장 예외 발생: $e');
      return false;
    }
  }
  // ✅ 각 DeviceID별 최신 CCTV 알람 조회
  static Future<List<AlarmHistory>> fetchLatestCctvLogs() async {
    final url = Uri.parse('$baseUrl3030/api/alarmhistory/cctv/latest');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> records = decoded['data'];


        return records.map((e) {
          final parsed = AlarmHistory.fromJson(e);

          return parsed;
        }).toList();
      } else {
        print('⚠️ 최신 CCTV 알람 조회 실패: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ 최신 CCTV 알람 조회 예외 발생: $e');
      return [];
    }
  }
// ✅ 특정 DeviceID의 CCTV 경고/주의 알람 100건 조회
  static Future<List<AlarmHistory>> fetchCctvAlertByDevice(String deviceId) async {
    final url = Uri.parse('$baseUrl3030/api/alarmhistory/cctv/alert-by-device/$deviceId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> records = decoded['data'];

        return records.map((e) => AlarmHistory.fromJson(e)).toList();
      } else {
        print('⚠️ CCTV 알람 조회 실패: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ CCTV 알람 조회 예외 발생: $e');
      return [];
    }
  }


  static Future<void> downloadCctvLogExcel(String camId) async {
    final url = Uri.parse('$baseUrl3030/api/alarmhistory/download-excel-cctv?camId=$camId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final blob = html.Blob([response.bodyBytes]);
        final urlObj = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: urlObj)
          ..setAttribute("download", "cctv_logs_$camId.xlsx")
          ..click();
        html.Url.revokeObjectUrl(urlObj);

        print('✅ 엑셀 다운로드 성공');
      } else {
        print('⚠️ 엑셀 다운로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 엑셀 다운로드 예외 발생: $e');
    }
  }


  static Future<void> downloadCctvLogCsv(String camId) async {
    final url = Uri.parse('$baseUrl3030/api/alarmhistory/download-log?camId=$camId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final blob = html.Blob([response.bodyBytes]);
        final urlObj = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: urlObj)
          ..setAttribute("download", "cctv_logs_$camId.csv")
          ..click();
        html.Url.revokeObjectUrl(urlObj);

        print('✅ CSV 다운로드 성공');
      } else {
        print('⚠️ CSV 다운로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ CSV 다운로드 예외 발생: $e');
    }
  }

  static Future<void> downloadCctvLogExcelByPeriod({
    required List<String> camIds,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (camIds.isEmpty) {
      print('❌ 다운로드 실패: 선택된 camId 없음');
      return;
    }

    final startStr = Uri.encodeComponent(startDate.toIso8601String());
    final endStr = Uri.encodeComponent(endDate.toIso8601String());

    // 쉼표로 join 후 encode
    final camIdParam = Uri.encodeComponent(camIds.join(','));

    final url = Uri.parse(
      '$baseUrl3030/api/alarmhistory/download-excel-cctv-period-multi?camId=$camIdParam&startDate=$startStr&endDate=$endStr',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final blob = html.Blob([response.bodyBytes]);
        final urlObj = html.Url.createObjectUrlFromBlob(blob);

        // 파일 이름: 단일이면 cam1_2025-08-05.xlsx / 다중이면 cam1~cam3_2025-08-05.xlsx
        final first = camIds.first;
        final last = camIds.length > 1 ? '~${camIds.last}' : '';
        final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
        final filename = 'cctv_logs_${first}${last}_$dateStr.xlsx';

        final anchor = html.AnchorElement(href: urlObj)
          ..setAttribute("download", filename)
          ..click();
        html.Url.revokeObjectUrl(urlObj);

        print('✅ CCTV 엑셀 다운로드 성공: $filename');
      } else {
        print('⚠️ CCTV 엑셀 다운로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ CCTV 엑셀 다운로드 예외 발생: $e');
    }
  }




  static Future<List<Map<String, dynamic>>> fetchCctvGraphData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final url = Uri.parse(
        '$baseUrl3030/api/alarmhistory/cctv/graph-data?startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}'
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> records = decoded['data'];

        return records.map((e) {
          final event = e['Event'];
          int value = 0;
          if (event == '주의') value = 1;
          else if (event == '경고') value = 2;

          return {
            'deviceId': e['DeviceID'],
            'timestamp': DateTime.parse(e['Timestamp']),
            'value': value,
          };
        }).toList();
      } else {
        print('⚠️ CCTV 그래프 데이터 조회 실패: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ CCTV 그래프 데이터 조회 예외 발생: $e');
      return [];
    }
  }

}
