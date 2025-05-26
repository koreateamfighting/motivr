// admin_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/component/base_layout.dart';
import 'package:iot_dashboard/theme/colors.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

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
                Container(
                  height: 98.h,
                  color: AppColors.main2,
                  padding: EdgeInsets.symmetric(horizontal: 275.w),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/icons/color_setting.png',
                        width: 80.w,
                        height: 80.h,
                      ),
                      SizedBox(width: 20.w),
                      Text(
                        '관리자',
                        style: TextStyle(
                          fontFamily: 'PretendardGOV',
                          fontWeight: FontWeight.w800,
                          fontSize: 48.sp,
                          color: Color(0xff3CBFAD),
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
                  height: 27.h,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: Column(
                        children: [
                          Container(
                            width: 2880.w,
                            height: 70.h,
                            decoration: BoxDecoration(
                              color: Color(0xff414c67),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 11.w,
                                ),
                                Container(
                                  width: 50.w,
                                  height: 50.h,
                                  child:
                                      Image.asset('assets/icons/profile.png'),
                                ),
                                SizedBox(
                                  width: 45.w,
                                ),
                                Text(
                                  '관리자 설정 입력',
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
                          Container(
                            width: 2880.w,
                            height: 1757.h,
                            color: Colors.brown,
                          ),
                          InkWell(
                              onTap: () {},
                              child: Container(
                                width: 2880.w,
                                height: 60.h,
                                padding: EdgeInsets.only(bottom:4.h),
                                decoration: BoxDecoration(
                                  color: Color(0xff5664d2),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 40.w,
                                      height: 40.h,
                                      child: Icon(
                                        Icons.file_upload_outlined,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 7.w,),
                                    Text(
                                      '모든 정보 저장',
                                      style: TextStyle(
                                        fontFamily: 'PretendardGOV',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 36.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                    
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }
}
