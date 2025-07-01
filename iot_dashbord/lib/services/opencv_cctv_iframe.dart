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
  late String _viewId;
  late String _imageUrl;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    print('📸 전달된 cam 값: ${widget.cam}'); // ✅ 여기서 확인 가능
    _updateImage();

    // 💡 1분마다 새로고침 (타이머로 감지 프레임 리프레시)
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted) {
        _updateImage();
      }
    });
  }

  void _updateImage() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _imageUrl = 'https://hanlimtwin.kr:5001/preview/${widget.cam}?t=$timestamp'; // 🟢 캐시 방지용 쿼리
    _viewId = 'opencv-preview-${widget.cam}-$timestamp';

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final img = html.ImageElement()
        ..src = _imageUrl
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..alt = 'OpenCV 감지 영상';

      return img;
    });

    setState(() {});
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewId);
  }
}
