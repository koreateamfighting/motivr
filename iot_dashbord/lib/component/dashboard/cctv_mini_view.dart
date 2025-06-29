import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/theme/colors.dart';
import 'package:iot_dashboard/services/hls_player_iframe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iot_dashboard/services/webrtc_player.dart';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';

class CctvMiniView extends StatefulWidget {
  const CctvMiniView({super.key});

  @override
  State<CctvMiniView> createState() => _CctvMiniViewState();
}

class _CctvMiniViewState extends State<CctvMiniView> {

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 881.w,
      height: 1709.h,
      decoration: BoxDecoration(
        //color: Color(0xff111c44),
        color: Color(0xff1b254b),
        border: Border.all(
          color: Colors.white,
          width: 1.w,
        ),
        borderRadius: BorderRadius.circular(5.r),
        // child: 이후 실제 위젯 들어갈 수 있도록 구성해둠
      ),
      child: Column(children: [
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
                child: Image.asset('assets/icons/cctv.png'),
              ),
              SizedBox(
                width: 12.w,
              ),
              Text(
                'CCTV 현황',
                style: TextStyle(
                    fontFamily: 'PretendardGOV',
                    fontWeight: FontWeight.w500,
                    fontSize: 36.sp,
                    color: Colors.white),
              ),
            ],
          ),
        ),
        Container(
          height: 1.h,
          color: Colors.white,
        ),
        Container(
          width: 859.w,
          height: 503.h,
          padding: EdgeInsets.fromLTRB(11.w, 10.h, 11.w, 10.h),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.grey),
          ),
          child: const HlsPlayerIframe(cam: 'cam1'),

        ),
        Container(
          height: 1.h,
          color: Colors.white,
        ),
        Container(
          height: 320.h,
          padding: EdgeInsets.only(left: 11.w, right: 11.w),
          child: Column(
            children: [
              Container(
                height: 69.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '●',
                      style:
                          TextStyle(fontSize: 32.sp, color: Color(0xff258420)),
                    ),
                    SizedBox(
                      width: 25.w,
                    ),
                    Text(
                      '추진구',
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
                height: 240.h,
                decoration: BoxDecoration(
                  //color: Color(0xff111c44),
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.white,
                    width: 1.w,
                  ),
                  borderRadius: BorderRadius.circular(5.r),
                  // child: 이후 실제 위젯 들어갈 수 있도록 구성해둠
                ),
                child:Stack(
                  children: [// Stack 내부의 마지막 자식으로 추가

                    Positioned.fill(
                      child: Container(
                        height: 240.h,
                        child: LineChart(
                          LineChartData(

                            minY: -5,
                            maxY:  5,
                            backgroundColor: Colors.transparent,
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: [
                                  FlSpot(0, -2),
                                  FlSpot(1, -1),
                                  FlSpot(2, 0),
                                  FlSpot(3, 2.5),
                                  FlSpot(4, 3),
                                  FlSpot(5, 1),
                                  FlSpot(6, 0.5),
                                  FlSpot(7, -1.5),
                                ],
                                isCurved: true,
                                color: Colors.blue,
                                barWidth: 2,
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.withOpacity(0.8),
                                      Colors.blue.withOpacity(0.2),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 81.65.w,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '추진구 / CCTV',
                              style: GoogleFonts.inter(
                                color: Color(0xff262d33),
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '2025-05-23',
                              style: GoogleFonts.inter(
                                color: Color(0xff939699),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Text(
                              '1.1921',
                              style: GoogleFonts.inter(
                                color: Color(0xff262d33),
                                fontSize: 30.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              '+0.0015 (+0.13%)',
                              style: GoogleFonts.inter(
                                color: Color(0xff4b5157),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(
                              height: 15.h,
                            ),
                            Text(
                              '0.00 USD',
                              style: GoogleFonts.inter(
                                color: Color(0xff4b5157),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.8), // 회색 배경, 불투명도 30%
                        alignment: Alignment.center,
                        child: Text(
                          '점검중입니다',
                          style: TextStyle(
                            fontSize: 30.sp,
                            fontFamily: 'PretendardGOV',
                            fontWeight: FontWeight.w700,
                            color: Color(0xff3185ce),
                          ),
                        ),
                      ),
                    ),

                  ],
                )

              ),
            ],
          ),
        ),
        Container(
          width: 859.w,
          height: 495.h,
          padding: EdgeInsets.fromLTRB(11.w, 10.h, 11.w, 10.h),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.grey),
          ),
          child: const HlsPlayerIframe(cam: 'cam2'),
        ),
        Container(
          height: 1.h,
          color: Colors.white,
        ),
        Container(
          height: 320.h,
          padding: EdgeInsets.only(left: 11.w, right: 11.w),
          child: Column(
            children: [
              Container(
                height: 61.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '●',
                      style:
                          TextStyle(fontSize: 32.sp, color: Color(0xff258420)),
                    ),
                    SizedBox(
                      width: 25.w,
                    ),
                    Text(
                      '도달구',
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
              Expanded(child: Container(
                height: 248.h,
                decoration: BoxDecoration(
                  //color: Color(0xff111c44),
                  color: Color(0xffffc4c9),
                  border: Border.all(
                    color: Colors.white,
                    width: 1.w,
                  ),
                  borderRadius: BorderRadius.circular(5.r),
                  // child: 이후 실제 위젯 들어갈 수 있도록 구성해둠
                ),
                child: Stack(
                  children: [

                    Positioned.fill(
                      child: Container(
                        height: 240.h,
                        child: LineChart(
                          LineChartData(

                            minY: -5,
                            maxY:  5,
                            backgroundColor: Colors.white,
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: [
                                  FlSpot(0, -2),
                                  FlSpot(1, -1),
                                  FlSpot(2, 0),
                                  FlSpot(3, 2.5),
                                  FlSpot(4, 3),
                                  FlSpot(5, 1),
                                  FlSpot(6, 0.5),
                                  FlSpot(7, -1.5),
                                ],
                                isCurved: true,
                                color: Colors.red,
                                barWidth: 2,
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.red.withOpacity(0.8),
                                      Colors.red.withOpacity(0.2),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 81.65.w,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '도달구 / CCTV',
                              style: GoogleFonts.inter(
                                color: Color(0xff262d33),
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '2025-05-23',
                              style: GoogleFonts.inter(
                                color: Color(0xff939699),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Text(
                              '1.1763',
                              style: GoogleFonts.inter(
                                color: Color(0xff262d33),
                                fontSize: 30.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              '+0.0015 (+0.13%)',
                              style: GoogleFonts.inter(
                                color: Color(0xff4b5157),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(
                              height: 15.h,
                            ),
                            Text(
                              '기준치',
                              style: GoogleFonts.inter(
                                color: Color(0xff4b5157),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.8), // 회색 배경, 불투명도 30%
                        alignment: Alignment.center,
                        child: Text(
                          '점검중입니다',
                          style: TextStyle(
                            fontSize: 30.sp,
                            fontFamily: 'PretendardGOV',
                            fontWeight: FontWeight.w700,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),

                  ],
                ),

              ))
              ,
            ],
          ),
        ),
      ]),
    );
  }
}
