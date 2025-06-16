import 'package:flutter/foundation.dart';
import 'package:iot_dashboard/model/setting_model.dart';
import 'package:iot_dashboard/controller/setting_controller.dart';

class SettingService {
  static final ValueNotifier<SiteSetting?> settingNotifier = ValueNotifier(null);

  static SiteSetting? get setting => settingNotifier.value;

  /// 최초 로딩
  static Future<void> init() async {
    final setting = await SettingController.fetchLatestSetting();
    settingNotifier.value = setting;
  }

  /// 강제 리프레시
  static Future<void> refresh() async {
    final setting = await SettingController.fetchLatestSetting();
    settingNotifier.value = setting;
  }
}
