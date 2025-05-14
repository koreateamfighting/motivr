import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashbord/component/dashboard/iot_control_status.dart';
import 'package:iot_dashbord/component/unity_webgl_frame.dart';
import 'package:iot_dashbord/component/base_layout.dart';
import 'package:iot_dashbord/component/hlsplayer_view.dart'; // ✅ 이름 통일
import 'package:iot_dashbord/services/cctv_service.dart';
import 'package:iot_dashbord/theme/colors.dart';
import 'package:iot_dashbord/component/dashboard/iot_status.dart';


class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key);

  static const designWidth = 3812;
  static const designHeight = 2144;

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  late Future<List<CctvInfo>> _cctvs;

  @override
  void initState() {
    super.initState();
    _cctvs = CctvService.fetchCctvList(); // ✅ CCTV 리스트 가져오기
  }

  @override
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 50.w),
                width: 3712.w,
                height: 2.h,

                color:  Color(0xff3CBFAD),
              ),


              Container(
                height: 10.h,
                color: AppColors.main2,

              ),
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
                            Container(
                              width: 1102.w,
                              height: 1924.h,
                              color: AppColors.main1,
                            ),

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

//  return BaseLayout(
//           child: FutureBuilder<List<CctvInfo>>(
//             future: _cctvs,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
//                 return const Center(child: Text('CCTV 불러오기 실패'));
//               }
//
//               final cctv = snapshot.data!.first;
//
//               return Column(
//                 children: [
//                   Expanded(
//                     child: Row(
//                       children: [
//
//                         Expanded(child: UnityWebGLFrame()),
//                         Expanded(
//                           child: Column(
//                             children: [
//                               Container(
//                                 color: Colors.black,
//                                 padding: EdgeInsets.all(16.w),
//                                 alignment: Alignment.centerLeft,
//                                 child: Text(
//                                   cctv.name,
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 28.sp,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                               // Expanded(
//                               //   child: HlsPlayerView(
//                               //     videoUrl: cctv.url,
//                               //   ),
//                               // ),
//                               Expanded(child: Container(color: Colors.yellow)),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     child: Row(
//                       children: [
//                         Expanded(child: Container(color: Colors.blue)),
//                         Expanded(child: Container(color: Colors.orange)),
//                       ],
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         );
