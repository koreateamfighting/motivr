import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


Widget buildTab(
    {required String label,
      required String imageName,
      required bool isSelected}) {
  ScreenUtil.ensureScreenSize();
  return Container(
      height: 95.h,
      decoration: BoxDecoration(
        color: isSelected ? Color(0xff3182ce) : Color(0xff1b254b),
        border:  isSelected
            ? null
            : Border(
          top: BorderSide(color: Color(0xff3182ce), width: 4.w),
          left: BorderSide(color: Color(0xff3182ce), width: 4.w),
          right: BorderSide(color: Color(0xff3182ce), width: 4.w),
          bottom: BorderSide.none, // ✅ 하단 테두리 제거
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.r),
          topRight: Radius.circular(10.r),
        ),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50.w,
            height: 50.h,
            child: Image.asset('assets/icons/${imageName}.png'),
          ),
          SizedBox(
            width: 8.w,
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'PretendardGOV',
              fontSize: 48.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ));
}