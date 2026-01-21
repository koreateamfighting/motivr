import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/component/common/unity_webgl_frame.dart';

class ReachPortView extends StatelessWidget {
  const ReachPortView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1273.w,
      height: 1566.h,
      padding: EdgeInsets.only(left: 14.w, right: 16.w),
      color: Color(0xff3182ce),
      child: Column(
        children: [
          SizedBox(height: 30.h),
          Container(
              width: 1243.w,
              height: 718.h,
              alignment: Alignment.center,
              child: UnityWebGLFrame()), // 위쪽 영역
          SizedBox(height: 53.h),
          Container(
              width: 1251.w,
              height: 757.h,
              color: Colors.grey,

              child: Image.asset('assets/images/reachport.png',fit: BoxFit.fill,)),
        ],
      ),
    );
  }
}
