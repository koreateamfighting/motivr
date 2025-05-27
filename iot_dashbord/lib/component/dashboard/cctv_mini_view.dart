import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/theme/colors.dart';
import 'package:iot_dashboard/services/hls_player_iframe.dart';

class CctvMiniView extends StatefulWidget {
  const CctvMiniView({super.key});
  @override
  State<CctvMiniView> createState() => _CctvMiniViewState();
}

class _CctvMiniViewState extends State<CctvMiniView> {
  @override
  Widget build(BuildContext context) {
    return                            Container(
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
      child: Column(children: [
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
                child: Image.asset(
                    'assets/icons/cctv.png'),
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
          padding: EdgeInsets.fromLTRB(
              11.w, 10.h, 11.w, 10.h),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.grey),
          ),
          child: const HlsPlayerIframe(cam: 'cam1'),
        ),
        Container(
          height: 1.h,
          color: Colors.white,
        ),
        Container(
          height: 320.h,
          padding:
          EdgeInsets.only(left: 11.w, right: 11.w),
          child: Column(
            children: [
              Container(
                height: 80.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('●',style: TextStyle(fontSize: 32.sp,color: Color(0xff258420)),),
                    SizedBox(width: 25.w,),
                    Text(
                      '추진구',
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
              Container(
                height: 240.h,
                color: Colors.blueAccent,
              ),
            ],
          ),
        ),
        Container(
          width: 859.w,
          height: 503.h,
          padding: EdgeInsets.fromLTRB(
              11.w, 10.h, 11.w, 10.h),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.grey),
          ),
          child: const HlsPlayerIframe(cam: 'cam2'),
        ),
        Container(
          height: 1.h,
          color: Colors.white,
        ),
        Container(
          height: 320.h,
          padding:
          EdgeInsets.only(left: 11.w, right: 11.w),
          child: Column(
            children: [
              Container(
                height: 61.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('●',style: TextStyle(fontSize: 32.sp,color: Color(0xff258420)),),
                    SizedBox(width: 25.w,),
                    Text(
                      '도달구',
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
              Container(
                height: 265.h,
                color: Colors.pinkAccent,
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
