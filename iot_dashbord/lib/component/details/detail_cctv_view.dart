// detail_iot_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DetailCctvView extends StatelessWidget {
  const DetailCctvView({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 3672.w,
          height: 1775.h,
          color: Color(0xff1b254b),
          padding: EdgeInsets.only(top: 15.h, left: 14.w),
          child: Column(
            children: [
              Container(
                width: 3649.w,
                height: 82.h,
                decoration: BoxDecoration(
                  color: Color(0xff414c67),
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 18.8.w,
                    ),
                    Container(
                      width: 45.44.w,
                      height: 41.h,
                      child: Image.asset('assets/icons/cctv.png'),
                    ),
                    SizedBox(
                      width: 60.w,
                    ),
                    Text(
                      'CCTV 테이블',
                      style: TextStyle(
                        fontFamily: 'PretendardGOV',
                        fontWeight: FontWeight.w700,
                        fontSize: 36.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 16.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 813.w,
                    height: 1632.h,
                    child: Column(
                      children: [
                        Container(
                          width: 799.w,
                          height: 100.h,
                          decoration: BoxDecoration(
                            color: Color(0xff414c67),
                            border: Border(
                              top: BorderSide(color: Colors.white, width: 2.w),
                              // 위쪽 선
                              left: BorderSide(color: Colors.white, width: 2.w),
                              //  왼쪽 선
                              right: BorderSide(
                                  color: Colors.white, width: 2.w), // 오른쪽 선
                            ),
                          ),
                        ),
                        Container(
                          width: 799.w,
                          height: 1432.h,
                          decoration: BoxDecoration(
                            color: Color(0xff0b1437),
                            border: Border(
                              top: BorderSide(color: Colors.white, width: 2.w),
                              // 위쪽 선
                              left: BorderSide(color: Colors.white, width: 2.w),
                              //  왼쪽 선
                              right: BorderSide(
                                  color: Colors.white, width: 2.w), // 오른쪽 선
                            ),
                          ),
                        ),
                        Expanded(
                            child: Container(
                          width: 799.w,
                          decoration: BoxDecoration(
                            color: Color(0xff414c67),
                            border: Border.all(color: Colors.white, width: 2.w),
                          ),
                        ))
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 20.w,
                  ),
                  Container(
                    width: 2818.w,
                    height: 1632.h,
                    padding:
                        EdgeInsets.only(left: 10.w, right: 13.w, top: 12.h),
                    child: Column(
                      children: [
                        Container(
                          width: 2798.w,
                          height: 300.h,
                          decoration: BoxDecoration(
                            color: Color(0xff0b1437),
                            border: Border.all(color: Colors.white, width: 1.w),
                          ),
                        ),
                        SizedBox(height: 25.h,),
                        Row(
                          children: [
                            Container(
                              width: 2271.w,
                              height: 1295.h,
                              color: Colors.white,
                            ),
                            SizedBox(width: 56.w,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(height: 162.h),
                                Container(
                                  width: 356.w,
                                  height: 618.h,
                                  color: Colors.yellow,
                                ),
                                SizedBox(height: 175.h,),
                                Container(
                                  width: 435.81.w,
                                  height: 327.h,
                                  color: Colors.grey,
                                ),
                              ],
                            )

                          ],
                        )
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
