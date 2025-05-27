import 'dart:ui' as ui;
import 'dart:html' as html;
import 'package:flutter/material.dart';

class HlsPlayerIframe extends StatelessWidget {
  final String cam;

  const HlsPlayerIframe({super.key, this.cam = 'cam1'});

  @override
  Widget build(BuildContext context) {
    final String viewId = 'hls-player-iframe-$cam';

    final iframe = html.IFrameElement()
      ..src = 'https://hanlimtwin.kr:3030/hls_player.html?cam=$cam'
      ..style.border = 'none'
      ..allowFullscreen = true // ✅ 핵심
      ..setAttribute('allowfullscreen', ''); // ✅ 일부 브라우저 대응

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewId, (int viewId) => iframe);

    return HtmlElementView(viewType: viewId);
  }
}