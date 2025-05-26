import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/theme/colors.dart';
import 'top_app_bar.dart';
import 'side_navigation_menu.dart';
import 'package:go_router/go_router.dart'; // ✅ 라우트 정보 얻기 위해 필요

class BaseLayout extends StatefulWidget {
  final Widget child;

  const BaseLayout({Key? key, required this.child}) : super(key: key);

  @override
  State<BaseLayout> createState() => _BaseLayoutState();
}

class _BaseLayoutState extends State<BaseLayout> {
  bool isMenuVisible = false;

  @override
  Widget build(BuildContext context) {

    final currentPath = GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;; // ✅ 현재 라우트 경로

    // ✅ 특정 페이지라면 white, 아니면 main2 색상
    final backgroundColor =
    currentPath.contains('/twin') ? Colors.white : AppColors.main2;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          TopAppBar(
            onMenuPressed: () {
              setState(() {
                isMenuVisible = !isMenuVisible;
              });
            },
            isMenuVisible: isMenuVisible, // ✅ 추가
          ),

          Expanded(
            child: Row(
              children: [
                // 👉 사이드 메뉴는 그대로
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: isMenuVisible ? 203.w : 0,
                  child: isMenuVisible
                      ? SideNavigationMenu(
                    onClose: () {
                      setState(() {
                        isMenuVisible = false;
                      });
                    },
                    routerContext: context,
                  )
                      : const SizedBox(),
                ),

                // 👉 오른쪽 콘텐츠에만 Stack을 적용
                Expanded(
                  child: Stack(
                    children: [
                      widget.child,

                      // ✅ 메뉴 열렸을 때만 오버레이
                      if (isMenuVisible)
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isMenuVisible = false;
                              });
                            },
                            child: Container(
                              color: Colors.black.withOpacity(0.4),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
