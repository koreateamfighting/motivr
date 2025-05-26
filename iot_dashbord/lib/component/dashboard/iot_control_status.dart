import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/theme/colors.dart';
import 'package:fl_chart/fl_chart.dart';

class IotControlStatus extends StatelessWidget {
  const IotControlStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1542.w,
      height: 554.h,
      decoration: BoxDecoration(
        color: AppColors.main1,
        borderRadius: BorderRadius.circular(12.r),
        // child: 이후 실제 위젯 들어갈 수 있도록 구성해둠
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              height: 100.h,
              child: Row(
                children: [
                  SizedBox(
                    width: 17.w,
                  ),
                  Container(
                    width: 40.w,
                    height: 40.h,
                    child: Image.asset('assets/icons/iot_control.png'),
                  ),
                  SizedBox(
                    width: 12.w,
                  ),
                  Text(
                    'IoT 작동 현황',
                    style: TextStyle(
                        fontFamily: 'PretendardGOV',
                        fontWeight: FontWeight.w700,
                        fontSize: 40.sp,
                        color: Colors.white),
                  )
                ],
              ),
            ),
            Container(
              width: 1542.w,
              height: 1.h,
              color: Colors.white,
            ),
            SizedBox(
              height: 36.h,
            ),
            Row(
              children: [
                SizedBox(
                  width: 56.w,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _statusRow('정상', 19, const Color(0xFF2FA365),
                        'assets/icons/status_normal_icon.png'),
                    _statusRow('주의', 2, const Color(0xFFFBD50F),
                        'assets/icons/status_caution_icon.png'),
                    _statusRow('경고', 2, const Color(0xFFFF6060),
                        'assets/icons/status_warning_icon.png'),
                    _statusRow('점검 필요', 1, const Color(0xFF83C2F1),
                        'assets/icons/status_inspection_icon.png'),
                  ],
                ),

                SizedBox(
                  width: 282.w,
                ),
                // 전체 수치
                Container(
                  width: 300.w,
                  height: 300.w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          centerSpaceRadius: 90.w,
                          sectionsSpace: 0,
                          startDegreeOffset: -90,
                          sections: [
                            PieChartSectionData(
                              value: 19,
                              color: const Color(0xFF2FA365), // 정상
                              radius: 50.w,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              value: 2,
                              color: const Color(0xFFFBD50F), // 주의
                              radius: 50.w,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              value: 2,
                              color: const Color(0xFFFF6060), // 경고
                              radius: 50.w,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              value: 1,
                              color: const Color(0xFF83C2F1), // 점검 필요
                              radius: 50.w,
                              showTitle: false,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '24',
                            style: TextStyle(
                              fontFamily: 'PretendardGOV',
                              fontWeight: FontWeight.w800,
                              fontSize: 64.sp,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '전체',
                            style: TextStyle(
                              fontFamily: 'PretendardGOV',
                              fontWeight: FontWeight.w400,
                              fontSize: 32.sp,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _statusRow(String label, int count, Color color, String iconName) {
  return Padding(
    padding: EdgeInsets.only(bottom: 24.h),
    child: Row(
      children: [
        Container(
          width: 60.w,
          child: Text(
            '$label',
            style: TextStyle(
              fontFamily: 'PretendardGOV',
              color: Colors.white,
              fontSize: 32.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(
          width: 12.w,
        ),
        Container(
          width: 100.w,
          height: 60.h,
          padding: EdgeInsets.only(top: 6.h),
          decoration: BoxDecoration(
            color: Color(0xff414c67),
            borderRadius: BorderRadius.circular(8.r), // 둥근 모서리
            border:
                Border.all(color: Colors.white, width: 1.0.w), // 또는 Border.none
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontFamily: 'PretendardGOV',
              color: Colors.white,
              fontSize: 32.sp,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(width: 10.w),
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
        Container(
          width: 400.w,
          height: 60.h,
          decoration: BoxDecoration(
            color: Color(0xff414c67),
            borderRadius: BorderRadius.circular(5.r),
          ),
          alignment: Alignment.centerLeft,
          child: Container(
            width: (count / 24) * 400.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ),
        SizedBox(width: 16.w),
      ],
    ),
  );
}
