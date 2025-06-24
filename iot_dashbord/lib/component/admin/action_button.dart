import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget ActionButton(String label, Color color) {
  return InkWell(
    onTap: () {}, // TODO: 기능 연결
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
