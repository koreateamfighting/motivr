import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashbord/component/base_layout.dart';
import 'package:iot_dashbord/theme/colors.dart';
import 'package:iot_dashbord/component/unity_webgl_frame.dart';

class DigitalTwinScreen extends StatelessWidget {
  const DigitalTwinScreen({super.key});

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
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 275.w),
              child: Row(
                children: [
                  Image.asset(
                    'assets/icons/color_cube.png',
                    width: 80.w,
                    height: 80.h,
                  ),
                  SizedBox(width: 20.w),
                  Text(
                    '디지털트윈',
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

                  color:  Color(0xffd9d9d9),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0,0,0, 109.h),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: UnityWebGLFrame(),
                ),
              ),
            ),


          ],
        ));
      },
    );
  }
}
