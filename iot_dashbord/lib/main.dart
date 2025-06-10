import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'services/router.dart';
import 'services/setting_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ 필수
  await SettingService.init();               // ✅ 서버에서 setting 불러오기
  // setUrlStrategy(PathUrlStrategy());      // (필요 시 주석 해제)
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(

      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
