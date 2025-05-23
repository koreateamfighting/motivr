import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashbord/component/base_layout.dart';
import 'package:iot_dashbord/theme/colors.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class TimeSeriesScreen extends StatefulWidget {
  const TimeSeriesScreen({super.key});

  @override
  State<TimeSeriesScreen> createState() => _TimeSeriesScreenState();
}

class _TimeSeriesScreenState extends State<TimeSeriesScreen> {
  String selectedInterval = '10분';

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
                      'assets/icons/color_vector.png',
                      width: 80.w,
                      height: 80.h,
                    ),
                    SizedBox(width: 20.w),
                    Text(
                      '시계열데이터',
                      style: TextStyle(
                        fontFamily: 'PretendardGOV',
                        fontWeight: FontWeight.w800,
                        fontSize: 48.sp,
                        color: Color(0xff3CBFAD),
                      ),
                    ),
                    SizedBox(width: 32.w),
                    Container(
                      width: 320.w,
                      height: 80.h,
                      decoration: BoxDecoration(
                        color: Color(0xff3cbfad),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: InkWell(
                        onTap: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 40.w,
                              height: 40.h,
                              child: Image.asset('assets/icons/iot.png'),
                            ),
                            SizedBox(width: 36.w),
                            Text(
                              'IoT',
                              style: TextStyle(
                                fontFamily: 'PretendardGOV',
                                fontWeight: FontWeight.w700,
                                fontSize: 48.sp,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 34.w),
                    Container(
                      width: 1032.w,
                      height: 60.h,
                      child: Row(
                        children: [
                          Container(
                            width: 50.w,
                            height: 50.h,
                            child: Image.asset('assets/icons/calendar.png'),
                          ),
                          SizedBox(width: 11.w),
                          Text(
                            '기간 선택',
                            style: TextStyle(
                              fontFamily: 'PretendardGOV',
                              fontWeight: FontWeight.w700,
                              fontSize: 32.sp,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 28.w),
                          Container(
                            width: 300.w,
                            height: 60.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          Text(
                            ' ~ ',
                            style: TextStyle(
                              fontFamily: 'PretendardGOV',
                              fontWeight: FontWeight.w700,
                              fontSize: 32.sp,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            width: 300.w,
                            height: 60.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          SizedBox(width: 50.w),
                          Container(
                            width: 102.w,
                            height: 60.h,
                            decoration: BoxDecoration(
                              color: Color(0xff5664d2),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: InkWell(
                              onTap: () {},
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '조회',
                                    style: TextStyle(
                                      fontFamily: 'PretendardGOV',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 32.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 347.w),
                    Container(
                      width: 320.w,
                      height: 80.h,
                      decoration: BoxDecoration(
                        color: Color(0xff3cbfad),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: InkWell(
                        onTap: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: 40.w,
                              height: 40.h,
                              child: Image.asset('assets/icons/cctv.png'),
                            ),
                            Text(
                              'CCTV',
                              style: TextStyle(
                                fontFamily: 'PretendardGOV',
                                fontWeight: FontWeight.w700,
                                fontSize: 48.sp,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 275.w, top: 20.h),
                child: Row(
                  children: [
                    _intervalButton('10분'),
                    SizedBox(width: 16.w),
                    _intervalButton('30분'),
                    SizedBox(width: 16.w),
                    _intervalButton('1시간'),
                    SizedBox(width: 16.w),
                    _intervalButton('3시간'),
                    SizedBox(width: 16.w),
                    _intervalButton('6시간'),
                  ],
                ),
              ),
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
              SizedBox(height: 34.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 203.w),
                child: Container(
                  width: 3417.w,
                  height: 610.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: SfCartesianChart(
                    margin: EdgeInsets.all(20),
                    title: ChartTitle(text: '센서 변위 데이터'),
                    legend: Legend(isVisible: true),
                    primaryXAxis: DateTimeAxis(
                      intervalType: DateTimeIntervalType.minutes,
                      interval: selectedInterval == '10분' ? 10 : _getIntervalValue() * 60,
                      dateFormat: DateFormat('HH:mm'),
                      majorGridLines: const MajorGridLines(width: 0.5),
                      labelStyle: TextStyle(fontSize: _getFontSize()),
                      labelRotation: 45,
                      minimum: DateTime(2025, 5, 12, 0, 0),
                      maximum: DateTime(2025, 5, 12, 23, 59),
                    ),
                    primaryYAxis: NumericAxis(
                      minimum: -0.5,
                      maximum: 0.5,
                      interval: 0.1,
                      axisLine: const AxisLine(width: 0.5),
                    ),
                    series: <LineSeries<DisplacementData, DateTime>>[
                      LineSeries<DisplacementData, DateTime>(
                        name: '센서 A',
                        dataSource: _getIntervalData(getMockDisplacementData()),
                        xValueMapper: (d, _) => d.time,
                        yValueMapper: (d, _) => d.value,
                        markerSettings: const MarkerSettings(isVisible: true),
                      ),
                      LineSeries<DisplacementData, DateTime>(
                        name: '센서 B',
                        dataSource: _getIntervalData(getMockSecondaryData()),
                        xValueMapper: (d, _) => d.time,
                        yValueMapper: (d, _) => d.value,
                        markerSettings: const MarkerSettings(isVisible: true),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  double _getIntervalValue() {
    switch (selectedInterval) {
      case '10분':
        return 1;
      case '30분':
        return 3;
      case '1시간':
        return 6;
      case '3시간':
        return 18;
      case '6시간':
        return 36;
      default:
        return 1;
    }
  }

  double _getFontSize() {
    switch (selectedInterval) {
      case '10분':
        return 9.sp;
      case '30분':
        return 10.sp;
      case '1시간':
        return 12.sp;
      case '3시간':
        return 13.sp;
      case '6시간':
        return 14.sp;
      default:
        return 10.sp;
    }
  }

  List<DisplacementData> _getIntervalData(List<DisplacementData> original) {
    switch (selectedInterval) {
      case '30분':
        return _aggregateData(original, Duration(minutes: 30));
      case '1시간':
        return _aggregateData(original, Duration(hours: 1));
      case '3시간':
        return _aggregateData(original, Duration(hours: 3));
      case '6시간':
        return _aggregateData(original, Duration(hours: 6));
      default:
        return original;
    }
  }

  List<DisplacementData> _aggregateData(List<DisplacementData> data, Duration interval) {
    final List<DisplacementData> aggregated = [];
    if (data.isEmpty) return aggregated;
    DateTime current = data.first.time;
    DateTime end = current.add(interval);
    List<double> buffer = [];
    for (final d in data) {
      if (d.time.isBefore(end)) {
        buffer.add(d.value);
      } else {
        if (buffer.isNotEmpty) {
          final avg = buffer.reduce((a, b) => a + b) / buffer.length;
          aggregated.add(DisplacementData(current, avg));
        }
        current = end;
        end = current.add(interval);
        buffer = [d.value];
      }
    }
    if (buffer.isNotEmpty) {
      final avg = buffer.reduce((a, b) => a + b) / buffer.length;
      aggregated.add(DisplacementData(current, avg));
    }
    return aggregated;
  }

  Widget _intervalButton(String label) {
    final isSelected = selectedInterval == label;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Color(0xff3cbfad) : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
      onPressed: () {
        setState(() => selectedInterval = label);
      },
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'PretendardGOV',
          fontWeight: FontWeight.w600,
          fontSize: 28.sp,
        ),
      ),
    );
  }
}

class DisplacementData {
  final DateTime time;
  final double value;
  DisplacementData(this.time, this.value);
}

List<DisplacementData> getMockDisplacementData() {
  final start = DateTime(2025, 5, 12, 0, 0);
  return List.generate(144, (index) {
    final time = start.add(Duration(minutes: index * 10));
    final value = (0.5 - (index % 20) * 0.05) * (index % 2 == 0 ? 1 : -1);
    return DisplacementData(time, value);
  });
}

List<DisplacementData> getMockSecondaryData() {
  final start = DateTime(2025, 5, 12, 0, 0);
  return List.generate(144, (index) {
    final time = start.add(Duration(minutes: index * 10));
    final value = (0.4 - (index % 15) * 0.04) * (index % 3 == 0 ? 1 : -1);
    return DisplacementData(time, value);
  });
}
