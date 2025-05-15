//weather_api1에서 x,y 좌표로 하나 weather_api3은 시도명, 동이름으로 검색함
//서로 상호 호환이 필요

import 'dart:convert';


import 'package:http/http.dart' as http;

class FineDustApiService {
  static const String _baseUrl =
      'https://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getCtprvnRltmMesureDnsty';
  static const String _serviceKey =
      'bW8uwKE3u%2B7F9ESDv%2F0hlv9hkyyRoR6od6QAZ%2F74FR8bvJCZNYXtC6HbuJINGUTxNy8Jl1WDx0%2BsSt4hm%2Bpmvw%3D%3D';

  /// 미세먼지 농도 (㎍/㎥) 를 문자열로 반환
  static Future<String?> fetchFineDust({
    String sidoName = '대구',
    String stationName = '만촌동',
  }) async {
    final url = Uri.parse('$_baseUrl?serviceKey=$_serviceKey'
        '&returnType=json&numOfRows=100&pageNo=1&sidoName=$sidoName&ver=1.0');

    print('📡 미세먼지 API 호출 URL: $url');

    try {
      final response = await http.get(url);

      print('📬 응답 상태코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['response']['body']['items'] as List;

        print('📦 수신된 미세먼지 측정소 목록 수: ${items.length}');

        // stationName 기준 필터링
        final targetStation = items.firstWhere(
              (el) => el['stationName'] == stationName,
          orElse: () => null,
        );

        if (targetStation != null) {
          final pm10Value = targetStation['pm10Value'];
          print('✅ [$stationName] 미세먼지(PM10): $pm10Value');
          return pm10Value != null ? '${pm10Value}㎍/㎥' : null;
        } else {
          print('⚠️ "$stationName" 측정소를 찾을 수 없습니다.');
        }
      } else {
        print('❌ 미세먼지 API 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('❗ 미세먼지 API 예외 발생: $e');
    }

    return null;
  }
}
