import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';

class CctvInfo {
  final String name;
  final String url;

  CctvInfo({required this.name, required this.url});
}

class CctvService {
  static const _apiKey = '34eabfc2efc84f728afa2b02c3491304'; // 🔑 본인 키로 교체

  static Future<List<CctvInfo>> fetchCctvList() async {
    final uri = Uri.parse(
      'https://openapi.its.go.kr:9443/cctvInfo'
          '?apiKey=$_apiKey&type=ex&cctvType=1&minX=126.8&maxX=127.9&minY=37.4&maxY=37.6&getType=xml',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) throw Exception("CCTV 요청 실패");

    final xml2json = Xml2Json();
    xml2json.parse(response.body);
    final jsonMap = jsonDecode(xml2json.toParker());

    final data = jsonMap['response']['data'];

    // data가 리스트인지 단일인지 판단
    final List<dynamic> cctvList = data is List ? data : [data];

    return cctvList
        .where((item) => item['cctvformat'] == 'HLS' && item['cctvurl'] != null)
        .map((item) => CctvInfo(
      name: item['cctvname'] ?? '이름 없음',
      url: item['cctvurl'],
    ))
        .toList();
  }
}
