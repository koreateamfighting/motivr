import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/component/dashboard/cctv_log.dart';
import 'package:iot_dashboard/component/dashboard/cctv_mini_view.dart';
import 'package:iot_dashboard/component/dashboard/iot_control_status.dart';
import 'package:iot_dashboard/component/dashboard/work_process.dart';
import 'package:iot_dashboard/component/common/unity_webgl_frame.dart';
import 'package:iot_dashboard/component/common/base_layout.dart';
import 'package:iot_dashboard/component/dashboard/weather_info.dart';
import 'package:iot_dashboard/component/dashboard/recent_alarm_section.dart';
import 'package:iot_dashboard/component/dashboard/work_task_and_notice.dart';
import 'package:iot_dashboard/component/common/iot_alarm_dialog.dart';
import 'package:iot_dashboard/controller/iot_controller.dart';
import 'package:iot_dashboard/constants/global_constants.dart'; // baseUrl3030 사용
import 'dart:async';
import 'dart:html' as html;
import 'package:provider/provider.dart';
import 'package:iot_dashboard/component/common/realtime_iot_alert.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key);

  static const designWidth = 3812;
  static const designHeight = 2144;

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  bool _fetchTriggered = false;
  Timer? _timer;
  Timer? _retryTimer;
  bool _retryScheduled = false;
  String get kWsUrl3030 {
    final u = Uri.parse(baseUrl3030);
    final scheme = u.scheme == 'https' ? 'wss' : 'ws';
    final hostPort = u.hasPort ? '${u.host}:${u.port}' : u.host;
    return '$scheme://$hostPort';
  }


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IotController>().fetchSensorStatusSummary();
    });


  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _retryTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(3812, 2144),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return BaseLayout(
          child: Stack(
            children: [
              RealtimeIotAlert(
                wsUrl: kWsUrl3030,          // ❗ 3030으로 확실히 붙이기
                ignorePastOnStartup: false, // ❗ 테스트 동안 과거 필터 끄기
                allowedSkewMs: 60000,       // (옵션) 여유 60초
              ),
              Consumer<IotController>(
                builder: (context, controller, _) {
                  final isLoading = controller.isLoading;
                  final hasError = controller.hasError;
                  final total = controller.getTotal;

                  if (hasError && !_retryScheduled) {
                    _retryScheduled = true;
                    _retryTimer?.cancel(); // 혹시 몰라 초기화
                    _retryTimer = Timer(Duration(seconds: 5), () {
                      _retryScheduled = false; // 다음 재시도를 위해 초기화
                      context.read<IotController>().fetchSensorStatusSummary();
                    });
                  }
                  Widget statusWidget;

                  if (isLoading) {
                    statusWidget = Container(
                      width: 613.w,
                      height: 641.h,
                      alignment: Alignment.center,
                      decoration: _statusBoxDecoration(),
                      child: CircularProgressIndicator(
                        color: Color(0xff3182ce),
                      ),
                    );
                  } else if (hasError) {
                    statusWidget = Container(
                      width: 613.w,
                      height: 641.h,
                      alignment: Alignment.center,
                      decoration: _statusBoxDecoration(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Color(0xff3182ce),
                          )
                        ],
                      ),
                    );
                  } else if (total == 0) {
                    statusWidget = Container(
                      width: 613.w,
                      height: 641.h,
                      alignment: Alignment.center,
                      decoration: _statusBoxDecoration(),
                      child: Text(
                        '표시할 데이터가 없습니다.',
                        style: TextStyle(color: Colors.white, fontSize: 28.sp),
                      ),
                    );
                  } else {
                    statusWidget = IotControlStatus();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ 대시보드 헤더
                      Container(
                        height: 69.h,
                        color: Color(0xff1b254b),
                        padding: EdgeInsets.symmetric(horizontal: 66.w),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/icons/uncolor_dashboard.png',
                              width: 40.w,
                              height: 40.h,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '대시보드',
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
                      // ✅ 헤더 하단 선
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 50.w),
                              width: 3712.w,
                              height: 4.h,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),

                      Container(
                        height: 10.h,
                        color: Color(0xff1b254b),
                      ),

                      // ✅ 본문 내용
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xff1b254b),
                            border: Border.all(
                                color: Colors.transparent), // 또는 Border.none
                          ),
                          child: Center(
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 53.w,
                                ),
                                //첫번째 콘텐츠
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    statusWidget,
                                    SizedBox(height: 26.h),
                                    WorkProcessStatus(),
                                    SizedBox(height: 26.h),
                                    WeatherInfo(),
                                  ],
                                ),
                                SizedBox(
                                  width: 20.w,
                                ),
                                //두번째 콘텐츠
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 2170.w,
                                      height: 1288.h,
                                      decoration: BoxDecoration(
                                        //color: Color(0xff111c44),
                                        color: Color(0xff1b254b),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1.w,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(5.r),
                                        // child: 이후 실제 위젯 들어갈 수 있도록 구성해둠
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 2163.w,
                                            height: 59.h,
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 24.w,
                                                ),
                                                Container(
                                                  width: 30.w,
                                                  height: 30.h,
                                                  child: Image.asset(
                                                      'assets/icons/iot.png'),
                                                ),
                                                SizedBox(
                                                  width: 12.w,
                                                ),
                                                Text(
                                                  'IoT 현황',
                                                  style: TextStyle(
                                                      fontFamily:
                                                          'PretendardGOV',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 36.sp,
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: 2165.w,
                                            height: 1.h,
                                            color: Colors.white,
                                          ),
                                          Container(
                                            width: 2165.w,
                                            height: 1197.h,
                                            padding: EdgeInsets.only(
                                                top: 14.h,
                                                left: 16.w,
                                                right: 16.w),
                                            color: Color(0xff1b254b),
                                            child: Container(
                                              width: 967.w,
                                              height: 725.h,
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                border: Border.all(
                                                    color: Colors.grey),
                                              ),
                                              child: UnityWebGLFrame(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 8.h,
                                      color: Colors.red,
                                    ),
                                    Row(
                                      children: [
                                        WorkTaskAndNotice(),
                                        SizedBox(
                                          width: 16.w,
                                        ),
                                        AlarmListView(),
                                      ],
                                    )
                                  ],
                                ),
                                SizedBox(
                                  width: 20.w,
                                ),
                                //세번째 콘텐츠
                                Column(
                                  children: [
                                    CctvMiniView(),
                                    SizedBox(
                                      height: 8.h,
                                    ),
                                    CctvLog(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              )
            ],
          ),
        );
      },
    );
  }

  BoxDecoration _statusBoxDecoration() {
    return BoxDecoration(
      color: Color(0xff111c44),
      border: Border.all(color: Colors.white, width: 1.w),
      borderRadius: BorderRadius.circular(5.r),
    );
  }
}
