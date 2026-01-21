import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/utils/live_clock.dart';
import 'package:iot_dashboard/utils/auth_service.dart';
import 'package:iot_dashboard/component/common/dialog_form2.dart';
import 'package:go_router/go_router.dart';
import 'package:iot_dashboard/controller/user_controller.dart';
import 'dart:html' as html;
import 'package:iot_dashboard/utils/iframe_visibility.dart';
import 'package:iot_dashboard/component/common/change_password_dialog.dart';
import 'package:iot_dashboard/utils/setting_service.dart';
import 'package:iot_dashboard/constants/global_constants.dart';
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
      child: ValueListenableBuilder(
          valueListenable: SettingService.settingNotifier,
          builder: (context, setting, _) {
            return Row(
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
                Tooltip(
                  message: '메뉴 펼치기/닫기',
                  child: Container(
                    alignment: Alignment.center,
                    width: 60.w,
                    height: 60.h,
                    child: InkWell(
                      onTap: onMenuPressed,
                      child: Image.asset('assets/icons/menu2.png'),
                    ),
                  ),
                )
                ,
                SizedBox(width: 140.w),
                Container(
                  width: 288.w,
                  height: 100.h,
                  color: Colors.white,
                  child: (SettingService.setting?.logoUrl != null &&
                      SettingService.setting!.logoUrl!.trim().isNotEmpty)
                      ? Image.network(
                    '${baseUrl3030}${SettingService.setting!.logoUrl!}',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image_not_supported);
                    },
                  )
                      : Image.asset(
                    'assets/images/default_logo.png', // ✅ 기본 로고 이미지
                    fit: BoxFit.contain,
                  ),
                ),

                SizedBox(
                  width: 169.w,
                ),
                LiveClock(),
                SizedBox(
                  width: 264.w,
                ),
                Container(
                  width: 1500.w,
                  child: Text(
                    (SettingService.setting?.title?.trim().isNotEmpty ?? false)
                        ? SettingService.setting!.title!
                        : '타이틀을 입력하세요.', // ✅ 안내 문구
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'PretendardGOV',
                        fontWeight: FontWeight.w700,
                        fontSize: 70.sp,
                        color: Color(0xff0b1437)),
                  ),
                ),
                SizedBox(width: 750.w),

                // WeatherInfoBar(),

                Tooltip(
                  message: 'Full screen on/off',
                  child: InkWell(
                    onTap: () {
                      toggleFullScreen();
                    },
                    child: Container(
                      width: 60.w,
                      height: 60.h,
                      padding: EdgeInsets.fromLTRB(4.0.w, 4.0.h, 4.0.w, 4.0.h),
                      decoration: BoxDecoration(
                        color: Color(0xFF3182ce),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Image.asset('assets/icons/max.png'),
                    ),
                  ),
                ),

                SizedBox(width: 63.w),
                Tooltip(
                  message: '설정',
                  child: InkWell(
                    onTap: () {
                      hideIframes();

                      showDialog(
                        context: context,
                        barrierDismissible: false, // 바깥 클릭으로 닫히지 않도록
                        builder: (_) => const ChangePasswordDialog(),
                      ).then((_) {
                        showIframes(); // 다이얼로그 닫힌 후 다시 iframe 보여주기
                      });
                    },

                    child: Container(
                      width: 60.w,
                      height: 60.h,
                      padding: EdgeInsets.fromLTRB(4.0.w, 4.0.h, 4.0.w, 4.0.h),
                      decoration: BoxDecoration(
                        color: Color(0xFF3182ce),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Image.asset('assets/icons/uncolor_setting.png'),
                    ),
                  ),
                ),
                SizedBox(width: 63.w),
                Tooltip(
                    message: '로그아웃',
                    child: InkWell(
                        onTap: () async {
                          hideIframes();

                          await showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) =>
                                DialogForm2(
                                  mainText: "로그아웃 하시겠습니까?",
                                  btnText1: "아니오",
                                  btnText2: "네",
                                  onConfirm: () async {
                                    final userID = await AuthService
                                        .getUserID();
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
                          padding:
                          EdgeInsets.fromLTRB(4.0.w, 4.0.h, 4.0.w, 4.0.h),
                          decoration: BoxDecoration(
                            color: Color(0xFF3182ce),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Image.asset(
                            'assets/icons/logout.png',
                          ),
                        ))),
              ],
            );
          }),
    );
  }
}
