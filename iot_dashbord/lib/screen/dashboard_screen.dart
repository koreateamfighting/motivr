import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/component/dashboard/iot_control_status.dart';
import 'package:iot_dashboard/component/dashboard/work_process.dart';
import 'package:iot_dashboard/component/unity_webgl_frame.dart';
import 'package:iot_dashboard/component/base_layout.dart';
import 'package:iot_dashboard/component/hlsplayer_view.dart'; // ✅ 이름 통일
import 'package:iot_dashboard/theme/colors.dart';
import 'package:iot_dashboard/component/dashboard/iot_status.dart';
import 'package:iot_dashboard/component/dashboard/weather_info.dart';
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
                    color: Colors.white,
                  ),
                ],
              ),
              SizedBox(
                height: 10.h,
              ),

              // ),
              // ✅ 본문 내용
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xff1b254b),
                    border:
                        Border.all(color: Colors.transparent), // 또는 Border.none
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
                                          child:
                                          Image.asset('assets/icons/iot.png'),
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
                                    padding: EdgeInsets.only(top:14.h,left: 17.w,right: 19.w),

                                    color: Color(0xff1b254b),
                                    child: Container(
                                      width: 967.w,
                                      height: 725.h,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child:  UnityWebGLFrame(),
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
                                Container(width: 987.w,height: 602.h,color: Colors.red,),
                                SizedBox(width: 9.w,),
                                Container(width: 1168.w,height: 602.h,color: Colors.yellow,)
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
                            Container(
                              width: 881.w,
                              height: 1709.h,
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
                                children: [
                                  Container(

                                    height: 59.h,

                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 24.w,
                                        ),
                                        Container(
                                          width: 30.w,
                                          height: 30.h,
                                          child:
                                          Image.asset('assets/icons/cctv.png'),
                                        ),
                                        SizedBox(
                                          width: 12.w,
                                        ),
                                        Text(
                                          'CCTV 현황',
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

                                    height: 1.h,
                                    color: Colors.white,
                                  ),
                                
                                  Container(
                                    width: 859.w,
                                    height: 503.h,
                                    padding: EdgeInsets.fromLTRB(11.w, 10.h, 11.w, 10.h),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child:  const HlsPlayerIframe(cam: 'cam1'),
                                  ),
                                  Container(

                                    height: 1.h,
                                    color: Colors.white,
                                  ),
                                  Container(
                                    height: 320.h,
                                    color: Colors.yellow,
                                  ),
                                  Container(
                                    width: 859.w,
                                    height: 503.h,
                                    padding: EdgeInsets.fromLTRB(11.w, 10.h, 11.w, 10.h),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child:  const HlsPlayerIframe(cam: 'cam2'),
                                  ),
                                  Container(

                                    height: 1.h,
                                    color: Colors.white,
                                  ),
                                  Container(

                                    color: Colors.yellow,
                                  ),

                                ]

                              ),
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Container(
                              width: 881.w,
                              height: 181.h,
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
  final String cam;
  const HlsPlayerIframe({super.key, this.cam = 'cam1'});

  @override
  Widget build(BuildContext context) {
    final String viewId = 'hls-player-iframe-$cam';

    final iframe = html.IFrameElement()
      ..src = 'https://hanlimtwin.kr:3030/hls_player.html?cam=$cam'
      ..style.border = 'none'
      ..allowFullscreen = true  // ✅ 핵심
      ..setAttribute('allowfullscreen', ''); // ✅ 일부 브라우저 대응

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewId, (int viewId) => iframe);

    return HtmlElementView(viewType: viewId);
  }
}

