import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iot_dashboard/model/cctv_model.dart';

class CctvController extends ChangeNotifier {
  List<CctvItem> _items = [];

  List<CctvItem> get items => _items;

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
}
