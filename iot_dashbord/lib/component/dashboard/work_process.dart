import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/theme/colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class WorkProcessStatus extends StatelessWidget {
  const WorkProcessStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 613.w,
      height: 602.h,
      decoration: BoxDecoration(
        color: Color(0xff111c44),
        border: Border.all(
          color: Colors.white,
          width: 1.w,
        ),
        borderRadius: BorderRadius.circular(5.r),
        // child: 이후 실제 위젯 들어갈 수 있도록 구성해둠
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              height: 59.h,
              child: Row(
                children: [
                  SizedBox(
                    width: 24.w,
                  ),
                  Container(
                    width: 30.w,
                    height: 30.h,
                    child: Image.asset('assets/icons/work_process.png'),
                  ),
                  SizedBox(
                    width: 12.w,
                  ),
                  Text(
                    '오늘 작업 공정',
                    style: TextStyle(
                        fontFamily: 'PretendardGOV',
                        fontWeight: FontWeight.w500,
                        fontSize: 36.sp,
                        color: Colors.white),
                  ),
                  SizedBox(
                    width: 70.w,
                  ),
                  Text(
                    _getFormattedDate(),
                    style: TextStyle(
                      fontFamily: 'PretendardGOV',
                      fontWeight: FontWeight.w400,
                      fontSize: 24.sp,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1542.w,
              height: 1.h,
              color: Colors.white,
            ),
            SizedBox(height: 54.h,),
            Container(
              height: 481.h,
              child: Column(
                children: [
                  SizedBox(
                    width: 334.45.w,
                    height: 340.w,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            centerSpaceRadius: 120.w,
                            startDegreeOffset: -90,
                            sectionsSpace: 0,

                            sections: [
                              PieChartSectionData(

                                color: const Color(0xff2980ff), // 완료
                                value: 60,
                                showTitle: false,
                                radius: 50.w,
                              ),
                              PieChartSectionData(
                                color: const Color(0xffa0aec0), // 미완료
                                value: 40,
                                showTitle: false,
                                radius: 50.w,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 20.h,),
                            Text(
                              '60%',
                              style: TextStyle(
                                fontSize: 80.sp,
                                fontFamily: 'PretendardGOV',
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '공정률',
                              style: TextStyle(
                                fontSize: 32.sp,
                                fontFamily: 'PretendardGOV',
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 33.h,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _legendItem(Color(0xff414c67), '미완료'), // 단색 처리
                      SizedBox(width: 32.w),
                      _legendItem( Color(0xff030A64), '완료'), // 상단 밝음 → 하단 어두움
                    ],
                  ),
                  SizedBox(height: 24.h,),
                  Container(
                    width: 1542.w,
                    height: 1.h,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8.h,),
               Container(

                        width: 140.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          color:  Color(0xff3182ce),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Center(
                          child: Text(
                            '공정률 입력',
                            style: TextStyle(
                              fontFamily: 'PretendardGOV',
                              fontSize: 20.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                ],
              ),
            ),


          ],
        ),
      ),
    );
  }
}

String _getFormattedDate() {
  final now =
      DateTime.now().toUtc().add(const Duration(hours: 9)); // KST = UTC+9
  return '${now.year}년 ${now.month.toString().padLeft(2, '0')}월 ${now.day.toString().padLeft(2, '0')}일 현재';
}

Widget  _legendItem(Color baseColor, String label) {
  return Row(
    children: [
      ClipOval(
        child: Container(
          width: 16.w,
          height: 16.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                darken(baseColor, 0.2),
                baseColor,
                brighten(baseColor, 0.2),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      SizedBox(width: 8.w),
      Text(
        label,
        style: TextStyle(
          fontFamily: 'PretendardGOV',
          fontSize: 21.sp,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      ),
    ],
  );
}



Widget _statusRow(String label, int count, Color color, String iconName) {
  return Padding(
    padding: EdgeInsets.only(bottom: 24.h),
    child: Row(
      children: [
        // Container(
        //   width: 60.w,
        //   child: Text(
        //     '$label',
        //     style: TextStyle(
        //       fontFamily: 'PretendardGOV',
        //       color: Colors.white,
        //       fontSize: 32.sp,
        //       fontWeight: FontWeight.w500,
        //     ),
        //   ),
        // ),
        SizedBox(
          width: 64.w,
        ),
        //아이콘
        Container(
          width: 60.w,
          height: 60.h,
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5.r), // 둥근 모서리
          ),
          child: Image.asset(
            iconName,
            fit: BoxFit.contain,
          ),
        ),

        SizedBox(width: 10.w),

        //수치
        Container(
          width: 99.82.w,
          height: 49.18.h,
          padding: EdgeInsets.only(top: 6.h),
          decoration: BoxDecoration(
            color: Color(0xff414c67),
            borderRadius: BorderRadius.circular(8.r), // 둥근 모서리
            border:
                Border.all(color: Colors.white, width: 1.0.w), // 또는 Border.none
          ),
          child: Text(
            '$count',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 32.sp,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(width: 10.w),

        Container(
          width: 300.w,
          height: 60.h,
          color: Colors.transparent,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label,
                      style: TextStyle(
                        fontFamily: 'PretendardGOV',
                        fontWeight: FontWeight.w500,
                        fontSize: 32.sp,
                        color: Colors.white,
                      )),
                  Text(
                    '${(count / 24 * 100).toStringAsFixed(1)} %',
                    style: TextStyle(
                      fontFamily: 'PretendardGOV',
                      fontWeight: FontWeight.w500,
                      fontSize: 32.sp,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                width: 300.w,
                height: 10.h,
                decoration: BoxDecoration(
                  color: Color(0xff414c67),
                  borderRadius: BorderRadius.circular(5.r),
                ),
                alignment: Alignment.centerLeft,
                child: Container(
                  width: (count / 24) * 300.w,
                  // height: 60.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        darken(color, 0.2), // 어두운 쪽
                        color, // 중간
                        brighten(color, 0.2), // 밝은 쪽
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              )
            ],
          ),
        ),
        //그래프

        SizedBox(width: 16.w),
      ],
    ),
  );
}

Color darken(Color color, [double amount = .1]) {
  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
  return hslDark.toColor();
}

Color brighten(Color color, [double amount = .1]) {
  final hsl = HSLColor.fromColor(color);
  final hslBright = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
  return hslBright.toColor();
}
