import 'dart:html' as html;
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/material.dart';

class OpencvCctvIframe extends StatefulWidget {
  final String cam;
  const OpencvCctvIframe({super.key, this.cam = 'cam1'});

  @override
  State<OpencvCctvIframe> createState() => _OpencvCctvIframeState();
}

class _OpencvCctvIframeState extends State<OpencvCctvIframe> {
  //static const refreshSeconds = 10;
  late final String _viewId;
  late html.ImageElement _imgElement;
  //Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _viewId = 'opencv-cam-${widget.cam}';
    _imgElement = html.ImageElement()
      ..style.border = 'none'
      ..style.width = '100%'
      ..alt = 'CCTV 감지 영상';

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(_viewId, (int viewId) => _imgElement);

    // 초기 이미지 + 타이머 시작
    _updateImage();
    // _refreshTimer = Timer.periodic(
    //   const Duration(seconds: refreshSeconds),
    //       (_) => _updateImage(),
    // );
  }

  void _updateImage() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final newUrl = 'https://hanlimtwin.kr:5002/stream/${widget.cam}?t=$timestamp';
    _imgElement.src = newUrl;
  }

  @override
  void dispose() {
    //_refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewId);
  }
}
