import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
Widget customRadio({
  required String value,
  required String groupValue,
  required ValueChanged<String?> onChanged,
  required String title,
  required String subtitle,
}) {
  final selected = value == groupValue;
  ScreenUtil.ensureScreenSize();

  return GestureDetector(
    onTap: () {
      // 이미 선택된 항목을 다시 탭하면 선택 해제 (null 전달)
      if (selected) {
        onChanged(null);
      } else {
        onChanged(value);
      }
    },
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 30.w,
          height: 30.h,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: selected ? Color(0xff3182ce) : Colors.white,
              width: 1.w,
            ),
            color: selected ? Color(0xff3182ce) : Colors.transparent,
          ),
          child: selected
              ? Icon(
            Icons.check,
            color: Colors.white,
            size: 15.sp,
          )
              : null,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 1020.w,
                height: 55.h,
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'PretendardGOV',
                    fontSize: 36.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'PretendardGOV',
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
