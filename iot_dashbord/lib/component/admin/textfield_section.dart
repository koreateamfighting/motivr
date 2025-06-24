import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/theme/colors.dart';


Widget labeledTextField(
    {final String? title,
      String? hint,
      required double width,
      required double height,
      required double textBoxwidth,
      required double textBoxHeight,
      TextEditingController? controller,
    bool enabled = true}) {
  ScreenUtil.ensureScreenSize();
  return Container(
    child: Row(
      children: [
        if( title != null) ...[
          SizedBox(
            width: 41.w,
          ),
          Container(
            width: textBoxwidth.w,
            height: textBoxHeight.h,
            alignment: Alignment.centerLeft,
            child: Text(
              title!,
              style: TextStyle(
                fontFamily: 'PretendardGOV',
                fontSize: 36.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 12.h),
        ],
        Container(
            width: width.w,
            height: height.h,
            child: TextField(
              enabled: enabled,
              controller: controller,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: hint ?? '',
                hintStyle: TextStyle(
                    color: Color(0xff9eaea2),
                    fontSize: 36.sp,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'PretendardGOV'),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: AppColors.focusedBorder(2.w),
                // ✅ 여기에 적용
                contentPadding:
                EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
              ),
            )),
      ],
    ),
  );
}