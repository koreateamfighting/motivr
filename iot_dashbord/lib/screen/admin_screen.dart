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
                          'assets/icons/color_setting2.png',
                        ),
                      ),
                      SizedBox(width: 18.w),
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
                                    Container(
                                      width: 30.w,
                                      height: 30.h,
                                      child: Image.asset(
                                          'assets/icons/edit2.png'),
                                    ),
                                    SizedBox(
                                      width: 5.w,
                                    ),
                                    sectionTitle('전체 타이틀 변경')
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
                                    Container(
                                      width: 30.w,
                                      height: 30.h,
                                      child: Image.asset(
                                          'assets/icons/inputdata.png'),
                                    ),
                                    SizedBox(
                                      width: 5.w,
                                    ),
                                    sectionTitle('기초 데이터 입력')
                                  ],
                                ),
                                Container(
                                  width: 2880.w,
                                  height: 502.03.h,
                                  decoration: BoxDecoration(
                                    color: Color(0xff414c67),
                                    borderRadius: BorderRadius.circular(5.r),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(width:60.w),
                                          Container(
                                            width: 30.w,
                                            height: 30.h,
                                            child:
                                            Image.asset('assets/icons/edit3.png'),
                                          ),
                                          SizedBox(
                                            width: 5.w,
                                          ),
                                          blockTitle('작업명')
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 99.w,
                                          ),
                                          labeledTextField(
                                              title: '작업명',
                                              hint:
                                              '예: 콘크리트 타설',
                                              width: 1000,
                                              height: 55.17),
                                          SizedBox(
                                            width: 61.w,
                                          ),
                                          labeledTextField(
                                              title: '시작일',
                                              hint: '예: 20250517',
                                              width: 500,
                                              height: 55.17),
                                          SizedBox(
                                            width: 61.w,
                                          ),
                                          labeledTextField(
                                              title: '완료일',
                                              hint: '예: 20250531',
                                              width: 500,
                                              height: 55.17),
                                          SizedBox(
                                            width: 61.w,
                                          ),
                                          labeledTextField(
                                              title: '공정률',
                                              hint: '예: 70',
                                              width: 495,
                                              height: 55),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(width:60.w),
                                          Container(
                                            width: 30.w,
                                            height: 30.h,
                                            child:
                                            Image.asset('assets/icons/alarm.png'),
                                          ),
                                          SizedBox(
                                            width: 5.w,
                                          ),
                                          blockTitle('최근알람 / 이벤트')
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 99.w,
                                          ),
                                          labeledTextField(
                                              title: '날짜 / 시간',
                                              hint:
                                              '예: ',
                                              width: 1000,
                                              height: 60),
                                          SizedBox(
                                            width: 61.w,
                                          ),
                                          labeledTextField(
                                              title: '유형',
                                              hint: '예: 경고/주의/경보',
                                              width: 269,
                                              height: 60),
                                          SizedBox(
                                            width: 61.w,
                                          ),
                                          labeledTextField(
                                              title: '메세지',
                                              hint: '예: 20250531',
                                              width: 1287,
                                              height: 60),

                                        ],
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(width:60.w),
                                          Container(
                                            width: 30.w,
                                            height: 30.h,
                                            child:
                                            Image.asset('assets/icons/clipboard2.png'),
                                          ),
                                          SizedBox(
                                            width: 5.w,
                                          ),
                                          blockTitle('공지 및 주요 일정')
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 99.w,
                                          ),
                                          labeledTextField(
                                              title: '날짜 / 시간',
                                              hint:
                                              '예: ',
                                              width: 541,
                                              height: 60),
                                          SizedBox(
                                            width: 61.w,
                                          ),
                                          labeledTextField(
                                              title: '유형',
                                              hint: '예: 경고/주의/경보',
                                              width: 269,
                                              height: 60),
                                          SizedBox(
                                            width: 61.w,
                                          ),
                                          labeledTextField(
                                              title: '내용',
                                              hint: '예: 20250531',
                                              width: 1745,
                                              height: 60),

                                        ],
                                      ),
                                    ],
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
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(width:60.w),
                                          Container(
                                            width: 30.w,
                                            height: 30.h,
                                            child:
                                            Image.asset('assets/icons/iot.png'),
                                          ),
                                          SizedBox(
                                            width: 5.w,
                                          ),
                                          blockTitle('Iot 정보 입력')
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 99.w,
                                          ),
                                          labeledTextField(
                                              title: '제품 식별자(ID)',
                                              hint:
                                              '예: 콘크리트 타설',
                                              width: 207,
                                              height: 60),
                                          SizedBox(
                                            width: 61.w,
                                          ),
                                          labeledTextField(
                                              title: '설치 위치 (추진구/도달구)',
                                              hint: '예: 추진구_1',
                                              width: 326,
                                              height: 60),
                                          SizedBox(
                                            width: 61.w,
                                          ),
                                          labeledTextField(
                                              title: '상태',
                                              hint: '예: 정상',
                                              width: 210,
                                              height: 60),
                                          SizedBox(
                                            width: 61.w,
                                          ),
                                          labeledTextField(
                                              title: '상태',
                                              hint: '예: 정상',
                                              width: 210,
                                              height: 60),
                                          SizedBox(
                                            width: 61.w,
                                          ),
                                          labeledTextField(
                                              title: '마지막 수신',
                                              hint: '예: 2025-05-20 14:23',
                                              width: 266,
                                              height: 60),
                                          SizedBox(
                                            width: 61.w,
                                          ),
                                          labeledTextField(
                                              title: 'X (mm / 0°)',
                                              hint: '예 : 0.3 /  24°',
                                              width: 163,
                                              height: 60),
                                          SizedBox(
                                            width: 61.w,
                                          ),
                                          labeledTextField(
                                              title: 'Y (mm / 0°)',
                                              hint: '예 : 0.3 /  24°',
                                              width: 163,
                                              height: 60),
                                          SizedBox(
                                            width: 61.w,
                                          ),
                                          labeledTextField(
                                              title:'Z (mm / 0°)',
                                              hint: '예 : 0.3 /  24°',
                                              width: 163,
                                              height: 60),
                                          SizedBox(
                                            width: 61.w,
                                          ),
                                          labeledTextField(
                                              title:'경사 (0°)',
                                              hint: '예 : 5',
                                              width: 163,
                                              height: 60),
                                          SizedBox(
                                            width: 61.w,
                                          ),
                                          labeledTextField(
                                              title:'배터리 정보',
                                              hint: '예 : 5',
                                              width: 257,
                                              height: 60),

                                        ],
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(width:60.w),
                                          Container(
                                            width: 30.w,
                                            height: 30.h,
                                            child:
                                            Image.asset('assets/icons/cctv.png'),
                                          ),
                                          SizedBox(
                                            width: 5.w,
                                          ),
                                          blockTitle('CCTV 정보 입력')
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 99.w,
                                          ),
                                          labeledTextField(
                                              title: '카메라 이름 / 번호',
                                              hint:
                                              '예: CCTV-01',
                                              width: 207,
                                              height: 60),
                                          SizedBox(
                                            width: 61.w,
                                          ),
                                          labeledTextField(
                                              title: '설치 위치 (추진구/도달구)',
                                              hint: '예: sensor-001',
                                              width: 326,
                                              height: 60),
                                          SizedBox(
                                            width: 61.w,
                                          ),
                                          labeledTextField(
                                              title: '상태',
                                              hint: '예: 정상',
                                              width: 210,
                                              height: 60),
                                          SizedBox(
                                            width: 61.w,
                                          ),
                                          labeledTextField(
                                              title: 'RTSP 주소',
                                              hint: 'rstp://..',
                                              width: 1000,
                                              height: 60),
                                          SizedBox(
                                            width: 61.w,
                                          ),
                                          labeledTextField(
                                              title: '변위 측정 값',
                                              hint: '예 : 0.3 /  24°',
                                              width: 691,
                                              height: 60),

                                        ],
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(width:60.w),
                                          Container(
                                            width: 30.w,
                                            height: 30.h,
                                            child:
                                            Image.asset('assets/icons/clock2.png'),
                                          ),
                                          SizedBox(
                                            width: 5.w,
                                          ),
                                          blockTitle('알람 히스토리')
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(width:108.97.w),
                                          blockTitle('IoT')
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 99.w,
                                          ),
                                          labeledTextField(
                                              title: '제품 식별자(ID)',
                                              hint:
                                              '예: sensor-001',
                                              width: 206.85,
                                              height: 60),
                                          SizedBox(
                                            width: 61.w,
                                          ),
                                          labeledTextField(
                                              title: '날짜 / 시간',
                                              hint: '예: 2025-05-20 14:23',
                                              width: 595.56,
                                              height: 60),
                                          SizedBox(
                                            width: 61.w,
                                          ),
                                          labeledTextField(
                                              title: '로그',
                                              hint: '예: 센서_3_INFO',
                                              width: 1747.71,
                                              height: 60),

                                        ],
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(width:108.97.w),
                                          blockTitle('CCTV')
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 99.w,
                                          ),
                                          labeledTextField(
                                              title: '제품 식별자(ID)',
                                              hint:
                                              '예: sensor-001',
                                              width: 206.85,
                                              height: 60),
                                          SizedBox(
                                            width: 61.w,
                                          ),
                                          labeledTextField(
                                              title: '날짜 / 시간',
                                              hint: '예: 2025-05-20 14:23',
                                              width: 595.56,
                                              height: 60),
                                          SizedBox(
                                            width: 61.w,
                                          ),
                                          labeledTextField(
                                              title: '로그',
                                              hint: '예: 센서_3_INFO',
                                              width: 1747.71,
                                              height: 60),

                                        ],
                                      ),

                                    ],
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
                                  child:  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 99.w,
                                      ),
                                      labeledTextField(
                                          title: '공사명',
                                          hint:
                                          '예 : 절토사면 안정화 공사',
                                          width: 600.42,
                                          height: 60),
                                      SizedBox(
                                        width: 61.w,
                                      ),
                                      labeledTextField(
                                          title: '현장 주소',
                                          hint: '예 : 대구광역시 수성구 알파시티1로 35, 17',
                                          width: 600.42,
                                          height: 60),
                                      SizedBox(
                                        width: 61.w,
                                      ),
                                      labeledTextField(
                                          title: '발주처',
                                          hint: '예: 한림기술',
                                          width: 420.29,
                                          height: 60),
                                      SizedBox(
                                        width: 61.w,
                                      ),
                                      labeledTextField(
                                          title: '공사 기간',
                                          hint: '예: 20250520',
                                          width: 420.29,
                                          height: 60),
                                      SizedBox(
                                        width: 61.w,
                                      ),
                                      labeledTextField(
                                          title: '시공사',
                                          hint: '예: 한림기술',
                                          width: 397.28,
                                          height: 60),

                                    ],
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
                style: TextStyle(color: Colors.black),
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
