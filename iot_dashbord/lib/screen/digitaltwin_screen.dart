import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/component/base_layout.dart';
import 'package:iot_dashboard/theme/colors.dart';
import 'package:iot_dashboard/component/unity_webgl_frame.dart';


class DigitalTwinScreen extends StatefulWidget {
  const DigitalTwinScreen({super.key});

  @override
  State<DigitalTwinScreen> createState() => _DigitalTwinScreenState();
}
class _DigitalTwinScreenState extends State<DigitalTwinScreen> {


  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(3812, 2144),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return BaseLayout(
            child: Container(
              padding: EdgeInsets.only(left: 64.w, right: 68.w),
              color: Color(0xff1b254b),
              child:   Column(

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
                          'assets/icons/uncolor_cube.png',
                          width: 40.w,
                          height: 40.h,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '디지털트윈',
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
                    width: double.infinity,
                    height: 4.h,
                    color: Colors.white,
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
              ),
            )
        );
      },
    );
  }
}
