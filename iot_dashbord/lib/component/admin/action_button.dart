import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget ActionButton(String label, Color color, {VoidCallback? onTap}) {
  return InkWell(
    onTap: onTap, // ✅ 외부에서 동작 주입
    child: Container(
      width: 103.w,
      height: 60.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 30.sp,
          fontWeight: FontWeight.w700,
          fontFamily: 'PretendardGOV',
          color: Colors.white,
        ),
      ),
    ),
  );
}
