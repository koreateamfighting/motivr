import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/component/base_layout.dart';
import 'package:iot_dashboard/theme/colors.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(3812, 2144),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return BaseLayout(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ 대시보드 헤더
                Container(
                  height: 98.h,
                  color: AppColors.main2,
                  padding: EdgeInsets.symmetric(horizontal: 275.w),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/icons/color_clipboard.png',
                        width: 80.w,
                        height: 80.h,
                      ),
                      SizedBox(width: 20.w),
                      Text(
                        '세부현황',
                        style: TextStyle(
                          fontFamily: 'PretendardGOV',
                          fontWeight: FontWeight.w800,
                          fontSize: 48.sp,
                          color: Color(0xff3CBFAD),
                        ),
                      ),
                      SizedBox(width: 127.w),
                      Container(
                        width: 320.w,
                        height: 80.h,
                        decoration: BoxDecoration(
                          color: Color(0xff3cbfad),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: InkWell(
                          onTap: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  width: 40.w,
                                  height: 40.h,
                                  child: Image.asset('assets/icons/iot.png')),
                              SizedBox(
                                width: 36.w,
                              ),
                              Text(
                                'IoT',
                                style: TextStyle(
                                    fontFamily: 'PretendardGOV',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 48.sp,
                                    color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 1413.w),
                      Container(
                        width: 320.w,
                        height: 80.h,
                        decoration: BoxDecoration(
                          color: Color(0xff3cbfad),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: InkWell(
                          onTap: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                  width: 40.w,
                                  height: 40.h,
                                  child: Image.asset('assets/icons/cctv.png')),
                              Text(
                                'CCTV',
                                style: TextStyle(
                                    fontFamily: 'PretendardGOV',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 48.sp,
                                    color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // ✅ 헤더 하단 선
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 50.w),
                      width: 3712.w,
                      height: 2.h,
                      color: Color(0xff3CBFAD),
                    ),
                  ],
                ),
                SizedBox(
                  height: 73.h,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 203.w,
                    ),
                    Container(
                      width: 1124.w,
                      height: 80.h,
                      decoration: BoxDecoration(
                        color: Color(0xff414c67),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 16.w,),
                          Container(
                              width: 40.w,
                              height: 40.h,
                              child: Image.asset('assets/icons/location.png')),
                          SizedBox(width: 16.w,),
                          Text(
                            'IoT 위치',
                            style: TextStyle(
                                fontFamily: 'PretendardGOV',
                                fontWeight: FontWeight.w700,
                                fontSize: 36.sp,
                                color: Colors.white),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 28.w,
                    ),
                    Container(
                      width: 2404.w,
                      height: 80.h,
                      decoration: BoxDecoration(
                        color: Color(0xff414c67),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 16.w,),
                          Container(
                              width: 40.w,
                              height: 40.h,
                              child: Image.asset('assets/icons/iot.png')),
                          SizedBox(width: 16.w,),
                          Text(
                            'IoT 목록 테이블',
                            style: TextStyle(
                                fontFamily: 'PretendardGOV',
                                fontWeight: FontWeight.w700,
                                fontSize: 36.sp,
                                color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 52.h,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 203.w,
                    ),
                    Container(
                      width: 1121.w,
                      height: 1681.h,
                      color: Colors.grey,
                    ),
                    SizedBox(
                      width: 33.w,
                    ),
                    Expanded(
                        child: Container(
                      padding: EdgeInsets.only(right: 55.w),
                      height: 1681.h,
                      child: Container(
                        color: Colors.red,
                      ),
                    ))
                  ],
                )
              ],
            ),
          );
        });
  }
}
