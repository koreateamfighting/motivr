import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/component/dashboard/iot_control_status.dart';
import 'package:iot_dashboard/component/dashboard/work_process.dart';
import 'package:iot_dashboard/component/unity_webgl_frame.dart';
import 'package:iot_dashboard/component/base_layout.dart';
import 'package:iot_dashboard/component/hlsplayer_view.dart'; // ✅ 이름 통일
import 'package:iot_dashboard/theme/colors.dart';
import 'package:iot_dashboard/component/dashboard/iot_status.dart';
import 'package:iot_dashboard/component/dashboard/weather_info2.dart';
import 'dart:ui' as ui;
import 'dart:html' as html;


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

  }

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

                    color:  Colors.white,
                  ),
                ],
              ),
              SizedBox(height: 10.h,),


              // ),
              // ✅ 본문 내용
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color:  Color(0xff1b254b),
                    border: Border.all(color: Colors.transparent), // 또는 Border.none
                  ),

                  child: Center(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 53.w,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IotControlStatus(),

                            SizedBox(height: 46.h,),
                            WorkProcessStatus(),
                            SizedBox(height: 6.h,),
                            WeatherInfo(),

                            // IotStatus(),
                          ],
                        ),
                        SizedBox(
                          width: 29.w,
                        ),
                        Column(
                          children: [
                            // Container(
                            //   width: 1102.w,
                            //   height: 1924.h,
                            //   color: Colors.white,
                            //
                            // ),
                            Container(
                              width: 1102.w,
                              height: 1924.h,
                              color: Colors.white,
                              child:  Container(
                                  width: 967.w,
                                  height: 725.h,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child:  HlsPlayerIframe (), // ✅ iframe 기반 영상 삽입
                                ),

                            )



                          ],
                        ),
                        SizedBox(
                          width: 36.w,
                        ),
                        Column(
                          children: [
                            Container(
                              width: 1000.w,
                              height: 814.h,
                              color: AppColors.main1,
                            ),
                            SizedBox(height: 10.h,),
                            Container(
                              width: 1000.w,
                              height: 360.h,
                              color: AppColors.main1,
                            ),
                            SizedBox(height: 13.h,),
                            Container(
                              width: 1000.w,
                              height: 360.h,
                              color: AppColors.main1,
                            ),
                            SizedBox(height: 7.h,),
                            Container(
                              width: 1000.w,
                              height: 360.h,
                              color: AppColors.main1,
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
    );
  }
}


class HlsPlayerIframe extends StatelessWidget {
  const HlsPlayerIframe({super.key});

  @override
  Widget build(BuildContext context) {
    const viewId = 'hls-player-iframe';

    html.IFrameElement _iframe = html.IFrameElement()
      ..id = 'hls-player-iframe'
      ..width = '100%'
      ..height = '100%'
      ..src = 'https://hanlimtwin.kr:3030/hls_player.html'
      ..style.border = 'none';

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewId, (int viewId) => _iframe);

    return const HtmlElementView(viewType: viewId);
  }
}

