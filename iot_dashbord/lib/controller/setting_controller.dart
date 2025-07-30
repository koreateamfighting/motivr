import 'dart:async';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:iot_dashboard/model/setting_model.dart'; // 위에서 만든 모델
import 'dart:convert';
import 'package:iot_dashboard/utils/setting_service.dart';
import 'package:iot_dashboard/constants/global_constants.dart';
class SettingController {
  static Future<SettingUploadResult> uploadTitleAndLogo(String title, html.File? logoFile) async {
    try {
      final uri = Uri.parse('${baseUrl3030}/update-settings');
      final request = http.MultipartRequest('POST', uri);

      // 기존 title 유지
      final trimmedTitle = title.trim();
      if (trimmedTitle.isEmpty && SettingService.setting?.title != null) {
        request.fields['title'] = SettingService.setting!.title!;
      } else {
        request.fields['title'] = trimmedTitle;
      }

      if (logoFile != null) {
        final reader = html.FileReader();
        final completer = Completer<Uint8List>();

        reader.readAsArrayBuffer(logoFile);
        reader.onLoadEnd.listen((_) {
          completer.complete(reader.result as Uint8List);
        });
        reader.onError.listen((e) => completer.completeError(e));

        final bytes = await completer.future;

        request.files.add(http.MultipartFile.fromBytes(
          'logo',
          bytes,
          filename: logoFile.name,
          contentType: MediaType('image', 'png'),
        ));
      }

      final response = await request.send();
      if (response.statusCode == 200) {
        return SettingUploadResult(success: true, message: '업로드 성공');
      } else {
        return SettingUploadResult(success: false, message: '업로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      return SettingUploadResult(success: false, message: '오류: $e');
    }
  }



  static Future<SiteSetting?> fetchLatestSetting() async {
    try {
      final uri = Uri.parse('${baseUrl3030}/get-settings');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SiteSetting.fromJson(data);
      } else {
        print('❌ 설정 조회 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ 네트워크 오류: $e');
      return null;
    }
  }

}
