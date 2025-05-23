import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iot_dashbord/component/register.dart';
import 'package:iot_dashbord/theme/colors.dart'; // ✅ 추가

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
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/background_image.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/background_color.png',
                      fit: BoxFit.cover,
                    ),
                  ),

                  Positioned(
                    child: Container(
                      width: 215.59.w,
                      height: 74.8.h,
                      child: Image.asset('assets/images/company_logo.png'),
                    ),
                    bottom: 60.2.h,
                    right: 92.41.w,
                  ),

                  Center(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 380.h,
                        ),
                        // Container(
                        //   width: 1406.w,
                        //   height: 372.h,
                        //   child: Image.asset(
                        //     'assets/images/company_logo_big.png',
                        //   ),
                        // ),

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
                          height: 280.h,
                        ),
                        Container(
                          width: 809.w,
                          height: 953.h,
                          decoration: BoxDecoration(
                            color: AppColors.main1,
                            border: Border.all(
                              color: Color(0xffA0AEC0),
                              width: 2.w,
                            ),
                            borderRadius:
                                BorderRadius.circular(20.r), // 선택사항: 둥근 테두리
                          ),
                          child: Center(
                              child:
                              Column(
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
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(
                                height: 73.5.h,
                              ),
                              Container(
                                width: 600.w,

                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 50.h,
                                      child: Text(
                                        '아이디',
                                        style: TextStyle(
                                          fontFamily: 'PretendardGOV',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 24.sp,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 600.w,
                                      height: 80.h, // 고정된 입력창 높이
                                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: const Color(0xFFE2E8F0),
                                          width: 1.w,
                                        ),
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                      child: Center(
                                        child: TextField(
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "아이디 입력",
                                            hintStyle: TextStyle(
                                              color: Color(0xffA0AEC0),
                                              fontSize: 32.sp,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'PretendardGOV',
                                            ),
                                            isDense: true, // 👈 여백 자동 줄이기
                                            contentPadding: EdgeInsets.zero, // 👈 여백 제거
                                          ),
                                          style: TextStyle(
                                            fontSize: 36.sp,
                                            color: Color(0xff2d3748),
                                          ),
                                          textAlignVertical: TextAlignVertical.center, // 👈 수직 정렬 핵심
                                        ),
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.centerRight,

                                      height: 50.h,
                                      child: Text(
                                        '아이디 찾기',
                                        style: TextStyle(
                                          fontFamily: 'PretendardGOV',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 20.sp,
                                          color: Colors.white,
                                        ),

                                      ),
                                    )

                                  ]

                                ),
                              ),
                              Container(
                                width: 600.w,

                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 50.h,
                                        child: Text(
                                          '비밀번호',
                                          style: TextStyle(
                                            fontFamily: 'PretendardGOV',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 24.sp,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 600.w,
                                        height: 80.h, // 고정된 입력창 높이
                                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: const Color(0xFFE2E8F0),
                                            width: 1.w,
                                          ),
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                        child: Center(
                                          child: TextField(
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: "비밀번호 입력",
                                              hintStyle: TextStyle(
                                                color: Color(0xffA0AEC0),
                                                fontSize: 32.sp,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: 'PretendardGOV',
                                              ),
                                              isDense: true, // 👈 여백 자동 줄이기
                                              contentPadding: EdgeInsets.zero, // 👈 여백 제거
                                            ),
                                            style: TextStyle(
                                              fontSize: 36.sp,
                                              color: Color(0xff2d3748),
                                            ),
                                            textAlignVertical: TextAlignVertical.center, // 👈 수직 정렬 핵심
                                          ),
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.centerRight,

                                        height: 50.h,
                                        child: Text(
                                          '비밀번호 찾기',
                                          style: TextStyle(
                                            fontFamily: 'PretendardGOV',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 20.sp,
                                            color: Colors.white,
                                          ),

                                        ),
                                      )

                                    ]

                                ),
                              ),



                              SizedBox(
                                height: 31.h,
                              ),
                              Container(
                                  width: 600.w,
                                  height: 80.h,
                                  padding: EdgeInsets.only(top: 12.h),
                                  decoration: BoxDecoration(
                                    color: Color(0xff3182ce),

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
                                  )),
                              SizedBox(
                                height: 47.h,
                              ),
                              Container(
                                width: 600.w,
                                height: 2.h,
                                color: Color(0xffd9d9d9),
                              ),
                              SizedBox(
                                height: 98.h,
                              ),
                              Container(
                                  width: 600.w,
                                  height: 80.h,
                                  padding: EdgeInsets.only(top: 12.h),
                                  decoration: BoxDecoration(
                                    color: Color(0xff84bf3c),

                                    borderRadius:
                                    BorderRadius.circular(8.r), // 둥근 모서리
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        barrierColor: Colors.transparent,
                                        barrierDismissible: true, // 바깥 터치로 닫기
                                        builder: (BuildContext context) {
                                          return const RegisterWidget();
                                        },
                                      );
                                    },
                                    child: (Text(
                                      '회원 가입',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'PretendardGOV',
                                        fontWeight: FontWeight.w800,
                                        fontSize: 36.sp,
                                        color: Color(0xffFFFFFF),
                                      ),
                                    )),
                                  )),
                            ],
                          )),
                        ),
SizedBox(height: 285.h,),

                      ],
                    ),
                  ),



                ],
              )),
        );
      },
    );
  }

}
