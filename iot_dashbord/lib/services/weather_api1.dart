import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherApiService {
  static const String _serviceKey =
      'bW8uwKE3u%2B7F9ESDv%2F0hlv9hkyyRoR6od6QAZ%2F74FR8bvJCZNYXtC6HbuJINGUTxNy8Jl1WDx0%2BsSt4hm%2Bpmvw%3D%3D';
  static const String _baseUrl =
      'https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst';

  /// 날씨 정보 요청 (온도, 습도, 풍속)
  static Future<Map<String, String?>> fetchWeatherData({
    int nx = 89,
    int ny = 90,
  }) async {
    final timeInfo = _getBaseDateTime();
    final baseDate = timeInfo['baseDate']!;
    final baseTime = timeInfo['baseTime']!;

    final url = Uri.parse('$_baseUrl?serviceKey=$_serviceKey'
        '&pageNo=1&numOfRows=1000&dataType=JSON'
        '&base_date=$baseDate&base_time=$baseTime&nx=$nx&ny=$ny');

    print('🌤️ Weather API 호출: $baseDate $baseTime');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['response']['body']['items']['item'] as List;

        final temp = _getItemValue(items, 'TMP', suffix: '°C');
        final humidity = _getItemValue(items, 'REH', suffix: '%');
        final windSpeed = _getItemValue(items, 'WSD', suffix: 'm/s');

        return {
          'TMP': temp,
          'REH': humidity,
          'WSD': windSpeed,
        };
      } else {
        print('❌ Weather API Error: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('❗ Weather API Exception: $e');
      return {};
    }
  }

  /// 발표 시각 기준 정리 (1일 8회 발표시간 기준 + 10분 반영)
  static Map<String, String> _getBaseDateTime() {
    final now = DateTime.now();

    // 발표 기준 시각 리스트
    final baseHours = [2, 5, 8, 11, 14, 17, 20, 23];
    DateTime? selected;

    for (int i = baseHours.length - 1; i >= 0; i--) {
      final hour = baseHours[i];
      final candidate = DateTime(now.year, now.month, now.day, hour, 10);
      if (now.isAfter(candidate)) {
        selected = DateTime(now.year, now.month, now.day, hour);
        break;
      }
    }

    // 자정 이전이면 전날 23시로
    selected ??= DateTime(now.year, now.month, now.day - 1, 23);

    final baseDate = '${selected.year.toString().padLeft(4, '0')}'
        '${selected.month.toString().padLeft(2, '0')}'
        '${selected.day.toString().padLeft(2, '0')}';

    final baseTime = '${selected.hour.toString().padLeft(2, '0')}00';

    return {'baseDate': baseDate, 'baseTime': baseTime};
  }

  static String? _getItemValue(List items, String category, {String suffix = ''}) {
    final item = items.firstWhere(
          (el) => el['category'] == category,
      orElse: () => null,
    );
    return item != null ? '${item['fcstValue']}$suffix' : null;
  }
}
