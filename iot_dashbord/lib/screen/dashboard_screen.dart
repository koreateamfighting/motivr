import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashbord/component/dashboard/iot_control_status.dart';
import 'package:iot_dashbord/component/unity_webgl_frame.dart';
import 'package:iot_dashbord/component/base_layout.dart';
import 'package:iot_dashbord/component/hlsplayer_view.dart'; // ✅ 이름 통일
import 'package:iot_dashbord/theme/colors.dart';
import 'package:iot_dashbord/component/dashboard/iot_status.dart';
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
                height: 98.h,
                color: AppColors.main2,
                padding: EdgeInsets.symmetric(horizontal: 275.w),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/icons/color_dashboard.png',
                      width: 80.w,
                      height: 80.h,
                    ),
                    SizedBox(width: 20.w),
                    Text(
                      '대시보드',
                      style: TextStyle(
                        fontFamily: 'PretendardGOV',
                        fontWeight: FontWeight.w800,
                        fontSize: 48.sp,
                        color: Color(0xff3CBFAD),
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
                    height: 2.h,

                    color:  Color(0xff3CBFAD),
                  ),
                ],
              ),



              // ),
              // ✅ 본문 내용
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.main2,
                    border: Border.all(color: Colors.transparent), // 또는 Border.none
                  ),

                  child: Center(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 53.w,
                        ),
                        Column(
                          children: [
                            IotStatus(),
                            SizedBox(height: 9.h,),
                            IotControlStatus(),
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
      ..width = '100%'
      ..height = '100%'
      ..src = 'https://hanlimtwin.kr:3030/hls_player.html'
      ..style.border = 'none';

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewId, (int viewId) => _iframe);

    return const HtmlElementView(viewType: viewId);
  }
}

