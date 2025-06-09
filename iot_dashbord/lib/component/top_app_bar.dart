import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/services/live_clock.dart';
import 'package:iot_dashboard/utils/auth_service.dart';
import 'package:iot_dashboard/component/dialog_form2.dart';
import 'package:go_router/go_router.dart';
import 'package:iot_dashboard/controller/user_controller.dart';
import 'dart:html' as html;
import 'package:iot_dashboard/utils/iframe_visibility.dart';

class TopAppBar extends StatelessWidget {
  final VoidCallback? onMenuPressed;
  final bool isMenuVisible; // ✅ 추가

  const TopAppBar({
    Key? key,
    this.onMenuPressed,
    required this.isMenuVisible, // ✅ 필수값으로 지정
  }) : super(key: key);




  void toggleFullScreen() {
    final doc = html.document;

    if (doc.fullscreenElement != null) {
      doc.exitFullscreen(); // 전체화면 종료
    } else {
      doc.documentElement?.requestFullscreen(); // 전체화면 요청
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3812.w,
      height: 140.h,
      color: Colors.white,
      child: Row(
        children: [
          SizedBox(width: 50.w),
          // Container(
          //   alignment: Alignment.center,
          //
          //   width: 60.w,
          //         height: 80.h,
          //         child: IconButton(
          //           onPressed: onMenuPressed,
          //           icon:  Icon(Icons.menu_rounded,size: 70.sp,),
          //           color: isMenuVisible
          //               ? const Color(0xFF3182ce) // 열렸을 때
          //               :  Color(0xFF3182ce)         // 닫혔을 때
          //         ),
          // ),
          Container(
            alignment: Alignment.center,

            width: 60.w,
            height: 60.h,
            child: InkWell(
              onTap: onMenuPressed,
              child: Image.asset(
                'assets/icons/menu2.png'
              ),
            ),
          ),
          SizedBox(width: 140.w),
          Container(
            alignment: Alignment.center, // 내부에서 우측 정렬
            child: Container(
              width: 288.w,
              height: 100.h,
              color: Colors.white,
              // padding: EdgeInsets.symmetric(vertical: 8.h), // ✅ 내부 여백 추가
              child: Image.asset(
                'assets/images/company_logo_small.png',
                fit: BoxFit.fill, // ✅ 비율 유지하면서 컨테이너 안에 맞춤
              ),
            ),
          ),
          SizedBox(width: 169.w,),
          LiveClock(),
          SizedBox(width: 264.w,),
          Container(
            width: 1500.w ,
            child: Text(
              'Digital Twin CMS',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PretendardGOV',
                fontWeight: FontWeight.w700,
                fontSize: 70.sp,
                color: Color(0xff0b1437)
              ),
            ),
          ),
          SizedBox(width: 840.w),

          // WeatherInfoBar(),

          InkWell(
              onTap: ()  {
                toggleFullScreen();
              },
              child: Container(
                width: 60.w,
                height: 60.h,
                padding: EdgeInsets.fromLTRB(4.0.w,4.0.h,4.0.w,4.0.h),
                decoration: BoxDecoration(
                   color:  Color(0xFF3182ce),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Image.asset('assets/icons/max.png',),
              )),
          SizedBox(width: 63.w),
          InkWell(
            onTap: () async {
              hideIframes();

              await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => DialogForm2(
                  mainText: "로그아웃 하시겠습니까?",
                  btnText1: "아니오",
                  btnText2: "네",
                  onConfirm: () async {
                    final userID = await AuthService.getUserID();
                    if (userID != null) {
                      await UserController.logout(userID);
                    }
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                ),
              );

              showIframes(); // ✅ 다이얼로그 닫히고 나서 실행됨
            },

            child: Container(
                width: 60.w,
                height: 60.h,
                padding: EdgeInsets.fromLTRB(4.0.w,4.0.h,4.0.w,4.0.h),
                decoration: BoxDecoration(
                  color:  Color(0xFF3182ce),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Image.asset('assets/icons/logout.png',),
              )),



        ],
      ),
    );
  }
}
