import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SideNavigationMenu extends StatelessWidget {
  final void Function()? onClose;
  final BuildContext routerContext;

  const SideNavigationMenu({
    Key? key,
    this.onClose,
    required this.routerContext,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      // backgroundColor: Colors.transparent, // 투명하게
      child: Container(
        margin: EdgeInsets.only(top: 0.h), // ✅ 전체 위젯 자체를 아래로 이동
        color: const Color(0xFF0B2144),      // 내부 배경 적용
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMenuItem(context, Icons.dashboard, '대시보드', '/dashboard0'),
              _buildMenuItem(context, Icons.list_alt, '세부현황', '/detail'),
              _buildMenuItem(context, Icons.show_chart, '시계열데이터', '/timeseries'),
              _buildMenuItem(context, Icons.settings_input_component, '디지털트윈', '/twin'),
              _buildMenuItem(context, Icons.admin_panel_settings, '관리자', '/admin'),
              const Spacer(),
              IconButton(
                onPressed: onClose ?? () => Navigator.pop(context),
                icon: const Icon(Icons.chevron_left, color: Colors.white),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildMenuItem(BuildContext context, IconData icon, String title, String routePath) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: InkWell(
        onTap: () {
          print("이동 경로: $routePath");
          GoRouter.of(context).go(routePath);
        },
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 32.sp),
            SizedBox(width: 16.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 28.sp,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}
