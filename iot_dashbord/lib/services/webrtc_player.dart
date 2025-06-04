import 'dart:ui' as ui;
import 'dart:html' as html;
import 'package:flutter/material.dart';

class WebRTCPlayer extends StatelessWidget {
  final String streamName;

  const WebRTCPlayer({Key? key, required this.streamName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String viewId = 'webrtc-player-$streamName';

    final iframe = html.IFrameElement()
      ..src = 'http://hanlimtwin.kr:3001'
      ..style.border = 'none'
      ..allowFullscreen = true;

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewId, (int viewId) => iframe);

    return HtmlElementView(viewType: viewId);
  }
}
