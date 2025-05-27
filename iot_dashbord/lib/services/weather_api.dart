import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherApiService {
  static const String _apiKey = 'd373383c549894c6b07b71eb2ce1cd9c'; // 발급받은 API 키로 교체
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  static Future<Map<String, String?>> fetchWeatherData({String city = 'Daegu'}) async {
    final url = Uri.parse('$_baseUrl?q=$city&appid=$_apiKey&units=metric&lang=kr');
    //print("url은? ${url}");
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final tempRaw = data['main']['temp'];
        final temp = tempRaw != null ? '${tempRaw.toDouble().toInt()}' : null;
        final tempMinRaw = data['main']['temp_min'];
        final tempMaxRaw = data['main']['temp_max'];
        final tempMin = tempMinRaw != null ? '${tempMinRaw.toDouble().toInt()}' : null;
        final tempMax = tempMaxRaw != null ? '${tempMaxRaw.toDouble().toInt()}' : null;
        final humidity = data['main']['humidity']?.toString();
        final windSpeed = data['wind']['speed']?.toString();
        final pressure = data['main']['pressure']?.toString();

        return {
          'temperature': temp != null ? '$temp°C' : null,
          'tempMin': tempMin != null ? '$tempMin°C' : null,
          'tempMax': tempMax != null ? '$tempMax°C' : null,
          'humidity': humidity != null ? '$humidity%' : null,
          'windSpeed': windSpeed != null ? '$windSpeed m/s' : null,
          'pressure': pressure != null ? '$pressure hPa' : null,
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
}
