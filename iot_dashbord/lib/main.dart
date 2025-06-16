import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'routes/router.dart';
import 'utils/setting_service.dart';
import 'package:iot_dashboard/theme/colors.dart';

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
      // ✅ 전역 텍스트 커서/선택 색상 설정
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.cursorColor,
          selectionColor: AppColors.cursorColor.withOpacity(0.3),
          selectionHandleColor: AppColors.cursorColor,
        ),
      ),
    );
  }
}
