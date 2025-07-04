// ✅ 최종 리팩토링된 graph_view.dart 20250704
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:iot_dashboard/component/timeseries/show_loading_dialog.dart';
import 'package:provider/provider.dart';
import 'package:iot_dashboard/controller/iot_controller.dart';
import 'package:iot_dashboard/screen/timeseries_screen.dart';
import 'package:iot_dashboard/model/iot_model.dart'; // ← IotItem이 여기 들어있어야 함

class GraphView extends StatefulWidget {
  final TimeRange timeRange;
  final void Function(String rid) onRidTap;

  const GraphView({super.key, required this.timeRange, required this.onRidTap});

  @override
  State<GraphView> createState() => _GraphViewState();
}

class _GraphViewState extends State<GraphView> {
  late TooltipBehavior _tooltipBehavior;
  String selectedInterval = '30분';
  List<DisplacementGroup> groups = [];
  Map<String, String> selectedIntervals = {};
  final ScrollController _scrollController = ScrollController();

  @override
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _loadData);
  }


  @override
  void didUpdateWidget(covariant GraphView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_isSameTimeRange(widget.timeRange, oldWidget.timeRange)) {
      debugPrint('✅ TimeRange 변경 감지 → _loadData() 호출');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadData();
      });
    }
  }



  bool _isSameTimeRange(TimeRange a, TimeRange b) {
    return a.start == b.start && a.end == b.end;
  }

  Future<void> _loadData() async {
    showLoadingDialog(context);
    final iot = context.read<IotController>();
    final start = widget.timeRange.start;
    final end = widget.timeRange.end;

    await iot.fetchSensorDataByTimeRange(start, end);

    groups = iot.getFilteredDisplacementGroups();
    debugPrint('🎯 데이터 개수: ${iot.items.length}');
    debugPrint('🎯 필터된 그룹 개수: ${groups.length}');

    groups.sort((a, b) {
      final aNum = int.tryParse(a.rid.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      final bNum = int.tryParse(b.rid.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return aNum.compareTo(bNum);
    });

    for (final g in groups) {
      selectedIntervals[g.rid] = '30분';
    }

    if (groups.isNotEmpty) widget.onRidTap(groups.first.rid);
    Navigator.of(context).pop();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.ensureScreenSize();
    return Container(
      width: 2916.w,
      height: 1648.h,
      decoration: BoxDecoration(
        color: Color(0xff414c67),
        borderRadius: BorderRadius.circular(5.r),
        border: Border.all(color: Color(0xff414c67), width: 4.w),
      ),
      child: ScrollbarTheme(
        data: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.all(Color(0xff004aff)),
          trackColor: MaterialStateProperty.all(Colors.white),
          radius: Radius.circular(10.r),
          thickness: MaterialStateProperty.all(10.w),
        ),
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
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
      ),
    );
  }

  int _getCategoryAxisInterval(String intervalLabel) {
    switch (intervalLabel) {
      case '30분':
        return 1; // 실제 데이터는 30분 간격으로 입력됨
      case '1시간':
        return 2; // 30분 * 2 = 1시간
      case '2시간':
        return 4;
      case '3시간':
        return 6;
      default:
        return 1;
    }
  }

  Widget _buildSensorChart(DisplacementGroup group) {
    final interval = selectedIntervals[group.rid] ?? '30분';
    final allTimes = [...group.x, ...group.y, ...group.z].map((e) => e.time);
    final xMin = allTimes.isNotEmpty
        ? allTimes.reduce((a, b) => a.isBefore(b) ? a : b)
        : DateTime.now();
    final xMax = allTimes.isNotEmpty
        ? allTimes.reduce((a, b) => a.isAfter(b) ? a : b)
        : DateTime.now();

    _tooltipBehavior = TooltipBehavior(
      enable: true,
      shared: true,
      canShowMarker: true,
      tooltipPosition: TooltipPosition.pointer,
      format: 'point.x : point.y',
    );

    return Container(
      height: 580.h,
      color: Color(0xff0b1437),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 73.51.h,
            padding: EdgeInsets.only(top: 6.h, left: 3.w),
            alignment: Alignment.bottomLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    widget.onRidTap(group.rid); // ✅ 부모에게 RID 전달
                  },
                  child: Container(
                    width: 432.w,
                    height: 80.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color(0xff3182ce),
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: Text('[${group.rid}]',
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
          Container(
            width: double.infinity,
            height: 505.h,
            decoration: BoxDecoration(
              color: Color(0xff0b1437),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: SfCartesianChart(
              tooltipBehavior: _tooltipBehavior,
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
                ),
              ),
              primaryXAxis: DateTimeCategoryAxis(
                intervalType: DateTimeIntervalType.minutes,
                interval: _getCategoryAxisInterval(interval).toDouble(),
                // ✅ 정상

                dateFormat: DateFormat('HH:mm'),
                labelRotation: 45,
                labelPlacement: LabelPlacement.onTicks,
                labelIntersectAction: AxisLabelIntersectAction.none,
                majorGridLines: const MajorGridLines(width: 0),
                minimum: xMin.subtract(Duration(minutes: 5)),
                maximum: xMax.add(Duration(minutes: 5)),
                labelStyle: TextStyle(fontSize: 18.sp, color: Colors.white),
              ),
              primaryYAxis: NumericAxis(
                minimum: -5,
                maximum: 5,
                interval: 1,

                majorGridLines: const MajorGridLines(width: 0),
                plotBands: [
                  ...[5, -5, 3, -3, 0].map((v) => PlotBand(
                        isVisible: true,
                        start: v,
                        end: v,
                        borderWidth: 2,
                        borderColor: v == 0
                            ? Colors.white
                            : (v.abs() == 3
                                ? Color(0xffffc300)
                                : Color(0xffff0404)),
                      ))
                ],
              ),
              series: [
                ScatterSeries<DisplacementData, DateTime>(
                  name: 'X',
                  color: const Color(0xffff714d),
                  markerSettings: MarkerSettings(
                    isVisible: true,
                    shape: DataMarkerType.circle,
                    width: 15.w,
                    height: 15.h,
                  ),
                  dataSource: group.x,
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
                  dataSource: _getIntervalData(group.y, interval),
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

  int _getIntervalValue(DateTime xMin, DateTime xMax) {
    final duration = xMax.difference(xMin).inMinutes;
    if (duration >= 7 * 24 * 60) return 60;
    if (duration >= 30 * 24 * 60) return 180;
    return 30;
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

  DisplacementGroup(
      {required this.rid, required this.x, required this.y, required this.z});
}
