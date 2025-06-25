import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iot_dashboard/model/special_sensor_model.dart';

class SpecialSensorController {
  static const String baseUrl = 'https://hanlimtwin.kr:3030/api';

  static Future<bool> upsertSensorData(SpecialSensorData data) async {
    final url = Uri.parse('$baseUrl/specialsensor');
    final body = json.encode(data.toJson());

    try {
      final response = await http.post(url, headers: {
        'Content-Type': 'application/json',
      }, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Failed to save sensor data: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Exception during save sensor data: $e');
      return false;
    }
  }

// 필요하면 get / list API도 구현 가능
}
