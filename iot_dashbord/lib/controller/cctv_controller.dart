import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iot_dashboard/model/cctv_model.dart';

class CctvController extends ChangeNotifier {
  List<CctvItem> _items = [];

  List<CctvItem> get items => _items;

  // 기존 CCTV 리스트 조회
  Future<void> fetchCctvs() async {
    try {
      final response = await http.get(
        Uri.parse('https://hanlimtwin.kr:4040/api/cctvs'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        _items = jsonData.map((json) => CctvItem.fromJson(json)).toList();
        notifyListeners();
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ CCTV 불러오기 실패: $e');
    }
  }

  // CCTV 등록 또는 수정 API 호출
  Future<bool> upsertCctv({
    required String camID,
    String? location,
    bool? isConnected,
    String? eventState,
    double? imageAnalysis,
    required String streamUrl,
    String? recordPath,
    String? rtspUrl,
    String? onvifXaddr,
    String? onvifUser,
    String? onvifPass,
  }) async {
    final url = Uri.parse('https://hanlimtwin.kr:4040/api/cctvs');

    final body = {
      'camID': camID,
      'location': location,
      'isConnected': isConnected,
      'eventState': eventState,
      'imageAnalysis': imageAnalysis,
      'streamUrl': streamUrl,
      'recordPath': recordPath,
      'rtspUrl': rtspUrl,
      'onvifXaddr': onvifXaddr,
      'onvifUser': onvifUser,
      'onvifPass': onvifPass,
    };

    // null 값은 JSON에 포함하지 않도록 필터링
    body.removeWhere((key, value) => value == null);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 변경 후 최신 목록 다시 불러오기
        await fetchCctvs();
        return true;
      } else {
        print('❌ CCTV 등록/수정 실패 상태코드: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ CCTV 등록/수정 실패: $e');
      return false;
    }
  }
}
