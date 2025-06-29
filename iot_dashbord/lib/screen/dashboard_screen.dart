import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/component/dashboard/cctv_log.dart';
import 'package:iot_dashboard/component/dashboard/cctv_mini_view.dart';
import 'package:iot_dashboard/component/dashboard/iot_control_status.dart';
import 'package:iot_dashboard/component/dashboard/work_process.dart';
import 'package:iot_dashboard/component/common/unity_webgl_frame.dart';
import 'package:iot_dashboard/component/common/base_layout.dart';
import 'package:iot_dashboard/component/common/hlsplayer_view.dart'; // ✅ 이름 통일
import 'package:iot_dashboard/theme/colors.dart';
import 'package:iot_dashboard/component/dashboard/iot_status.dart';
import 'package:iot_dashboard/component/dashboard/weather_info.dart';
import 'package:iot_dashboard/component/dashboard/recent_alarm_section.dart';
import 'package:iot_dashboard/component/dashboard/work_task_and_notice.dart';
import 'package:iot_dashboard/controller/cctv_controller.dart';
import 'dart:async';
import 'dart:html' as html;
import 'package:provider/provider.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key);

  static const designWidth = 3812;
  static const designHeight = 2144;

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  @override
  void initState() {
    super.initState();

    // 1분마다 현재 시간을 체크
    Timer.periodic(Duration(minutes: 1), (timer) {
      final now = DateTime.now();

      // 원하는 시간: 오전 6시 56분
      if (now.hour == 6 && now.minute == 56) {
        print("웹 페이지 새로고침");
        html.window.location.reload(); // 웹페이지 새로고침
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CctvController())],
      child: ScreenUtilInit(
        designSize: const Size(3812, 2144),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return BaseLayout(
            child: Column(
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
                Row(
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
                SizedBox(
                  height: 10.h,
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
                              IotControlStatus(),

                              SizedBox(
                                height: 46.h,
                              ),
                              WorkProcessStatus(),
                              SizedBox(
                                height: 6.h,
                              ),
                              WeatherInfo(),

                              // IotStatus(),
                            ],
                          ),
                          SizedBox(
                            width: 9.w,
                          ),
                          //두번째 콘텐츠
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 2165.w,
                                height: 1288.h,
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                                                fontFamily: 'PretendardGOV',
                                                fontWeight: FontWeight.w500,
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
                                      width: 2129.w,
                                      height: 1197.h,
                                      padding: EdgeInsets.only(
                                          top: 14.h, left: 17.w, right: 19.w),
                                      color: Color(0xff1b254b),
                                      child: Container(
                                        width: 967.w,
                                        height: 725.h,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          border:
                                              Border.all(color: Colors.grey),
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
                            width: 8.w,
                          ),
                          //세번째 콘텐츠
                          Column(
                            children: [
                              CctvMiniView(),
                              SizedBox(
                                height: 10.h,
                              ),
                              Expanded(

                                child: CctvLog(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
