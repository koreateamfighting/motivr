import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:iot_dashboard/component/timeseries/show_loading_dialog.dart';
import 'package:provider/provider.dart';
import 'package:iot_dashboard/controller/iot_controller.dart';
import 'package:iot_dashboard/screen/timeseries_screen.dart';



class GraphView extends StatefulWidget {
  final TimeRange timeRange;
  final void Function(String rid) onRidTap; // ✅ 추가
  const GraphView({
    super.key,
    required this.timeRange,
    required this.onRidTap,
  });

  @override
  State<GraphView> createState() => _GraphViewState();
}
class _GraphViewState extends State<GraphView> {
  late TooltipBehavior _tooltipBehavior;
  String selectedInterval = '30분';
  List<DisplacementGroup> groups = [];
  Map<String, String> selectedIntervals = {};
  final ScrollController _scrollController = ScrollController();

  late DateTime xMin;
  late DateTime xMax;

  void initState() {
    super.initState();

    if (groups.isNotEmpty && widget.onRidTap != null) {
      widget.onRidTap!(groups.first.rid); // ✅ 첫 rid 알림
    }

    Future.delayed(Duration.zero, () async {
      showLoadingDialog(context);
      final iot = context.read<IotController>();
      await iot.fetchRecentSensorData(days: 1);

// TimeRange 값을 이용해 데이터 조회
      await iot.fetchSensorDataByTimeRange(widget.timeRange.start, widget.timeRange.end);

      groups = iot.getTodayDisplacementGroups();

      groups.sort((a, b) {
        final aNum = int.tryParse(a.rid.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final bNum = int.tryParse(b.rid.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return aNum.compareTo(bNum);
      });

      for (final g in groups) {
        selectedIntervals[g.rid] = '30분';
      }

      Navigator.of(context).pop();
      setState(() {});
    });
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
                children: groups.map(_buildSensorChart).toList(),
              ),
            ),
          ),
        ));
  }

  Widget _buildSensorChart(DisplacementGroup group)
  {
    final interval = selectedIntervals[group.rid] ?? '30분';
    final allTimes = [...group.x, ...group.y, ...group.z].map((e) => e.time);
    final xMin = allTimes.isNotEmpty ? allTimes.reduce((a, b) => a.isBefore(b) ? a : b) : DateTime.now();
    final xMax = allTimes.isNotEmpty ? allTimes.reduce((a, b) => a.isAfter(b) ? a : b) : DateTime.now();
    _tooltipBehavior = TooltipBehavior(
      enable: true,
      shared: true,
      canShowMarker: true,
      tooltipPosition: TooltipPosition.pointer,
      format: 'point.x : point.y', // 👉 기본 형식
    );

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
                InkWell(
                  onTap: (){
                    widget.onRidTap(group.rid); // ✅ 부모에게 RID 전달
                  },
                  child:         Container(
                    width: 432.w,
                    height: 80.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color(0xff3182ce),
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child:Text('[${group.rid}]',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PretendardGOV',
                          fontWeight: FontWeight.w700,
                          fontSize: 40.sp,
                          color: Colors.white,
                        )),
                  ),
                ),

                SizedBox(
                  width: 22.w,
                ),

                ...['30분', '1시간', '2시간', '3시간'].map((label) => Padding(
                  padding: EdgeInsets.only(right: 10.w),
                  child: InkWell(
                    onTap: () async {
                      showLoadingDialog(context);
                      await Future.delayed(Duration(milliseconds: 200));
                      setState(() {
                        selectedIntervals[group.rid] = label;
                      });
                      Navigator.of(context).pop();
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
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontFamily: 'PretendardGOV',
                          fontWeight: FontWeight.w400,
                          fontSize: 24.sp,
                          color: Color(0xff3182ce),
                        ),
                      ),
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
              tooltipBehavior: _tooltipBehavior, // ✅ 추가!
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
                interval: _getIntervalValue(xMin, xMax).toDouble(),
                 // ← 이 줄 수정!
                dateFormat: DateFormat('HH:mm'),
                labelRotation: 45,
                labelIntersectAction: AxisLabelIntersectAction.none,
                minimum: xMin.subtract(Duration(minutes: 5)),
                maximum: xMax.add(Duration(minutes: 5)),
                // ⬅️ 마지막을 23:59로 명시
                majorGridLines: const MajorGridLines(width: 0),
                labelStyle: TextStyle(
                  fontSize: interval  == '10분' ? 10.sp : 18.sp,
                  // 👈 조건부 스타일
                  color: Colors.white,
                ),
              ),
              primaryYAxis: NumericAxis(
                minimum: -5,
                maximum: 5,
                interval: 1,
                majorGridLines: const MajorGridLines(width: 0),
                plotBands: <PlotBand>[
                  PlotBand(
                    isVisible: true,
                    start: 5,
                    end: 5,
                    borderWidth: 2,
                    borderColor: Color(0xffff0404),
                  ),
                  PlotBand(
                    isVisible: true,
                    start: -5,
                    end: -5,
                    borderWidth: 2,
                    borderColor: Color(0xffff0404),
                  ),
                  PlotBand(
                    isVisible: true,
                    start: 3,
                    end: 3,
                    borderWidth: 2,
                    borderColor: Color(0xffffc300),
                  ),
                  PlotBand(
                    isVisible: true,
                    start: -3,
                    end: -3,
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
                  enableTooltip: true,
                  markerSettings: MarkerSettings(
                    isVisible: true,
                    shape: DataMarkerType.circle,
                    width: 15.w,
                    height: 15.h,
                  ),
                  dataSource: _getIntervalData(group.x, interval),
                  xValueMapper: (d, _) => d.time,
                  yValueMapper: (d, _) => d.value,
                ),
                ScatterSeries<DisplacementData, DateTime>(
                  name: 'Y',
                  enableTooltip: true,
                  color: const Color(0xff32ade6),
                  markerSettings: MarkerSettings(
                    isVisible: true,
                    shape: DataMarkerType.circle,
                    width: 15.w,
                    height: 15.h,
                  ),
                  dataSource:_getIntervalData(group.y, interval),
                  xValueMapper: (d, _) => d.time,
                  yValueMapper: (d, _) => d.value,
                ),
                ScatterSeries<DisplacementData, DateTime>(
                  name: 'Z',
                  enableTooltip: true,
                  color: const Color(0xff00c7be),
                  markerSettings: MarkerSettings(
                    isVisible: true,
                    shape: DataMarkerType.circle,
                    width: 15.w,
                    height: 15.h,
                  ),
                  dataSource: _getIntervalData(group.z, interval),
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
    final interval = _getIntervalValue(xMin, xMax);
    return List.generate(144, (index) {
      final time = start.add(Duration(minutes: (index * interval).toInt() + 9)); // .toInt()로 강제 형변환

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

  int _getIntervalValue(DateTime xMin, DateTime xMax) {
    final duration = xMax.difference(xMin).inMinutes;

    // 일주일 또는 그 이상일 때는 더 긴 간격을 설정
    if (duration >= 7 * 24 * 60) {
      return 60; // 1시간 간격
    } else if (duration >= 30 * 24 * 60) {
      return 180; // 3시간 간격
    } else {
      return 30; // 30분 간격
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

class DisplacementGroup {
  final String rid;
  final List<DisplacementData> x;
  final List<DisplacementData> y;
  final List<DisplacementData> z;

  DisplacementGroup({required this.rid, required this.x, required this.y, required this.z});
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
