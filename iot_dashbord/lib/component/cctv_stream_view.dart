import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class CctvStreamView extends StatelessWidget {
  final String videoPageUrl; // 예: '/hls_player.html'

  const CctvStreamView({super.key, required this.videoPageUrl});

  @override
  Widget build(BuildContext context) {
    final viewId = 'iframe-${videoPageUrl.hashCode}';

    final iframeElement = html.IFrameElement()
      ..src = videoPageUrl
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..setAttribute('allowfullscreen', '') // ✅ 이거 꼭 필요
      ..allowFullscreen = true; // ✅ 전체화면 허용

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewId, (int viewId) => iframeElement);

    return HtmlElementView(viewType: viewId);
  }
}
