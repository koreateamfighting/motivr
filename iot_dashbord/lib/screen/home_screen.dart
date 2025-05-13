// import 'package:flutter/material.dart';
// import 'dart:html' as html;
// import 'dart:ui' as ui; // 반드시 필요!
//
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Column(
//         children: [
//           Text(
//             '대시보드 테스트 20250512',
//             style: TextStyle(
//               fontFamily: 'PretendardGOV',
//               fontWeight: FontWeight.w700, // PretendardGOV-Bold.ttf 사용
//               fontSize: 20,
//               color: Color(0xffa0aec0),
//             ),
//           ),
//           Expanded(child: UnityWebGLFrame()),
//         ],
//       ),
//     );
//   }
// }
//
// // Unity WebGL iframe을 보여주는 위젯
// class UnityWebGLFrame extends StatelessWidget {
//   const UnityWebGLFrame({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final iframe = html.IFrameElement()
//       ..src = '/unity_build/index.html' // Unity WebGL 경로
//       ..style.border = 'none'
//       ..style.width = '100%'
//       ..style.height = '100%'
//       ..allowFullscreen = true;
//
//     // ignore: undefined_prefixed_name
//     ui.platformViewRegistry.registerViewFactory(
//       'unity-webgl-iframe',
//           (int viewId) => iframe,
//     );
//
//     return const HtmlElementView(viewType: 'unity-webgl-iframe');
//   }
// }
