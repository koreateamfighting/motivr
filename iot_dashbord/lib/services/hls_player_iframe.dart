import 'dart:html' as html;
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iot_dashboard/constants/global_constants.dart';
class HlsPlayerIframe extends StatefulWidget {
  final String cam;
  const HlsPlayerIframe({super.key, this.cam = 'cam1'});

  @override
  State<HlsPlayerIframe> createState() => _HlsPlayerIframeState();
}

class _HlsPlayerIframeState extends State<HlsPlayerIframe> {
  late String _viewId;
  late String _iframeUrl;
  Timer? _reloadTimer;

  @override
  void initState() {
    super.initState();
    _refreshIframe();

    _reloadTimer = Timer.periodic(Duration(minutes: 60), (_) {
      if (mounted) {
        _refreshIframe();
      }
    });
  }

  void _refreshIframe() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _iframeUrl = '${baseUrl3030}/hls_player.html?cam=${widget.cam}&t=$timestamp';
    print('현재 cctv의 url :${_iframeUrl}');
    _viewId = 'hls-player-iframe-${widget.cam}-$timestamp';

    // re-register with a new viewId
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final iframe = html.IFrameElement()
        ..src = _iframeUrl
        ..style.border = 'none'
        ..allowFullscreen = true
        ..setAttribute('allowfullscreen', '');

      return iframe;
    });

    setState(() {}); // re-render with new viewId
  }

  @override
  void dispose() {
    _reloadTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewId);
  }
}
