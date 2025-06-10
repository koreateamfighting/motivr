import 'package:flutter/material.dart';
import 'package:iot_dashboard/component/dialog_form.dart';
import 'package:go_router/go_router.dart';

class ForbiddenScreen extends StatelessWidget {
  const ForbiddenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 다이얼로그는 다음 프레임에서 띄우기
    Future.microtask(() {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => DialogForm(mainText: "관리자 계정만 접근 가능합니다.", btnText: "닫기"),
      ).then((_) {
        context.go('/dashboard0'); // 확인 누르면 다른 곳으로 이동
      });
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox.shrink(), // 화면 자체는 빈 상태
    );
  }
}
