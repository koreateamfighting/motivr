import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'routes/router.dart';
import 'utils/setting_service.dart';
import 'package:iot_dashboard/theme/colors.dart';
import 'package:provider/provider.dart';
import 'package:iot_dashboard/controller/cctv_controller.dart';
import 'package:iot_dashboard/controller/iot_controller.dart';
import 'package:iot_dashboard/state/alarm_history_state.dart';
import 'package:iot_dashboard/state/notice_state.dart';
import 'package:iot_dashboard/state/work_task_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ 필수
  await SettingService.init();               // ✅ 서버에서 setting 불러오기
  // setUrlStrategy(PathUrlStrategy());      // (필요 시 주석 해제)

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CctvController()),
        ChangeNotifierProvider(create: (_) => IotController()),
        ChangeNotifierProvider(create: (_) => AlarmHistoryState()), // ✅ 추가
        ChangeNotifierProvider(create: (_) => NoticeState()),
        ChangeNotifierProvider(create: (_) => WorkTaskState()),

      ],
      child: const MyApp(),
    ),
  );
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
