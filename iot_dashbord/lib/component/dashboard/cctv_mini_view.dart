import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/theme/colors.dart';
import 'package:iot_dashboard/services/hls_player_iframe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iot_dashboard/services/webrtc_player.dart';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iot_dashboard/constants/global_constants.dart';

class CctvMiniView extends StatefulWidget {
  const CctvMiniView({super.key});

  @override
  State<CctvMiniView> createState() => _CctvMiniViewState();
}

class _CctvMiniViewState extends State<CctvMiniView> {
  Timer? _refreshTimer;
  List<FlSpot> cam1Spots = [];
  List<FlSpot> cam2Spots = [];
  double cam1Avg = 0;
  double cam2Avg = 0;
  String today = '';
  String _lastUpdatedTime = ''; // ⏰ 최근 업데이트 시각 저장
  final List<String> _minuteLabels = List.generate(
    1440,
        (i) {
      final h = (i ~/ 60).toString().padLeft(2, '0');
      final m = (i % 60).toString().padLeft(2, '0');
      return '$h:$m';
    },
  );
  @override
  void initState() {
    super.initState();
    _fetchCctvAlertData(); // 최초 실행
    _refreshTimer = Timer.periodic(Duration(seconds: 10), (_) {
      _fetchCctvAlertData(); // 1분마다 호출
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchCctvAlertData() async {
    final now = DateTime.now();
    final todayDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    try {
      final response = await http.get(Uri.parse('${baseUrl3030}/api/alarmhistory/cctv/alert'));
      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body)['data'];
      final cam1Map = _initializeDayMap();
      final cam2Map = _initializeDayMap();

      for (var item in data) {
        final deviceId = item['DeviceID'];
        final event = item['Event'];

        // ✅ 타임존 보정을 하지 않음 → 타임존 포함된 ISO8601 처리 안전
        final timestamp = DateTime.parse(item['Timestamp']);

        // ✅ 'HH:mm' 키 생성
        final key = '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';



        final value = event == '주의' ? 1.0 : (event == '경고' ? 2.0 : 0.0);

        if (deviceId == 'cam1') {
          cam1Map[key] = value > (cam1Map[key] ?? 0.0) ? value : cam1Map[key]!;
        }
        if (deviceId == 'cam2') {
          cam2Map[key] = value > (cam2Map[key] ?? 0.0) ? value : cam2Map[key]!;
        }
      }

      List<FlSpot> cam1 = [], cam2 = [];
      double cam1Sum = 0, cam2Sum = 0;
      int cam1Cnt = 0, cam2Cnt = 0;
      final nowKeySet = _getRecent10MinKeys();

      int i = 0;
      for (var key in cam1Map.keys) {
        final y1 = cam1Map[key]!;
        final y2 = cam2Map[key]!;

        cam1.add(FlSpot(i.toDouble(), y1));
        cam2.add(FlSpot(i.toDouble(), y2));

        if (nowKeySet.contains(key)) {
          cam1Sum += y1;
          cam2Sum += y2;
          cam1Cnt += 1;
          cam2Cnt += 1;
        }
        i++;
      }

      setState(() {
        cam1Spots = List<FlSpot>.from(cam1);
        cam2Spots = List<FlSpot>.from(cam2);
        cam1Avg = cam1Cnt > 0 ? (cam1Sum / cam1Cnt) : 0.0;
        cam2Avg = cam2Cnt > 0 ? (cam2Sum / cam2Cnt) : 0.0;
        today = todayDate;
        _lastUpdatedTime = DateFormat('HH:mm:ss').format(DateTime.now());
        print('📈 CCTV 그래프 재갱신 : $_lastUpdatedTime');
      });
    } catch (e) {
      print("❌ CCTV 알람 로딩 실패: $e");
    }
  }


  Map<String, double> _initializeDayMap() {
    final map = <String, double>{};
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    for (int i = 0; i <= currentMinutes; i++) {
      final dt = DateTime(0).add(Duration(minutes: i));
      final key = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      map[key] = 0.0;
    }

    return map;
  }


  Set<String> _getRecent10MinKeys() {
    final now = DateTime.now();
    final keys = <String>{};
    for (int i = 0; i < 10; i++) {
      final dt = now.subtract(Duration(minutes: i));
      final key = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      keys.add(key);
    }
    return keys;
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
        SizedBox(
          height: 8.h,
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
          height: 312.h,
          padding: EdgeInsets.only(left: 11.w, right: 11.w),
          child: Column(
            children: [
              Container(
                height: 55.h,
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
                  child: Stack(
                    children: [
                      // Stack 내부의 마지막 자식으로 추가

                      Positioned.fill(
                        child: Container(
                          height: 240.h,
                          child: LineChart(
                            LineChartData(
                              minY: -5,
                              maxY: 5,
                              backgroundColor: Colors.transparent,
                              gridData: FlGridData(show: false),
                              titlesData: FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              lineTouchData: LineTouchData(
                                touchTooltipData: LineTouchTooltipData(
                                  getTooltipItems: (touchedSpots) {
                                    return touchedSpots.map((spot) {
                                      final time = _minuteLabels[spot.x.toInt()];
                                      final value = spot.y.toStringAsFixed(1);
                                      return LineTooltipItem(
                                        '$time\n$value',
                                        const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      );
                                    }).toList();
                                  },
                                ),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: cam1Spots,
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
                          )

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
                                today,
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
                                '${cam1Avg.toStringAsFixed(2)}',
                                style: GoogleFonts.inter(
                                  color: Color(0xff262d33),
                                  fontSize: 30.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              // Text(
                              //   '+0.0015 (+0.13%)',
                              //   style: GoogleFonts.inter(
                              //     color: Color(0xff4b5157),
                              //     fontSize: 14.sp,
                              //     fontWeight: FontWeight.w400,
                              //   ),
                              // ),
                              SizedBox(
                                height: 15.h,
                              ),
                              // Text(
                              //   '0.00 USD',
                              //   style: GoogleFonts.inter(
                              //     color: Color(0xff4b5157),
                              //     fontSize: 12.sp,
                              //     fontWeight: FontWeight.w400,
                              //   ),
                              // ),
                            ],
                          )
                        ],
                      ),
                      // Positioned.fill(
                      //   child: Container(
                      //     color: Colors.black.withOpacity(0.8),
                      //     // 회색 배경, 불투명도 30%
                      //     alignment: Alignment.center,
                      //     child: Text(
                      //       '점검중입니다',
                      //       style: TextStyle(
                      //         fontSize: 30.sp,
                      //         fontFamily: 'PretendardGOV',
                      //         fontWeight: FontWeight.w700,
                      //         color: Color(0xff3185ce),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  )),
            ],
          ),
        ),
        Container(
          width: 859.w,
          height: 495.h,
          padding: EdgeInsets.fromLTRB(11.w, 0.h, 11.w, 10.h),
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
                height: 55.h,
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
              Expanded(
                  child: Container(
                height: 247.h,
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
                            maxY: 5,
                            backgroundColor: Colors.white,
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineTouchData: LineTouchData(
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipItems: (touchedSpots) {
                                  return touchedSpots.map((spot) {
                                    final time = _minuteLabels[spot.x.toInt()];
                                    final value = spot.y.toStringAsFixed(1);
                                    return LineTooltipItem(
                                      '$time\n$value',
                                      const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: cam2Spots,
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
                        )
                        ,
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
                              today,
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
                              '${cam2Avg.toStringAsFixed(2)}',
                              style: GoogleFonts.inter(
                                color: Color(0xff262d33),
                                fontSize: 30.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            // Text(
                            //   '+0.0015 (+0.13%)',
                            //   style: GoogleFonts.inter(
                            //     color: Color(0xff4b5157),
                            //     fontSize: 14.sp,
                            //     fontWeight: FontWeight.w400,
                            //   ),
                            // ),
                            // SizedBox(
                            //   height: 15.h,
                            // ),
                            // Text(
                            //   '기준치',
                            //   style: GoogleFonts.inter(
                            //     color: Color(0xff4b5157),
                            //     fontSize: 12.sp,
                            //     fontWeight: FontWeight.w400,
                            //   ),
                            //),
                          ],
                        )
                      ],
                    ),
                    // Positioned.fill(
                    //   child: Container(
                    //     color: Colors.black.withOpacity(0.8), // 회색 배경, 불투명도 30%
                    //     alignment: Alignment.center,
                    //     child: Text(
                    //       '점검중입니다',
                    //       style: TextStyle(
                    //         fontSize: 30.sp,
                    //         fontFamily: 'PretendardGOV',
                    //         fontWeight: FontWeight.w700,
                    //         color: Colors.red,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ]),
    );
  }
}
