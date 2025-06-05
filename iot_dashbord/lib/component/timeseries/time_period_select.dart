import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget TimePeriodSelect(){
  ScreenUtil.ensureScreenSize();
  return   Container(
    width: 3680.w,
    height: 100.h,
    decoration: BoxDecoration(
      color: Color(0xff414c67),
      borderRadius: BorderRadius.all(
        Radius.circular(5.r),
      ),
    ),
    child: Row(
      children: [
        SizedBox(
          width: 24.w,
        ),
        Container(
          width: 50.w,
          height: 50.h,
          child: Image.asset('assets/icons/calendar.png'),
        ),
        SizedBox(
          width: 11.w,
        ),
        Container(
          width: 141.w,
          height: 50.h,
          child: Text(
            '기간 선택',
            style: TextStyle(
              fontFamily: 'PretendardGOV',
              fontWeight: FontWeight.w700,
              fontSize: 36.sp,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          width: 6.w,
        ),
        InkWell(
          onTap: () {},
          child: Container(
            width: 106.98.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: Color(0xff414c67),
              border: Border.all(
                  color: Color(0xff3182ce), width: 1.w),
              borderRadius: BorderRadius.circular(5.r),
            ),
            alignment: Alignment.center,
            child: Text(
              '오늘',
              style: TextStyle(
                fontFamily: 'PretendardGOV',
                fontWeight: FontWeight.w400,
                fontSize: 32.sp,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 9.9.w,
        ),
        InkWell(
          onTap: () {},
          child: Container(
            width: 106.98.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: Color(0xff414c67),
              border: Border.all(
                  color: Color(0xff3182ce), width: 1.w),
              borderRadius: BorderRadius.circular(5.r),
            ),
            alignment: Alignment.center,
            child: Text(
              '1주',
              style: TextStyle(
                fontFamily: 'PretendardGOV',
                fontWeight: FontWeight.w400,
                fontSize: 32.sp,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 9.9.w,
        ),
        InkWell(
          onTap: () {},
          child: Container(
            width: 106.98.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: Color(0xff414c67),
              border: Border.all(
                  color: Color(0xff3182ce), width: 1.w),
              borderRadius: BorderRadius.circular(5.r),
            ),
            alignment: Alignment.center,
            child: Text(
              '1개월',
              style: TextStyle(
                fontFamily: 'PretendardGOV',
                fontWeight: FontWeight.w400,
                fontSize: 32.sp,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 15.w,
        ),
        InkWell(
          onTap: () {},
          child: Row(
            children: [
              Container(
                width: 288.w,
                height: 60.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5.r),
                ),
              ),
              SizedBox(
                width: 15.w,
              ),
              Text(
                '~',
                style: TextStyle(
                  fontFamily: 'PretendardGOV',
                  fontWeight: FontWeight.w700,
                  fontSize: 36.sp,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                width: 15.w,
              ),
              Container(
                width: 288.w,
                height: 60.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5.r),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 54.w,
        ),
        Container(
          width: 50.w,
          height: 50.h,
          child: Image.asset('assets/icons/clock.png'),
        ),
        SizedBox(
          width: 14.w,
        ),
        Container(
          width: 141.w,
          height: 50.h,
          child: Text(
            '시간 선택',
            style: TextStyle(
              fontFamily: 'PretendardGOV',
              fontWeight: FontWeight.w700,
              fontSize: 36.sp,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          width: 17.w,
        ),
        Container(
          width: 80.w,
          height: 60.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.r),
          ),
        ),
        SizedBox(
          width: 8.w,
        ),
        Text(
          ':',
          style: TextStyle(
            fontFamily: 'PretendardGOV',
            fontWeight: FontWeight.w700,
            fontSize: 36.sp,
            color: Colors.white,
          ),
        ),
        SizedBox(
          width: 8.w,
        ),
        Container(
          width: 80.w,
          height: 60.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.r),
          ),
        ),
        SizedBox(
          width: 15.w,
        ),
        Text(
          '~',
          style: TextStyle(
            fontFamily: 'PretendardGOV',
            fontWeight: FontWeight.w700,
            fontSize: 36.sp,
            color: Colors.white,
          ),
        ),
        SizedBox(
          width: 15.w,
        ),
        Container(
          width: 80.w,
          height: 60.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.r),
          ),
        ),
        SizedBox(
          width: 8.w,
        ),
        Text(
          ':',
          style: TextStyle(
            fontFamily: 'PretendardGOV',
            fontWeight: FontWeight.w700,
            fontSize: 36.sp,
            color: Colors.white,
          ),
        ),
        SizedBox(
          width: 8.w,
        ),
        Container(
          width: 80.w,
          height: 60.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.r),
          ),
        ),
        SizedBox(
          width: 95.w,
        ),
        Container(
          width: 100.w,
          height: 60.h,
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: () async {}, // 비어있는 onPressed
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff3182ce),
              // 파란색
              padding: EdgeInsets.symmetric(
                  horizontal: 20.w, vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
            ),
            child: Text(
              '조회',
              style: TextStyle(
                fontSize: 32.sp,
                fontFamily: 'PretendardGOV',
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 1180.w,
        ),
        Container(
          width: 230.w,
          height: 60.h,
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: () async {}, // 비어있는 onPressed
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff3182ce),
              // 파란색
              padding: EdgeInsets.symmetric(
                  horizontal: 20.w, vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
            ),
            child: Text(
              '다운로드',
              style: TextStyle(
                fontSize: 32.sp,
                fontFamily: 'PretendardGOV',
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 30.w,
        ),
        Container(
          width: 55.w,
          height: 55.h,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(5.r),
            border:
            Border.all(color: Colors.white, width: 2.w),
          ),
        )
      ],
    ),
  );

}