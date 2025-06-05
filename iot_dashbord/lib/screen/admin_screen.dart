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
              child: Container(
            padding: EdgeInsets.only(left: 64.w, right: 68.w),
            color: Color(0xff1b254b),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 100.h,
                  color: Color(0xff1b254b),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 60.w,
                        height: 60.h,
                        child: Image.asset(
                          'assets/icons/uncolor_setting2.png',
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Container(
                          width: 200.w,
                          child: Text(
                            '관리자',
                            style: TextStyle(
                              fontFamily: 'PretendardGOV',
                              fontWeight: FontWeight.w700,
                              fontSize: 48.sp,
                              color: Colors.white,
                            ),
                          )),
                      SizedBox(width: 125.w),
                      Container(
                        width: 2880.w,
                        height: 72.h,
                        decoration: BoxDecoration(
                          color: Color(0xff414767),
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 11.w,
                            ),
                            Container(
                              width: 50.w,
                              height: 50.h,
                              child: Image.asset('assets/icons/profile.png'),
                            ),
                            SizedBox(
                              width: 45.w,
                            ),
                            Container(
                                width: 261.w,
                                height: 50.h,
                                child: Text(
                                  '관리자 설정 입력',
                                  style: TextStyle(
                                    fontFamily: 'PretendardGOV',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 36.sp,
                                    color: Colors.white,
                                  ),
                                )),
                            SizedBox(
                              width: 2155.w,
                            ),
                            InkWell(
                                onTap: () {},
                                child: Container(
                                  width: 347.w,
                                  height: 60.h,
                                  decoration: BoxDecoration(
                                    color: Color(0xff3182ce),
                                    borderRadius: BorderRadius.circular(5.r),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '저장',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'PretendardGOV',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 36.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                ))
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                // ✅ 헤더 하단 선
                Container(
                  width: double.infinity,
                  height: 2.h,
                  color: Color(0xff3182ce),
                ),

                SizedBox(height: 40.h),

                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: Column(
                        children: [
                          Container(
                            width: 2880.w,

                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 30.w,
                                      height: 30.h,
                                      child: Image.asset(
                                          'assets/icons/uncolor_setting.png'),
                                    ),
                                    SizedBox(
                                      width: 5.w,
                                    ),
                                    sectionTitle('계정 관리')
                                  ],
                                ),
                                Container(
                                  width: 2880.w,
                                  height: 127.h,
                                  decoration: BoxDecoration(
                                    color: Color(0xff414c67),
                                    borderRadius: BorderRadius.circular(5.r),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 99.w,
                                      ),
                                      labeledTextField(
                                          title: '사용자 이름',
                                          hint: '예) : 관리자',
                                          width: 1309,
                                          height: 60),
                                      SizedBox(
                                        width: 61.w,
                                      ),
                                      labeledTextField(
                                          title: '권한',
                                          hint: '관리자',
                                          width: 1309,
                                          height: 60),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 35.w,
                                    ),
                                    sectionTitle('전체 타이틀 변경'),
                                  ],
                                ),
                                Container(
                                  width: 2880.w,
                                  height: 130.h,
                                  decoration: BoxDecoration(
                                    color: Color(0xff414c67),
                                    borderRadius: BorderRadius.circular(5.r),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 99.w,
                                      ),
                                      labeledTextField(
                                          title: '타이틀 이름',
                                          hint:
                                              '예: Digital Twin EMS > 스마트 안전 시스템',
                                          width: 1309,
                                          height: 60),
                                      SizedBox(
                                        width: 61.w,
                                      ),
                                      labeledTextField(
                                          title: '로고 변경',
                                          hint: '예: 이미지 파일을 업로드 하세요',
                                          width: 1309,
                                          height: 60),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 35.w,
                                    ),
                                    sectionTitle('기초 데이터 입력'),
                                  ],
                                ),
                                Container(
                                  width: 2880.w,
                                  height: 502.03.h,
                                  decoration: BoxDecoration(
                                    color: Color(0xff414c67),
                                    borderRadius: BorderRadius.circular(5.r),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 30.w,
                                      height: 30.h,
                                      child:
                                          Image.asset('assets/icons/edit.png'),
                                    ),
                                    SizedBox(
                                      width: 5.w,
                                    ),
                                    sectionTitle('측정 데이터 수동 입력')
                                  ],
                                ),
                                Container(
                                  width: 2880.w,
                                  height: 710.h,
                                  decoration: BoxDecoration(
                                    color: Color(0xff414c67),
                                    borderRadius: BorderRadius.circular(5.r),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 30.w,
                                      height: 30.h,
                                      child:
                                          Image.asset('assets/icons/flag.png'),
                                    ),
                                    SizedBox(
                                      width: 5.w,
                                    ),
                                    sectionTitle('현장명 정보 입력')
                                  ],
                                ),
                                Container(
                                  width: 2880.w,
                                  height: 130.h,
                                  decoration: BoxDecoration(
                                    color: Color(0xff414c67),
                                    borderRadius: BorderRadius.circular(5.r),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [],
                                  ),
                                ),

                                //////////
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ));
        });
  }

  Widget sectionTitle(String title) {
    ScreenUtil.ensureScreenSize();
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'PretendardGOV',
        fontSize: 32.sp,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }

  Widget blockTitle(String title) {
    ScreenUtil.ensureScreenSize();
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'PretendardGOV',
        fontSize: 32.sp,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
    );
  }

  Widget labeledTextField(
      {required String title,
      String? hint,
      required double width,
      required double height}) {
    ScreenUtil.ensureScreenSize();
    return Container(
      width: width.w,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'PretendardGOV',
              fontSize: 24.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6.h),
          Container(
              width: width.w,
              height: height.h,
              child: TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: hint ?? '',
                  hintStyle: TextStyle(
                      color: Color(0xff9eaea2),
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'PretendardGOV'),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
                ),
              )),
        ],
      ),
    );
  }
}
