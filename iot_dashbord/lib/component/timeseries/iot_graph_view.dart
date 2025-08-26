// ✅ 최종 리팩토링된 iot_graph_view.dart 20250704
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:iot_dashboard/component/timeseries/show_loading_dialog.dart';
import 'package:provider/provider.dart';
import 'package:iot_dashboard/controller/iot_controller.dart';
import 'package:iot_dashboard/screen/timeseries_screen.dart';

class IotGraphView extends StatefulWidget {
  final TimeRange timeRange;
  final void Function(String rid) onRidTap;
  final ValueNotifier<Set<String>> selectedDownloadRids;

  const IotGraphView(
      {super.key,
        required this.timeRange,
        required this.onRidTap,
        required this.selectedDownloadRids});

  @override
  State<IotGraphView> createState() => _IotGraphViewState();
}

class _IotGraphViewState extends State<IotGraphView> {
  late TooltipBehavior _tooltipBehavior;
  String selectedInterval = '30분';
  DateTime? _axisStart;   // X축 시작(자정)
  DateTime? _axisEnd;     // X축 끝(다음 자정)
  List<DisplacementGroup> groups = [];
  Map<String, String> selectedIntervals = {};
  final ScrollController _scrollController = ScrollController();
  bool _isCancelled = false;

  bool _isSelected(String rid) {
    final selected = widget.selectedDownloadRids.value;
    return selected.contains('ALL') || selected.contains(rid);
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _loadData);
  }

  @override
  void didUpdateWidget(covariant IotGraphView oldWidget) {
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
    _isCancelled = false;
    showLoadingDialog(context, onCancel: () { _isCancelled = true; });

    final rawStart = widget.timeRange.start;
    final rawEnd   = widget.timeRange.end;

    // 자정 스냅
    DateTime dayStart = DateTime(rawStart.year, rawStart.month, rawStart.day); // 00:00
    DateTime dayEnd   = DateTime(rawEnd.year, rawEnd.month, rawEnd.day);
    if (dayEnd.isAtSameMomentAs(dayStart)) {
      dayEnd = dayStart.add(const Duration(days: 1));
    } else {
      final endIsMidnight = rawEnd.hour == 0 && rawEnd.minute == 0 && rawEnd.second == 0;
      dayEnd = endIsMidnight ? dayEnd : dayEnd.add(const Duration(days: 1));
    }

    // ⬇️ 상태에 저장 (여기서 정의하면 build에서 접근 가능)
    _axisStart = dayStart;
    _axisEnd   = dayEnd;

    // 데이터 로드
    final iot = context.read<IotController>();
    await iot.fetchSensorDataByTimeRange(rawStart, rawEnd);
    if (_isCancelled) return;

    groups = iot.getFilteredDisplacementGroups()..sort((a, b) {
      final aNum = int.tryParse(a.rid.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      final bNum = int.tryParse(b.rid.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return aNum.compareTo(bNum);
    });

    for (final g in groups) {
      selectedIntervals[g.rid] = '30분';
    }
    if (groups.isNotEmpty) widget.onRidTap(groups.first.rid);

    Navigator.of(context).pop();
    if (mounted && !_isCancelled) setState(() {});
  }



  @override
  Widget build(BuildContext context) {
    ScreenUtil.ensureScreenSize();
    return ValueListenableBuilder<Set<String>>(
        valueListenable: widget.selectedDownloadRids,
        builder: (context, selectedRids, _) {
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
        });
    ;
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
      // format은 생략(커스텀 빌더가 우선)
      builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
        final d = data as DisplacementData;
        final timeStr = DateFormat('HH:mm').format(d.time);

        // 시리즈 컬러(마커 점 색) 안전 캐스팅
        Color? seriesColor;
        if (series is CartesianSeries) {
          final c = series.color;
          if (c is Color) seriesColor = c;
        }
        seriesColor ??= const Color(0xff32ade6); // 기본색(예비)

        return Container(
          constraints: BoxConstraints(minWidth: 200.w, maxWidth: 280.w),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: const Color(0xFF2B3253), // 기존 다크톤과 톤 맞춤
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10.r,
                offset: Offset(0, 4.h),
              ),
            ],
            border: Border.all(color: Colors.white12, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더: 시간(굵게)
              Text(
                timeStr,
                style: TextStyle(
                  fontFamily: 'PretendardGOV',
                  fontWeight: FontWeight.w700,
                  fontSize: 22.sp,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 6.h),
              Container(height: 1.h, width: double.infinity, color: Colors.white24),
              SizedBox(height: 6.h),
              // 본문: "13:15 : -306.0" (원본값)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10.w,
                    height: 10.w,
                    margin: EdgeInsets.only(right: 8.w),
                    decoration: BoxDecoration(color: seriesColor, shape: BoxShape.circle),
                  ),
                  Flexible(
                    child: Text(
                      '$timeStr : ${d.rawValue.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontFamily: 'PretendardGOV',
                        fontWeight: FontWeight.w400,
                        fontSize: 20.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
                InkWell(
                  onTap: () {
                    final current = widget.selectedDownloadRids.value;
                    if (current.contains('ALL')) current.remove('ALL');
                    if (current.contains(group.rid)) {
                      current.remove(group.rid);
                    } else {
                      current.add(group.rid);
                    }
                    widget.selectedDownloadRids.value = Set.from(current);
                  },
                  child: Container(
                    width: 45.w,
                    height: 45.h,
                    decoration: BoxDecoration(
                      color: _isSelected(group.rid)
                          ? const Color(0xff3182ce)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(5.r),
                      border: Border.all(color: Colors.white, width: 2.w),
                    ),
                    child: _isSelected(group.rid)
                        ? Icon(Icons.check, color: Colors.white, size: 28.sp)
                        : null,
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

              primaryXAxis: DateTimeAxis(
                intervalType: DateTimeIntervalType.minutes,
                interval: 30,                           // 눈금 30분 간격
                dateFormat: DateFormat('HH:mm'),
                labelRotation: 45,
                majorGridLines: const MajorGridLines(width: 0),
                minimum: _axisStart,
                maximum: _axisEnd,
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
                LineSeries<DisplacementData, DateTime>(
                  name: 'X',
                  color: const Color(0xffff714d),
                  width: 1.5.w,          // ✅ 선 얇게
                  opacity: 0.4,        // ✅ 선 흐릿하게
                  markerSettings: MarkerSettings(
                    isVisible: true,
                    shape: DataMarkerType.circle,
                    width: 15.w,
                    height: 15.h,
                  ),
                  dataSource: group.x,
                  xValueMapper: (d, _) => d.time,
                  yValueMapper: (d, _) =>_clampY(d.value),
                ),
                LineSeries<DisplacementData, DateTime>(
                  name: 'Y',
                  color: const Color(0xff32ade6),
                  width: 1.5.w,          // ✅ 선 얇게
                  opacity: 0.4,        // ✅ 선 흐릿하게
                  markerSettings: MarkerSettings(
                    isVisible: true,
                    shape: DataMarkerType.circle,
                    width: 15.w,
                    height: 15.h,
                  ),
                  dataSource: _getIntervalData(group.y, interval),
                  xValueMapper: (d, _) => d.time,
                  yValueMapper: (d, _) => _clampY(d.value),
                ),
                LineSeries<DisplacementData, DateTime>(
                  name: 'Z',
                  color: const Color(0xff00c7be),
                  width: 1.5.w,          // ✅ 선 얇게
                  opacity: 0.4,        // ✅ 선 흐릿하게
                  markerSettings: MarkerSettings(
                    isVisible: true,
                    shape: DataMarkerType.circle,
                    width: 15.w,
                    height: 15.h,
                  ),
                  dataSource: _getIntervalData(group.z, interval),
                  xValueMapper: (d, _) => d.time,
                  yValueMapper: (d, _) =>_clampY(d.value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<DisplacementData> _getIntervalData(
      List<DisplacementData> original,
      String intervalLabel,
      ) {
    if (original.isEmpty) return [];

    Duration window;
    switch (intervalLabel) {
      case '30분': window = const Duration(minutes: 30); break;
      case '1시간': window = const Duration(hours: 1); break;
      case '2시간': window = const Duration(hours: 2); break;
      case '3시간': window = const Duration(hours: 3); break;
      default: return original; // 혹시 모를 기본값
    }


    final allTimes = original.map((e) => e.time).toList()..sort();
    DateTime minT = _floorToWindow(allTimes.first, window);
    DateTime maxT = _ceilToWindow(allTimes.last, window);

    final buckets = <DateTime, List<double>>{};
    for (var t = minT; !t.isAfter(maxT); t = t.add(window)) {
      buckets[t] = [];
    }

    // ✅ 원본값(rawValue)로 버킷 평균 계산
    for (final d in original) {
      final b = _floorToWindow(d.time, window);
      if (buckets.containsKey(b)) {
        buckets[b]!.add(d.rawValue);
      }
    }

    final half = Duration(milliseconds: (window.inMilliseconds / 2).round());
    final out = <DisplacementData>[];
    buckets.forEach((bucketStart, values) {
      if (values.isEmpty) return;
      final rawAvg = values.reduce((a, b) => a + b) / values.length;
      // ✅ value는 클램프, rawValue는 원본 평균
      out.add(DisplacementData(bucketStart.add(half), _clampY(rawAvg), rawAvg));
    });

    return out;
  }

  DateTime _floorToWindow(DateTime dt, Duration window) {
    if (window.inMinutes == 30) {
      final snap = (dt.minute < 30) ? 0 : 30;
      return DateTime(dt.year, dt.month, dt.day, dt.hour, snap);
    }
    if (window.inHours >= 1) {
      final w = window.inHours;
      final hour = (dt.hour ~/ w) * w; // 예: 2시간 → 0,2,4...
      return DateTime(dt.year, dt.month, dt.day, hour);
    }
    return dt;
  }

  DateTime _ceilToWindow(DateTime dt, Duration window) {
    final f = _floorToWindow(dt, window);
    if (f == dt) return dt;
    return f.add(window);
  }

  List<DisplacementData> _aggregateData(
      List<DisplacementData> data, Duration interval) {
    final List<DisplacementData> aggregated = [];
    if (data.isEmpty) return aggregated;

    DateTime current = data.first.time;
    DateTime end = current.add(interval);
    List<double> buffer = [];

    for (final d in data) {
      buffer.add(d.rawValue); // ✅ 원본값 사용
      if (!d.time.isBefore(end)) {
        if (buffer.isNotEmpty) {
          final maxVal = buffer.reduce((a, b) => a > b ? a : b);   // ✅ 최대값
          final intVal = maxVal.round();                           // ✅ 정수화
          aggregated.add(DisplacementData(current, _clampY(intVal.toDouble()), intVal.toDouble()));
        }
        current = end;
        end = current.add(interval);
        buffer = [d.rawValue];
      }
    }

    if (buffer.isNotEmpty) {
      final maxVal = buffer.reduce((a, b) => a > b ? a : b);       // ✅ 최대값
      final intVal = maxVal.round();                               // ✅ 정수화
      aggregated.add(DisplacementData(current, _clampY(intVal.toDouble()), intVal.toDouble()));
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
  final double value;     // 그래프에 쓸 클램프 값
  final double rawValue;  // 툴팁에 보여줄 원본 값

  DisplacementData(this.time, this.value, this.rawValue);
}

double _clampY(double v) {
  if (v > 5) return 5;
  if (v < -5) return -5;
  return v;
}
class DisplacementGroup {
  final String rid;
  final List<DisplacementData> x;
  final List<DisplacementData> y;
  final List<DisplacementData> z;

  DisplacementGroup(
      {required this.rid, required this.x, required this.y, required this.z});
}
