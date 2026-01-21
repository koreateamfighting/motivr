import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget sectionTitle(String title) {
  ScreenUtil.ensureScreenSize();
  return Container(
    width: 2880.w,
    height: 70.h,
    decoration: BoxDecoration(    borderRadius: BorderRadius.circular(5.r),color: Color(0xff414c67),),
    child: Row(
      children: [
        SizedBox(width: 41.w),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'PretendardGOV',
            fontSize: 36.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Spacer(),
        Container(
          width: 30.w,
          height: 15.h,
          child: InkWell(
            onTap: () {},
            child: Image.asset('assets/icons/arrow_down.png'),
          ),
        ),
        SizedBox(
          width: 55.w,
        )
      ],
    ),
  );
}
