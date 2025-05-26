import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iot_dashboard/theme/colors.dart';

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
    final currentPath =
        GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;

    return Container(
      // backgroundColor: Colors.transparent, // 투명하게
      child: Container(
        margin: EdgeInsets.only(top: 0.h), // ✅ 전체 위젯 자체를 아래로 이동
        color: Color(0xff0b1437),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 140.h,
              ),
              _buildMenuItem(
                  context, 'dashboard', '대시보드', '/dashboard0', currentPath),
              SizedBox(
                height: 85.h,
              ),
              _buildMenuItem(
                  context, 'clipboard', '세부현황', '/detail', currentPath),
              SizedBox(
                height: 85.h,
              ),
              _buildMenuItem(context, 'vector', '시계열데이터', '/timeseries',
                  currentPath),
              SizedBox(
                height: 100.h,
              ),
              _buildMenuItem(context, 'cube', '디지털트윈',
                  '/twin', currentPath),
              SizedBox(
                height: 100.h,
              ),
              _buildMenuItem(context, 'setting', '관리자',
                  '/admin', currentPath),
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

  Widget _buildMenuItem(
    BuildContext context,
    String iconName,
    String title,
    String routePath,
    String currentPath, // ✅ 현재 경로 전달
  ) {
    final isSelected = currentPath == routePath;
    final Color activeColor = Color(0xFF3182ce);
    final iconAsset = isSelected
        ? 'assets/icons/color_$iconName.png'
        : 'assets/icons/uncolor_$iconName.png';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: InkWell(
        onTap: () {
          print("이동 경로: $routePath");
          GoRouter.of(context).go(routePath);
        },
        child: Center(
          child: Column(
            children: [
              Image.asset(
                iconAsset,
                width: 80.w, // 적절한 크기로 조절
                height: 80.h,
              ),
              SizedBox(height: 28.h,),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PretendardGOV',
                  fontSize: 30.sp,
                  color: isSelected ? activeColor : Colors.white,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
