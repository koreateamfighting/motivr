import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/theme/colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:iot_dashboard/controller/iot_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';


class IotControlStatus extends StatefulWidget {
  const IotControlStatus({super.key});

  @override
  State<IotControlStatus> createState() => _IotControlStatusState();
}

class _IotControlStatusState extends State<IotControlStatus> {
  int normal = 0, caution = 0, danger = 0, inspection = 0, total = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // 🔧 최초 한 번: 렌더링 이후 안전하게 호출

    // 주기적으로 센서 상태 갱신
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      _loadSensorStatus(); // 30초마다 상태 갱신
    });
  }
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadSensorStatus() async {
    try {
      final controller = Provider.of<IotController>(context, listen: false);
      await controller.fetchSensorStatusSummary();
    } catch (e, stack) {
      debugPrint('❌ 센서 상태 불러오기 실패: $e');
      debugPrint('$stack');
    }





  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IotController>(
      builder: (context, controller, child) {
        final normal = controller.getNormal;
        final caution = controller.getCaution;
        final danger = controller.getDanger;
        final inspection = controller.getInspection;
        final total = controller.getTotal;

        return Container(
          width: 613.w,
          height: 641.h,
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
                        child: Image.asset('assets/icons/iot_control.png'),
                      ),
                      SizedBox(
                        width: 12.w,
                      ),
                      Text(
                        'IoT 작동 현황',
                        style: TextStyle(
                            fontFamily: 'PretendardGOV',
                            fontWeight: FontWeight.w500,
                            fontSize: 36.sp,
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
                  height: 25.h,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 64.w,
                    ),
                    // 전체 수치
                    Container(
                      width: 141.26.w,
                      height: 143.71.h,
                      child: PieChart(
                        PieChartData(
                          centerSpaceRadius: 60.w,
                          sectionsSpace: 0,
                          startDegreeOffset: -90,
                          sections: [
                            PieChartSectionData(
                              value: normal.toDouble(),
                              color: const Color(0xFF2FA365), // 정상
                              radius: 20.w,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              value: caution.toDouble(),
                              color: const Color(0xFFFBD50F), // 주의
                              radius: 20.w,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              value: danger.toDouble(),
                              color: const Color(0xFFFF6060), // 경고
                              radius: 20.w,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              value: inspection.toDouble(),
                              color: const Color(0xFF83C2F1), // 점검 필요
                              radius: 20.w,
                              showTitle: false,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 160.w,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$total',
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
                            fontWeight: FontWeight.w500,
                            fontSize: 32.sp,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 32.h,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _statusRow(
                        '정상',
                        normal.toInt(),
                        total.toInt(),
                        const Color(0xFF2FA365),
                        'assets/icons/status_normal_icon.png'),
                    _statusRow(
                        '주의',
                        caution.toInt(),
                        total.toInt(),
                        const Color(0xFFFBD50F),
                        'assets/icons/status_caution_icon.png'),
                    _statusRow(
                        '경고',
                        danger.toInt(),
                        total.toInt(),
                        const Color(0xFFFF6060),
                        'assets/icons/status_warning_icon.png'),
                    _statusRow(
                        '점검 필요',
                        inspection.toInt(),
                        total.toInt(),
                        const Color(0xFF83C2F1),
                        'assets/icons/status_inspection_icon.png'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _statusRow(
    String label, int count, int total, Color color, String iconName) {
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
          // padding: EdgeInsets.symmetric(vertical: 4.h),
          alignment: Alignment.center,
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
                    '${(total > 0 ? (count / total * 100) : 0).toStringAsFixed(1)} %',
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
                  width: total > 0 ? (count / total) * 300.w : 0,
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
