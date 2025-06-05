import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget AlarmHistroy() {
  ScreenUtil.ensureScreenSize();
  return Container(
    width: 729.w,
    height: 1632.h,
    decoration: BoxDecoration(
      color: Color(0xff0b1437),
      borderRadius: BorderRadius.circular(5.r),
      border: Border.all(color: Color(0xff414c67), width: 4.w),
    ),
    child: Column(
      children: [
        Container(
          width: double.infinity,
          height: 100.h,
          decoration: BoxDecoration(
            color: Color(0xff414c67),
            border: Border(
              top: BorderSide(color: Colors.white, width: 2.w),
              // 위쪽 선
              left: BorderSide(color: Colors.white, width: 2.w),
              //  왼쪽 선
              right: BorderSide(color: Colors.white, width: 2.w), // 오른쪽 선
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 12.w,
              ),
              Container(
                width: 50.w,
                height: 50.h,
                child: Image.asset('assets/icons/clock2.png'),
              ),
              SizedBox(
                width: 11.w,
              ),
              Container(
                  width: 241.w,
                  height: 50.h,
                  child: Text(
                    '알람 히스토리',
                    style: TextStyle(
                      fontSize: 36.sp,
                      fontFamily: 'PretendardGOV',
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  )),
            ],
          ),
        ),
        Container(
            width: double.infinity,
            height: 100.h,
            decoration: BoxDecoration(
              color: Color(0xff3182ce),
              border: Border(
                bottom: BorderSide(color: Colors.white, width: 2.w),
                // 위쪽 선
                left: BorderSide(color: Colors.white, width: 2.w),
                //  왼쪽 선
                right: BorderSide(color: Colors.white, width: 2.w), // 오른쪽 선
              ),
            ),
            child: Center(
              child: Text(
                '[                      ]',
                style: TextStyle(
                  fontSize: 36.sp,
                  fontFamily: 'PretendardGOV',
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )),
        Container(
          width: double.infinity,
          height: 100.h,
          decoration: BoxDecoration(
            color: Color(0xff414c67),
            border: Border(
              top: BorderSide(color: Colors.white, width: 2.w),
              bottom: BorderSide(color: Colors.white, width: 2.w),
              // 위쪽 선
              left: BorderSide(color: Colors.white, width: 2.w),
              //  왼쪽 선
              right: BorderSide(color: Colors.white, width: 2.w), // 오른쪽 선
            ),
          ),
          child: Row(
            children: [
              Container(
                  width: 290.w,
                  height: 80.h,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '날짜/시간',
                    style: TextStyle(
                      fontSize: 36.sp,
                      fontFamily: 'PretendardGOV',
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  )),
              SizedBox(
                width: 181.w,
              ),
              Container(
                  width: 200.w,
                  height: 80.h,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '이벤트',
                    style: TextStyle(
                      fontSize: 36.sp,
                      fontFamily: 'PretendardGOV',
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  )),
            ],
          ),
        ),
      ],
    ),
  );
}
