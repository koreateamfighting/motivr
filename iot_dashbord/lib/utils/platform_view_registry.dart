// platform_view_registry.dart
// ✅ 플랫폼 별로 ui.platformViewRegistry 사용 가능하도록 설정

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'dart:ui' as ui;

void registerWebView(String viewId, html.IFrameElement iframe) {
  // 웹에서만 실행
  if (kIsWeb) {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewId, (int _) => iframe);
  }
}
