import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class UnityWebGLFrame extends StatefulWidget {
  const UnityWebGLFrame({Key? key}) : super(key: key);

  @override
  State<UnityWebGLFrame> createState() => _UnityWebGLFrameState();
}

class _UnityWebGLFrameState extends State<UnityWebGLFrame> {
  late final html.IFrameElement _iframe;

  @override
  void initState() {
    super.initState();

    // ✅ 핵심: iframe이 부모 크기를 제대로 채우도록 스타일을 명시
    _iframe = html.IFrameElement()
      ..src = '/unity_build/index.html'
      ..style.border = 'none'
      ..style.position = 'absolute' // 중요
      ..style.top = '0'
      ..style.left = '0'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.margin = '0'
      ..style.padding = '0'
      ..style.display = 'block'
      ..allowFullscreen = true;

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'unity-webgl-iframe',
          (int viewId) => _iframe,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Stack(
            children: [
              Positioned.fill( // ✅ 부모의 크기 기준으로 iframe 꽉 채우기
                child: HtmlElementView(viewType: 'unity-webgl-iframe'),
              ),
            ],
          ),
        );
      },
    );
  }
}
