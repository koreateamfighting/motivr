import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class CctvStreamView extends StatelessWidget {
  final String videoUrl;

  const CctvStreamView({super.key, required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    final viewId = 'video-${videoUrl.hashCode}';

    final videoElement = html.VideoElement()
      ..src = videoUrl
      ..autoplay = true
      ..controls = true
      ..muted = true
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover';

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewId, (int viewId) => videoElement);

    return HtmlElementView(viewType: viewId);
  }
}
