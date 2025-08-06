// ✅ CCTVGraphView 리팩토링 버전
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:iot_dashboard/component/timeseries/show_loading_dialog.dart';
import 'package:iot_dashboard/controller/alarm_history_controller.dart';
import 'package:iot_dashboard/screen/timeseries_screen.dart';

class CCTVGraphView extends StatefulWidget {
  final TimeRange timeRange;
  final int intervalMinutes;
  final void Function(String deviceId) onDeviceTap;
  final ValueNotifier<Set<String>> selectedDownloadDevices;

  const CCTVGraphView({
    super.key,
    required this.timeRange,
    required this.onDeviceTap,
    required this.selectedDownloadDevices,
    required this.intervalMinutes,
  });

  @override
  State<CCTVGraphView> createState() => _CCTVGraphViewState();
}

class _CCTVGraphViewState extends State<CCTVGraphView> {
  late TooltipBehavior _tooltipBehavior;
  List<CctvEventGroup> groups = [];
  final ScrollController _scrollController = ScrollController();
  bool _isCancelled = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _loadData);
  }

  @override
  void didUpdateWidget(covariant CCTVGraphView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isSameTimeRange(widget.timeRange, oldWidget.timeRange)) {
      debugPrint('✅ TimeRange 변경 감지 → _loadData() 호출');
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
    }
  }

  DateTime _normalize(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute, 0, 0, 0);
  }

  bool _isSelected(String deviceId) {
    final selected = widget.selectedDownloadDevices.value;
    return selected.contains('ALL') || selected.contains(deviceId);
  }

  DateTime roundToInterval(DateTime dt, int intervalMinutes) {
    final normalized =
        DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute, 0, 0, 0);
    final flooredMinute =
        normalized.minute - normalized.minute % intervalMinutes;
    return DateTime(normalized.year, normalized.month, normalized.day,
        normalized.hour, flooredMinute);
  }

  bool _isSameTimeRange(TimeRange a, TimeRange b) =>
      a.start == b.start && a.end == b.end;

  Future<void> _loadData() async {
    _isCancelled = false;
    showLoadingDialog(context, onCancel: () => _isCancelled = true);

    try {
      final rawData = await AlarmHistoryController.fetchCctvGraphData(
        startDate: widget.timeRange.start,
        endDate: widget.timeRange.end,
      );

      if (_isCancelled) return;

      final deviceMap = <String, List<CctvEventData>>{};
      final deviceMapRaw = <String, List<CctvEventData>>{};

      for (final item in rawData) {
        final deviceId = item['deviceId'];
        final rawTimestamp = item['timestamp'];
        final value = item['value']?.toDouble();
        if (deviceId == null || rawTimestamp == null || value == null) continue;

        final ts = rawTimestamp is String
            ? _normalize(DateTime.parse(rawTimestamp))
            : _normalize(rawTimestamp as DateTime);

        deviceMapRaw
            .putIfAbsent(deviceId, () => [])
            .add(CctvEventData(ts, value));

        final rounded = roundToInterval(ts, widget.intervalMinutes);

        final list = deviceMap.putIfAbsent(deviceId, () => []);
        final existing = list.where((e) => e.time == rounded).toList();
        if (existing.isEmpty) {
          list.add(CctvEventData(rounded, value));
        } else if (existing.first.value < value) {
          existing.first.value = value;
        }
      }
      for (final deviceId in deviceMap.keys) {
        final rawList = deviceMap[deviceId]!;

        // 👉 시간-값 매핑 생성 (rawList가 비어 있어도 문제 없음)
        final timeToValue = <DateTime, double>{};
        for (final e in rawList) {
          timeToValue[e.time] = e.value;
        }

        final filledList = <CctvEventData>[];
        final startTime = widget.timeRange.start;
        final endTime = widget.timeRange.end;
        final interval = Duration(minutes: widget.intervalMinutes);

        DateTime t = roundToInterval(startTime, widget.intervalMinutes);
        while (t.isBefore(endTime)) {
          final value = timeToValue[t] ?? 0; // 👉 없는 값은 정상 상태 0으로 보간
          filledList.add(CctvEventData(t, value));
          t = roundToInterval(t.add(interval), widget.intervalMinutes); // ✅ 간격 보장
        }

        deviceMap[deviceId] = filledList;
      }

      groups = deviceMap.entries
          .map((e) => CctvEventGroup(
                deviceId: e.key,
                data: e.value,
                rawAlarms: deviceMapRaw[e.key] ?? [],
              ))
          .toList()
        ..sort((a, b) =>
            int.parse(RegExp(r'\d+').stringMatch(a.deviceId) ?? '0').compareTo(
                int.parse(RegExp(r'\d+').stringMatch(b.deviceId) ?? '0')));

      if (groups.isNotEmpty) widget.onDeviceTap(groups.first.deviceId);
    } catch (e) {
      print('❌ 예외 발생: $e');
    } finally {
      if (mounted && !_isCancelled) {
        Navigator.of(context).pop();
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.ensureScreenSize();

    return ValueListenableBuilder<Set<String>>(
      valueListenable: widget.selectedDownloadDevices,
      builder: (context, selectedDevices, _) => Container(
        width: 2910.w,
        height: 1648.h,
        decoration: BoxDecoration(
          color: const Color(0xff414c67),
          borderRadius: BorderRadius.circular(5.r),
          border: Border.all(color: const Color(0xff414c67), width: 4.w),
        ),
        child: ScrollbarTheme(
          data: ScrollbarThemeData(
            thumbColor: MaterialStateProperty.all(const Color(0xff004aff)),
            trackColor: MaterialStateProperty.all(Colors.white),
            radius: Radius.circular(10.r),
            thickness: MaterialStateProperty.all(10.w),
          ),
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            trackVisibility: true,
            scrollbarOrientation: ScrollbarOrientation.right,
            interactive: true,
            radius: Radius.circular(5.r),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: groups
                    .map((group) =>
                        _buildChart(group, _isSelected(group.deviceId)))
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChart(CctvEventGroup group, bool isSelected) {
    final times = group.data.map((e) => e.time).toList();
    final now = DateTime.now();
    final xMin =
        times.isNotEmpty ? times.reduce((a, b) => a.isBefore(b) ? a : b) : now;

// ✅ xMax는 현재 시간과 비교하여 작은 쪽으로 자름
    final dataMax =
        times.isNotEmpty ? times.reduce((a, b) => a.isAfter(b) ? a : b) : now;
    final xMax = dataMax.isAfter(now) ? now : dataMax;

    _tooltipBehavior = TooltipBehavior(
      enable: true,
      shared: true,
      canShowMarker: true,
      tooltipPosition: TooltipPosition.pointer,
      format: 'point.x : point.y',
    );

    return Container(
      key: ValueKey('${group.deviceId}_${isSelected.toString()}'),
      // ✅ 장치 ID + 상태 조합 키
      height: 580.h,
      color: const Color(0xff0b1437),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              height: 73.51.h,
              padding: EdgeInsets.only(top: 6.h, left: 3.w),
              alignment: Alignment.bottomLeft,
              child: Row(
                children: [
                  InkWell(
                    onTap: () => widget.onDeviceTap(group.deviceId),
                    child: Container(
                      width: 432.w,
                      height: 80.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xff3182ce),
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: Text('[${group.deviceId}]',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'PretendardGOV',
                            fontWeight: FontWeight.w700,
                            fontSize: 40.sp,
                            color: Colors.white,
                          )),
                    ),
                  ),
                  Spacer(),
                  InkWell(
                    onTap: () {
                      final current = widget.selectedDownloadDevices.value;
                      if (current.contains('ALL')) current.remove('ALL');

                      if (current.contains(group.deviceId)) {
                        current.remove(group.deviceId);
                        debugPrint('🔻 ${group.deviceId} 해제 → $current');
                      } else {
                        current.add(group.deviceId);
                        debugPrint('✅ ${group.deviceId} 선택 → $current');
                      }

                      widget.selectedDownloadDevices.value = Set.from(current);
                    },
                    child: Container(
                      width: 45.w,
                      height: 45.h,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xff3182ce)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(5.r),
                        border: Border.all(color: Colors.white, width: 2.w),
                      ),
                      child: isSelected
                          ? Icon(Icons.check, color: Colors.white, size: 28.sp)
                          : null,
                    ),
                  ),
                  SizedBox(
                    width: 33.5.w,
                  )
                ],
              )),
          Container(
            height: 505.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xff0b1437),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: SfCartesianChart(
              tooltipBehavior: _tooltipBehavior,
              onTooltipRender: (TooltipArgs args) {
                final int? index = args.pointIndex?.toInt();
                if (index == null ||
                    args.dataPoints == null ||
                    index >= args.dataPoints!.length) return;

                final DateTime dt = args.dataPoints![index].x;
                final y = args.dataPoints![index].y;
                final formatted = DateFormat('yyyy-MM-dd HH:mm').format(dt);

                args.text = '$formatted\n값: $y';
              },
              margin: const EdgeInsets.all(20),
              legend: const Legend(isVisible: false),
              primaryXAxis: DateTimeAxis(
                intervalType: DateTimeIntervalType.minutes,
                interval: widget.intervalMinutes.toDouble(),
                // 기존 고정값 10 → 변경
                dateFormat: DateFormat('HH:mm'),
                labelRotation: 45,
                labelStyle: TextStyle(fontSize: 18.sp, color: Colors.white),
                majorGridLines: const MajorGridLines(width: 0),
                minimum: xMin.subtract(const Duration(minutes: 10)),
                maximum: xMax.add(const Duration(minutes: 10)),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                maximum: 2,
                interval: 1,
                majorGridLines: const MajorGridLines(width: 0),
                plotBands: [
                  PlotBand(
                      start: 0,
                      end: 0,
                      borderWidth: 2,
                      borderColor: Colors.white),
                  PlotBand(
                      start: 1,
                      end: 1,
                      borderWidth: 2,
                      borderColor: const Color(0xffffc300)),
                  PlotBand(
                      start: 2,
                      end: 2,
                      borderWidth: 2,
                      borderColor: const Color(0xffff0404)),
                ],
              ),
              series: [
                LineSeries<CctvEventData, DateTime>(
                  name: '10분 단위 경고',
                  dataSource: group.data,
                  xValueMapper: (d, _) => d.time,
                  yValueMapper: (d, _) => d.value,
                  emptyPointSettings: EmptyPointSettings(
                    mode: EmptyPointMode.zero,
                  ),
                  color: const Color(0xffff714d),
                  width: 2.w,
                  opacity: 0.9,
                  markerSettings: MarkerSettings(
                    isVisible: true,
                    shape: DataMarkerType.circle,
                    width: 15.w,
                    height: 15.h,
                  ),
                ),
                ScatterSeries<CctvEventData, DateTime>(
                  name: '실제 알람',
                  dataSource: group.rawAlarms,
                  xValueMapper: (d, _) => d.time,
                  yValueMapper: (d, _) => d.value,
                  color: Colors.amberAccent.withOpacity(0.95),
                  markerSettings: MarkerSettings(
                    isVisible: true,
                    shape: DataMarkerType.diamond,
                    width: 20.w,
                    height: 20.h,
                    borderColor: Colors.black,
                    borderWidth: 2,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class CctvEventData {
  final DateTime time;
  double value;

  CctvEventData(this.time, this.value);
}

class CctvEventGroup {
  final String deviceId;
  final List<CctvEventData> data;
  final List<CctvEventData> rawAlarms;

  CctvEventGroup({
    required this.deviceId,
    required this.data,
    required this.rawAlarms,
  });
}
