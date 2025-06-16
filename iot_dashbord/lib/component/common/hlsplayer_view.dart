import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class HlsPlayerView extends StatelessWidget {
  final String videoUrl;

  const HlsPlayerView({super.key, required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    final viewId = 'hls-player-${videoUrl.hashCode}';
    final iframe = html.IFrameElement()
      ..src = 'assets/html/cctv_player.html?url=${Uri.encodeComponent(videoUrl)}'
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allowFullscreen = true;

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewId, (int _) => iframe);

    return HtmlElementView(viewType: viewId);
  }
}
