import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui' as ui; // 반드시 필요!
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'home_screen.dart';
import 'dashboard_screen.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static const designWidth = 3812;
  static const designHeight = 2144;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(designWidth.toDouble(), designHeight.toDouble()),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                children: [
                  Container(
                      width: designWidth.toDouble(),
                      height: 100.h,
                      color: Color(0xff0b2144),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 275.w,
                          ),
                          Text(
                            'Digital Twin CMS',
                            style: TextStyle(
                              fontFamily: 'PretendardGOV',
                              fontWeight: FontWeight.w800,
                              fontSize: 40.sp,
                              color: Color(0xffffffff),
                            ),
                          ),
                        ],
                      )),
                  SizedBox(
                    height: 70.h,
                  ),
                  Container(
                    width: 1406.w,
                    height: 372.h,
                    child: Image.asset('assets/images/company_logo.png'),
                  ),
                  SizedBox(
                    height: 16.h,
                  ),
                  Text(
                    'Digital Twin CMS',
                    style: TextStyle(
                      fontFamily: 'PretendardGOV',
                      fontWeight: FontWeight.w800,
                      fontSize: 96.sp,
                      color: Color(0xff0B2144),
                    ),
                  ),
                  SizedBox(
                    height: 36.h,
                  ),
                  Text(
                    '안녕하세요',
                    style: TextStyle(
                      fontFamily: 'PretendardGOV',
                      fontWeight: FontWeight.w400,
                      fontSize: 64.sp,
                      color: Color(0xffa0aec0),
                    ),
                  ),
                  SizedBox(
                    height: 64.h,
                  ),
                  Text(
                    '회원서비스 이용을 위해 로그인해주시기 바랍니다.',
                    style: TextStyle(
                      fontFamily: 'PretendardGOV',
                      fontWeight: FontWeight.w400,
                      fontSize: 64.sp,
                      color: Color(0xffa0aec0),
                    ),
                  ),
                  Container(
                    width: 809.w,
                    height: 953.h,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFA0AEC0),
                        width: 2.w,
                      ),
                      borderRadius: BorderRadius.circular(20.r), // 선택사항: 둥근 테두리
                    ),
                    child: Center(
                        child: Column(
                      children: [
                        SizedBox(
                          height: 65.h,
                        ),
                        Text(
                          'Welcome!',
                          style: TextStyle(
                            fontFamily: 'PretendardGOV',
                            fontWeight: FontWeight.w700,
                            fontSize: 32.sp,
                            color: Color(0xff2d3748),
                          ),
                        ),
                        SizedBox(
                          height: 75.h,
                        ),
                        Container(
                          width: 600.w,
                          child: Text(
                            'Name',
                            style: TextStyle(
                              fontFamily: 'PretendardGOV',
                              fontWeight: FontWeight.w400,
                              fontSize: 14.sp,
                              color: Color(0xff2d3748),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 7.96.h,
                        ),
                        Container(
                          width: 600.w,
                          height: 80.h,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          // 내부 여백(optional)
                          decoration: BoxDecoration(
                            color: Colors.white, // 배경색(optional)
                            border: Border.all(
                              color: const Color(0xFFE2E8F0), // 외곽선 색
                              width: 1.w, // 외곽선 두께
                            ),
                            borderRadius: BorderRadius.circular(8.r), // 둥근 모서리
                          ),
                          child: Center(
                            child: TextField(
                              decoration: const InputDecoration(
                                border: InputBorder.none, // 밑줄 제거
                                hintText: "아이디", // optional
                              ),
                              style: TextStyle(fontSize: 36.sp,color: Color(0xffA0AEC0)),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 29.87.h,
                        ),
                        Container(
                          width: 600.w,
                          child: Text(
                            'Password',
                            style: TextStyle(
                              fontFamily: 'PretendardGOV',
                              fontWeight: FontWeight.w400,
                              fontSize: 14.sp,
                              color: Color(0xff2d3748),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 7.96.h,
                        ),
                        Container(
                          width: 600.w,
                          height: 80.h,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          // 내부 여백(optional)
                          decoration: BoxDecoration(
                            color: Colors.white, // 배경색(optional)
                            border: Border.all(
                              color: const Color(0xFFE2E8F0), // 외곽선 색
                              width: 1.w, // 외곽선 두께
                            ),
                            borderRadius: BorderRadius.circular(8.r), // 둥근 모서리
                          ),
                          child: Center(
                            child: TextField(
                              decoration: const InputDecoration(
                                border: InputBorder.none, // 밑줄 제거
                                hintText: "비밀번호", // optional
                              ),
                              style: TextStyle(fontSize: 36.sp,color: Color(0xffA0AEC0)),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 123.h,
                        ),
                        Container(
                            width: 600.w,
                            height: 80.h,
                            padding: EdgeInsets.only(top:16.h,bottom: 16.h),
                            decoration: BoxDecoration(
                              color: Color(0xff2d3748),

                              borderRadius:
                                  BorderRadius.circular(8.r), // 둥근 모서리
                            ),
                            child: InkWell(
                              onTap: () {
                                context.go('/dashboard0'); // 또는 push
                              },
                              child: (Text(
                                '로그인',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'PretendardGOV',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 36.sp,
                                  color: Color(0xffFFFFFF),
                                ),
                              )),
                            ))
                      ],
                    )),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
