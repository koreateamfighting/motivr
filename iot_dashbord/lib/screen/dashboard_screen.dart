import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashbord/component/unity_webgl_frame.dart';
import 'package:iot_dashbord/component/base_layout.dart';
import 'package:iot_dashbord/component/hlsplayer_view.dart';     // ✅ 이름 통일
import 'package:iot_dashbord/services/cctv_service.dart';

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
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(3812, 2144),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return BaseLayout(
          child: FutureBuilder<List<CctvInfo>>(
            future: _cctvs,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('CCTV 불러오기 실패'));
              }

              final cctv = snapshot.data!.first;

              return Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: UnityWebGLFrame()),
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                color: Colors.black,
                                padding: EdgeInsets.all(16.w),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  cctv.name,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: HlsPlayerView(
                                  videoUrl: cctv.url,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: Container(color: Colors.blue)),
                        Expanded(child: Container(color: Colors.orange)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
