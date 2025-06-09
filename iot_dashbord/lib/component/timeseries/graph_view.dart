import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:iot_dashboard/component/timeseries/show_loading_dialog.dart';

class GraphView extends StatefulWidget {
  const GraphView({super.key});

  @override
  State<GraphView> createState() => _GraphViewState();
}

class _GraphViewState extends State<GraphView> {
  String selectedInterval = '10분';
  final List<String> sensorIds = [
    'S1_001',
    'S1_002',
    'S1_003',
    'S1_004',
    'S1_005'
  ];
  Map<String, String> selectedIntervals = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      showLoadingDialog(context);
      await Future.delayed(Duration(milliseconds: 3000)); // fetch 초기 그래프 데이터
      Navigator.of(context).pop();
    });
    for (var id in sensorIds) {
      selectedIntervals[id] = '10분';
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.ensureScreenSize();
    return Container(
        width: 2916.w, // 🔹 기존보다 10.w 넓힘
        height: 1648.h,
        decoration: BoxDecoration(
          color: Color(0xff414c67),
          borderRadius: BorderRadius.circular(5.r),
          border: Border.all(color: Color(0xff414c67), width: 4.w),
        ),
        child: ScrollbarTheme(
          data: ScrollbarThemeData(
            thumbColor: MaterialStateProperty.all(Color(0xff004aff)),
            // 파란색 스크롤바
            trackColor: MaterialStateProperty.all(Colors.white),
            radius: Radius.circular(10.r),
            thickness: MaterialStateProperty.all(10.w),
          ),
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            // thickness: 6.w,
            radius: Radius.circular(5.r),
            trackVisibility: true,
            scrollbarOrientation: ScrollbarOrientation.right,
            interactive: true,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: sensorIds.map((id) => _buildSensorChart(id)).toList(),
              ),
            ),
          ),
        ));
  }

  Widget _buildSensorChart(String sensorId) {
    final currentInterval = selectedIntervals[sensorId]!;

    return Container(
      height: 580.h,
      color: Color(0xff0b1437),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // 상단 센서 ID 및 버튼 줄
          Container(
            height: 73.51.h,
            padding: EdgeInsets.only(top: 6.h, left: 3.w),
            alignment: Alignment.bottomLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 432.w,
                  height: 80.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(0xff3182ce),
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: Text('[$sensorId]',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'PretendardGOV',
                        fontWeight: FontWeight.w700,
                        fontSize: 40.sp,
                        color: Colors.white,
                      )),
                ),
                SizedBox(
                  width: 22.w,
                ),
                InkWell(
                    onTap: () {
                      setState(() {
                        selectedIntervals[sensorId] = '10분';
                      });
                    },
                    child: Container(
                      width: 101.w,
                      height: 60.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Color(0xff3182ce),
                          width: 1.w,
                        ),
                        borderRadius:
                            BorderRadius.circular(5.r), // 선택사항: 둥근 테두리
                      ),
                      child: Text(
                        '10분',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PretendardGOV',
                          fontWeight: FontWeight.w400,
                          fontSize: 24.sp,
                          color: Color(0xff3182ce),
                        ),
                      ),
                    )),
                SizedBox(
                  width: 10.w,
                ),
                InkWell(
                    onTap: () async {
                      showLoadingDialog(context); // 👈 로딩 다이얼로그 표시
                      await Future.delayed(Duration(
                          milliseconds: 300)); // 실제 API 호출이라면 await fetch...
                      setState(() {
                        selectedIntervals[sensorId] = '30분';
                      });
                      Navigator.of(context).pop(); // 👈 다이얼로그 닫기
                    },
                    child: Container(
                      width: 101.w,
                      height: 60.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Color(0xff3182ce),
                          width: 1.w,
                        ),
                        borderRadius:
                            BorderRadius.circular(5.r), // 선택사항: 둥근 테두리
                      ),
                      child: Text(
                        '30분',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PretendardGOV',
                          fontWeight: FontWeight.w400,
                          fontSize: 24.sp,
                          color: Color(0xff3182ce),
                        ),
                      ),
                    )),
                SizedBox(
                  width: 10.w,
                ),
                InkWell(
                    onTap: () async {
                      showLoadingDialog(context); // 👈 로딩 다이얼로그 표시
                      await Future.delayed(Duration(
                          milliseconds: 300)); // 실제 API 호출이라면 await fetch...
                      setState(() {
                        selectedIntervals[sensorId] = '1시간';
                      });
                      Navigator.of(context).pop(); // 👈 다이얼로그 닫기
                    },
                    child: Container(
                      width: 101.w,
                      height: 60.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Color(0xff3182ce),
                          width: 1.w,
                        ),
                        borderRadius:
                            BorderRadius.circular(5.r), // 선택사항: 둥근 테두리
                      ),
                      child: Text(
                        '1시간',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PretendardGOV',
                          fontWeight: FontWeight.w400,
                          fontSize: 24.sp,
                          color: Color(0xff3182ce),
                        ),
                      ),
                    )),
                SizedBox(
                  width: 10.w,
                ),
                InkWell(
                    onTap: () async {
                      showLoadingDialog(context); // 👈 로딩 다이얼로그 표시
                      await Future.delayed(Duration(
                          milliseconds: 300)); // 실제 API 호출이라면 await fetch...
                      setState(() {
                        selectedIntervals[sensorId] = '2시간';
                      });
                      Navigator.of(context).pop(); // 👈 다이얼로그 닫기
                    },
                    child: Container(
                      width: 101.w,
                      height: 60.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Color(0xff3182ce),
                          width: 1.w,
                        ),
                        borderRadius:
                            BorderRadius.circular(5.r), // 선택사항: 둥근 테두리
                      ),
                      child: Text(
                        '2시간',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PretendardGOV',
                          fontWeight: FontWeight.w400,
                          fontSize: 24.sp,
                          color: Color(0xff3182ce),
                        ),
                      ),
                    )),
                SizedBox(
                  width: 10.w,
                ),
                InkWell(
                    onTap: () async {
                      showLoadingDialog(context); // 👈 로딩 다이얼로그 표시
                      await Future.delayed(Duration(
                          milliseconds: 300)); // 실제 API 호출이라면 await fetch...
                      setState(() {
                        selectedIntervals[sensorId] = '3시간';
                      });
                      Navigator.of(context).pop(); // 👈 다이얼로그 닫기
                    },
                    child: Container(
                      width: 101.w,
                      height: 60.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Color(0xff3182ce),
                          width: 1.w,
                        ),
                        borderRadius:
                            BorderRadius.circular(5.r), // 선택사항: 둥근 테두리
                      ),
                      child: Text(
                        '3시간',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PretendardGOV',
                          fontWeight: FontWeight.w400,
                          fontSize: 24.sp,
                          color: Color(0xff3182ce),
                        ),
                      ),
                    )),
                Spacer(),
                Container(
                  width: 45.w,
                  height: 45.h,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(5.r),
                    border: Border.all(color: Colors.white, width: 2.w),
                  ),
                ),
                SizedBox(
                  width: 33.5.w,
                ),
              ],
            ),
          ),
          // 그래프 영역
          Container(
            width: double.infinity,
            height: 505.h,
            decoration: BoxDecoration(
              color: Color(0xff0b1437),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: SfCartesianChart(
              margin: EdgeInsets.all(20),
              legend: Legend(
                  isVisible: true,
                  position: LegendPosition.top,
                  alignment: ChartAlignment.center,
                  textStyle: TextStyle(
                    fontFamily: 'PretendardGOV',
                    fontWeight: FontWeight.w700,
                    color: Colors.grey,
                    fontSize: 36.sp,
                  )),
              primaryXAxis: DateTimeAxis(
                intervalType: DateTimeIntervalType.minutes,
                interval: 10,
                // 10분 간격
                dateFormat: DateFormat('HH:mm'),
                labelRotation: 45,
                labelIntersectAction: AxisLabelIntersectAction.none,
                minimum: DateTime(2025, 5, 12, 0, 9),
                // ⬅️ 시작을 00:09로 명시
                maximum: DateTime(2025, 5, 12, 23, 59),
                // ⬅️ 마지막을 23:59로 명시
                majorGridLines: const MajorGridLines(width: 0),
                labelStyle: TextStyle(
                  fontSize: currentInterval == '10분' ? 10.sp : 18.sp,
                  // 👈 조건부 스타일
                  color: Colors.white,
                ),
              ),
              primaryYAxis: NumericAxis(
                minimum: -0.5,
                maximum: 0.5,
                interval: 0.1,
                majorGridLines: const MajorGridLines(width: 0),
                plotBands: <PlotBand>[
                  PlotBand(
                    isVisible: true,
                    start: 0.5,
                    end: 0.5,
                    borderWidth: 2,
                    borderColor: Color(0xffff0404),
                  ),
                  PlotBand(
                    isVisible: true,
                    start: -0.5,
                    end: -0.5,
                    borderWidth: 2,
                    borderColor: Color(0xffff0404),
                  ),
                  PlotBand(
                    isVisible: true,
                    start: 0.3,
                    end: 0.3,
                    borderWidth: 2,
                    borderColor: Color(0xffffc300),
                  ),
                  PlotBand(
                    isVisible: true,
                    start: -0.3,
                    end: -0.3,
                    borderWidth: 2,
                    borderColor: Color(0xffffc300),
                  ),
                  PlotBand(
                    isVisible: true,
                    start: 0,
                    end: 0,
                    borderWidth: 2,
                    borderColor: Colors.white,
                  ),
                ],
              ),
              series:
                  /*  <LineSeries<DisplacementData, DateTime>>[
                LineSeries<DisplacementData, DateTime>(
                  name: 'X',
                  color: const Color(0xffff714d),
                  width: 0,
                  markerSettings: MarkerSettings(
                    isVisible: true,
                    shape: DataMarkerType.circle,
                    width: 6,
                    height: 6,
                  ),
                  dataSource: _getIntervalData(getMockData(sensorId, 'X', currentInterval), currentInterval),
                  xValueMapper: (d, _) => d.time,
                  yValueMapper: (d, _) => d.value,
                ),
                LineSeries<DisplacementData, DateTime>(
                  name: 'Y',
                  color: const Color(0xff32ade6),
                  width: 0,
                  markerSettings: MarkerSettings(
                    isVisible: true,
                    shape: DataMarkerType.circle,
                    width: 6,
                    height: 6,
                  ),
                  dataSource: _getIntervalData(getMockData(sensorId, 'Y', currentInterval), currentInterval),
                  xValueMapper: (d, _) => d.time,
                  yValueMapper: (d, _) => d.value,
                ),
                LineSeries<DisplacementData, DateTime>(
                  name: 'Z',
                  color: const Color(0xff00c7be),
                  width: 0,
                  markerSettings: MarkerSettings(
                    isVisible: true,
                    shape: DataMarkerType.circle,
                    width: 6,
                    height: 6,
                  ),
                  dataSource: _getIntervalData(getMockData(sensorId, 'Z', currentInterval), currentInterval),
                  xValueMapper: (d, _) => d.time,
                  yValueMapper: (d, _) => d.value,
                ),
              ],*/
                  [
                ScatterSeries<DisplacementData, DateTime>(
                  name: 'X',
                  color: const Color(0xffff714d),
                  markerSettings: MarkerSettings(
                    isVisible: true,
                    shape: DataMarkerType.circle,
                    width: 15.w,
                    height: 15.h,
                  ),
                  dataSource: _getIntervalData(
                      getMockData(sensorId, 'X', currentInterval),
                      currentInterval),
                  xValueMapper: (d, _) => d.time,
                  yValueMapper: (d, _) => d.value,
                ),
                ScatterSeries<DisplacementData, DateTime>(
                  name: 'Y',
                  color: const Color(0xff32ade6),
                  markerSettings: MarkerSettings(
                    isVisible: true,
                    shape: DataMarkerType.circle,
                    width: 15.w,
                    height: 15.h,
                  ),
                  dataSource: _getIntervalData(
                      getMockData(sensorId, 'Y', currentInterval),
                      currentInterval),
                  xValueMapper: (d, _) => d.time,
                  yValueMapper: (d, _) => d.value,
                ),
                ScatterSeries<DisplacementData, DateTime>(
                  name: 'Z',
                  color: const Color(0xff00c7be),
                  markerSettings: MarkerSettings(
                    isVisible: true,
                    shape: DataMarkerType.circle,
                    width: 15.w,
                    height: 15.h,
                  ),
                  dataSource: _getIntervalData(
                      getMockData(sensorId, 'Z', currentInterval),
                      currentInterval),
                  xValueMapper: (d, _) => d.time,
                  yValueMapper: (d, _) => d.value,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<DisplacementData> getMockData(
      String sensorId, String axis, String intervalLabel) {
    final start = DateTime(2025, 5, 12, 0, 0);
    final interval = _getIntervalValue(intervalLabel); // minutes
    return List.generate(144, (index) {
      final time = start.add(Duration(minutes: index * interval + 9));

      final base = sensorId.hashCode % 10 * 0.01;
      final offset = axis == 'X'
          ? 0.05
          : axis == 'Y'
              ? 0.04
              : 0.03;
      final value =
          (0.5 - (index % 20) * offset + base) * (index % 2 == 0 ? 1 : -1);
      return DisplacementData(time, value);
    });
  }

  int _getIntervalValue(String interval) {
    switch (interval) {
      case '10분':
        return 10;
      case '30분':
        return 30;
      case '1시간':
        return 60;
      case '2시간':
        return 120;
      case '3시간':
        return 180;
      case '6시간':
        return 360;
      default:
        return 10;
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

  List<DisplacementData> _getIntervalData(
      List<DisplacementData> original, String intervalLabel) {
    switch (intervalLabel) {
      case '30분':
        return _aggregateData(original, Duration(minutes: 30));
      case '1시간':
        return _aggregateData(original, Duration(hours: 1));
      case '2시간':
        return _aggregateData(original, Duration(hours: 2));
      case '3시간':
        return _aggregateData(original, Duration(hours: 3));
      case '6시간':
        return _aggregateData(original, Duration(hours: 6));
      default:
        return original;
    }
  }

  List<DisplacementData> _aggregateData(
      List<DisplacementData> data, Duration interval) {
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
