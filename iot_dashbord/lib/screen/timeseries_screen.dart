import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/component/common/base_layout.dart';
import 'package:iot_dashboard/component/common/dialog_form.dart';
import 'package:iot_dashboard/component/timeseries/iot_time_period_select.dart';
import 'package:iot_dashboard/component/timeseries/cctv_time_period_select.dart';
import 'package:iot_dashboard/controller/iot_controller.dart';
import 'package:iot_dashboard/controller/cctv_controller.dart';
import 'package:iot_dashboard/theme/colors.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:iot_dashboard/component/common/build_tab.dart';
import 'package:iot_dashboard/component/timeseries/iot_alarm_history.dart';
import 'package:iot_dashboard/component/timeseries/iot_graph_view.dart';
import 'package:iot_dashboard/component/timeseries/cctv_alarm_histroy.dart';
import 'package:iot_dashboard/component/timeseries/cctv_graph_view.dart';
import 'package:provider/provider.dart';

class TimeRange {
  final DateTime start;
  final DateTime end;

  TimeRange({required this.start, required this.end});
}

// ✅ interval 계산 함수 추가 (cctv 파트임)
int calculateIntervalInMinutes(DateTime start, DateTime end) {
  final diffMinutes = end.difference(start).inMinutes;
  if (diffMinutes <= 24 * 60) return 10; // 하루 이하
  if (diffMinutes <= 3 * 24 * 60) return 30; // 3일 이하
  if (diffMinutes <= 7 * 24 * 60) return 60; // 7일 이하
  if (diffMinutes <= 14 * 24 * 60) return 120; // 2주 이하
  if (diffMinutes <= 31 * 24 * 60) return 180; // 1달 이하
  return 360; // 그 외 (6시간)
}



class TimeSeriesScreen extends StatefulWidget {
  const TimeSeriesScreen({super.key});

  @override
  State<TimeSeriesScreen> createState() => _TimeSeriesScreenState();
}

class _TimeSeriesScreenState extends State<TimeSeriesScreen> {
  final ValueNotifier<Set<String>> selectedDownloadRids = ValueNotifier({});
  final ValueNotifier<Set<String>> selectedDownloadDevices = ValueNotifier({});

  String selectedRid = '';
  String selectedCCTV = '';
  String selectedInterval = '30분';
  int selectedTab = 1; // 0 = IoT, 1 = CCTV
  TimeRange _currentRange = TimeRange(
    start: DateTime.now().copyWith(hour: 0, minute: 0, second: 0),
    end: DateTime.now().copyWith(hour: 23, minute: 59, second: 59),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CctvController>().fetchCctvs();
    });

  }


  void _onQuery(DateTime from, DateTime to) {
    // 항상 새로운 인스턴스를 생성해 강제 업데이트 유도
    final newRange = TimeRange(start: from, end: to);

    // 이전 range와 다르지 않더라도 새로 갱신되도록 setState
    setState(() {
      _currentRange = TimeRange(start: newRange.start, end: newRange.end);
    });
  }



  @override
  Widget build(BuildContext context) {
    final allRids = context.watch<IotController>()
        .getFilteredDisplacementGroups()
        .map((g) => g.rid)
        .toList();
    final cctvAllDevices = context.watch<CctvController>().getAllDeviceIds().toList();

    final cctvInterval = calculateIntervalInMinutes(_currentRange.start, _currentRange.end);

    return ScreenUtilInit(
      designSize: const Size(3812, 2144),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return BaseLayout(
            child: Container(
              padding: EdgeInsets.only(
                left: 70.w,
                right: 72.w,
              ),
              color: Color(0xff1b254b),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 80.h,
                    color: Color(0xff1b254b),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/icons/uncolor_vector.png',
                          width: 60.w,
                          height: 60.h,
                        ),
                        SizedBox(width: 16.w),
                        Text(
                          '시계열데이터',
                          style: TextStyle(
                            fontFamily: 'PretendardGOV',
                            fontWeight: FontWeight.w700,
                            fontSize: 48.sp,
                            color: Colors.white,
                          ),
                        ),
                        Spacer(),
                        Text(
                          '시계열 데이터를 확인하실 수 있습니다.',
                          style: TextStyle(
                            fontFamily: 'PretendardGOV',
                            fontWeight: FontWeight.w400,
                            fontSize: 32.sp,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                  // ✅ 하단 선
                  Container(
                    width: double.infinity,
                    height: 4.h,
                    color: Colors.white,
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => selectedTab = 0);
                          },
                          child: buildTab(
                              label: 'IoT',
                              imageName: 'iot',
                              isSelected: selectedTab == 0),
                        ),
                      ),
                      SizedBox(
                        width: 20.w,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => selectedTab = 1); // CCTV 준비중
                            /*         showDialog(
                              context: context,
                              builder: (_) => const DialogForm(
                                mainText: 'CCTV 시계열 데이터 부분은 점검중입니다.',
                                btnText: '확인',
                              ),
                            );*/
                          },
                          child: buildTab(
                              label: 'CCTV',
                              imageName: 'cctv',
                              isSelected: selectedTab == 1),
                        ),
                      ),
                    ],
                  ),
                  Transform.translate(offset: Offset(0, -1),
                      child:
                      Container(
                        width: double.infinity,
                        height: 37.h,
                        color: Color(0xff3182ce),
                      ))
                  ,
                  SizedBox(
                    height: 4.h,
                  ),
                  Container(
                    width: 3680.w,
                    height: 1770.h,
                    padding: EdgeInsets.only(left: 6.w, right: 6.w),
                    decoration: BoxDecoration(
                      color: Color(0xff1b254b),
                      border: Border(
                        left: BorderSide(color: Color(0xff3182ce), width: 4.w),
                        right: BorderSide(color: Color(0xff3182ce), width: 4.w),
                        bottom:
                        BorderSide(color: Color(0xff3182ce), width: 4.w),
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10.r),
                        bottomRight: Radius.circular(10.r),
                      ),
                    ),
                    child: Column(
                      children: [
                        selectedTab == 0
                            ? IotTimePeriodSelect(
                          onQuery: _onQuery,
                          selectedDownloadRids: selectedDownloadRids,
                          allRids: allRids,
                        )
                            : CCTVTimePeriodSelect(
                          onQuery: _onQuery,
                          selectedDownloadDevices: selectedDownloadDevices,
                          allDevices: cctvAllDevices,
                        ),
                        SizedBox(
                          height: 16.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            selectedTab == 0?
                            IotAlarmHistory(
                              selectedRid: selectedRid,
                              allItems: context.watch<IotController>().items,
                              startDate: _currentRange.start,
                              endDate: _currentRange.end,
                            ):
                            CCTVAlarmHistory(
                              onDeviceSelected: (deviceId) {
                                setState(() {
                                  selectedRid = deviceId;
                                });
                              },
                            ),


                            SizedBox(
                              width: 4.w,
                            ),
                            selectedTab == 0?
                            IotGraphView(
                              timeRange: _currentRange,
                              onRidTap: (rid) {
                                setState(() {
                                  selectedRid = rid;
                                });
                              },
                              selectedDownloadRids: selectedDownloadRids, // ✅ 추가
                            ):
                            CCTVGraphView(
                              timeRange: _currentRange,
                              intervalMinutes: cctvInterval,
                              onDeviceTap: (cctv) {
                                setState(() {
                                  selectedCCTV = cctv;
                                });
                              },
                              selectedDownloadDevices: selectedDownloadDevices, // ✅ 추가
                            )
                          ],


                        )
                      ],
                    ),
//                child: selectedTab == 0 ? DetailIotView() : DetailCctvView(),
                  ),
                ],
              ),
            ));
      },
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
