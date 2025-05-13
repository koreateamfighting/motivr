// base_layout.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'top_app_bar.dart';
import 'side_navigation_menu.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          TopAppBar(
            onMenuPressed: () {
              setState(() {
                isMenuVisible = !isMenuVisible;
              });
            },
          ),
          Expanded(
            child: Row(
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: isMenuVisible ? 500.w : 0,
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
                Expanded(
                  child: widget.child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
