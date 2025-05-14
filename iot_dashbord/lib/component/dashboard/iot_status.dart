import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashbord/theme/colors.dart';
import 'package:iot_dashbord/component/unity_webgl_frame.dart'; // ✅ WebGL 연동

class IotStatus extends StatelessWidget {
  const IotStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1542.w,
      height: 1360.h,
      decoration: BoxDecoration(
        color: AppColors.main1,
        borderRadius: BorderRadius.circular(12.r),
        // child: 이후 실제 위젯 들어갈 수 있도록 구성해둠
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              height: 100.h,
              child: Row(
                children: [
                  SizedBox(
                    width: 17.w,
                  ),
                  Container(
                    width: 40.w,
                    height: 40.h,
                    child: Image.asset('assets/icons/iot.png'),
                  ),
                  SizedBox(
                    width: 12.w,
                  ),
                  Text(
                    'IoT 현황',
                    style: TextStyle(
                        fontFamily: 'PretendardGOV',
                        fontWeight: FontWeight.w400,
                        fontSize: 40.sp,
                        color: Colors.white),
                  )
                ],
              ),
            ),

            Container(
              width: 1542.w,
              height: 1.h,
              color: Colors.white,
            ),
            // ✅ 콘텐츠 (Unity WebGL 영역)
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(36.w, 75.h, 37.w, 92.h),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: UnityWebGLFrame(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
