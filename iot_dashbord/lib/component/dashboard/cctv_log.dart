import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/theme/colors.dart';
import 'package:iot_dashboard/services/hls_player_iframe.dart';

class CctvLog extends StatefulWidget {
  const CctvLog({super.key});
  @override
  State<CctvLog> createState() => _CctvLogState();
}

class _CctvLogState extends State<CctvLog> {
  @override
  Widget build(BuildContext context) {
    return
      Container(
        width: 881.w,
        height: 181.h,
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
            Row(
              children: [
                SizedBox(
                  width: 24.w,
                ),
                Container(
                  width: 30.w,
                  height: 30.h,
                  child: Image.asset(
                      'assets/icons/cctv_log.png'),
                ),
                SizedBox(
                  width: 12.w,
                ),
                Text(
                  'CCTV 로그 내역',
                  style: TextStyle(
                      fontFamily: 'PretendardGOV',
                      fontWeight: FontWeight.w500,
                      fontSize: 36.sp,
                      color: Colors.white),
                ),

              ],
            ),
            Container(
              width: 881.w,
              height: 1.h,
              color: Colors.white,
            ),
            Container(
              width: 881.w,
              height: 60.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 28.w,),
                  Container(width: 333.w,height: 30.h,child: Text('2025-04-22 10:40',style: TextStyle(
                      fontFamily: 'PretendardGOV',
                      fontWeight: FontWeight.w500,
                      fontSize: 24.sp,
                      color: Colors.white),),),
                  SizedBox(width: 51.w,),
                  Container(height: 30.w,child: Text('[추진구 1번]영상 이미지 수집 성공',style: TextStyle(
                      fontFamily: 'PretendardGOV',
                      fontWeight: FontWeight.w500,
                      fontSize: 24.sp,
                      color: Colors.white),),),
                ],
              ),
            ),
            Container(
              width: 881.w,
              height: 1.h,
              color: Colors.white,
            ),
            Container(
              width: 881.w,
              height: 60.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 28.w,),
                  Container(width: 333.w,height: 30.h,child: Text('2025-04-22 10:43',style: TextStyle(
                      fontFamily: 'PretendardGOV',
                      fontWeight: FontWeight.w500,
                      fontSize: 24.sp,
                      color: Colors.white),),),
                  SizedBox(width: 51.w,),
                  Container(height: 30.w,child: Text('[추진구 2번]영상 이미지 수집 성공',style: TextStyle(
                      fontFamily: 'PretendardGOV',
                      fontWeight: FontWeight.w500,
                      fontSize: 24.sp,
                      color: Colors.white),),),
                ],
              ),
            ),
          ],
        ),
      );
  }
}
