import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iot_dashboard/component/login/register_view.dart';
import 'package:iot_dashboard/theme/colors.dart'; // ✅ 추가
import 'package:iot_dashboard/controller/user_controller.dart';
import 'package:iot_dashboard/component/common/dialog_form.dart';
import 'package:flutter/services.dart';
import 'package:iot_dashboard/utils/keyboard_handler.dart';
import 'package:iot_dashboard/utils/setting_service.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const designWidth = 3812;
  static const designHeight = 2144;
  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  final FocusNode _focusNode = FocusNode(); // ✅ 키 이벤트 포커스용

  @override
  void initState() {
    super.initState();
    // 키보드 포커스를 강제로 요청
    SettingService.refresh(); // 🔁 TopAppBar 갱신 트리거
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final userID = _idController.text.trim();
    final password = _pwController.text;

    if (userID.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => DialogForm(
          mainText: "아이디와 비밀번호를 입력해주세요.",
          btnText: "닫기",
        ),
      );
      return;
    }

    final errorMessage = await UserController.login(userID, password);
    if (errorMessage == null) {
      // 로그인 성공 후 role 검사
      final user = UserController.currentUser;
      if (user?.role == 'disabled') {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const DialogForm(
            mainText: '회원 승인 요청이 필요합니다.\n관리자에게 문의하세요.',
            btnText: '확인',
          ),
        );
        return;
      }
      context.go('/DashBoard');
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => DialogForm(
          mainText: errorMessage,
          btnText: '닫기',
        ),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(designWidth.toDouble(), designHeight.toDouble()),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return RawKeyboardListener(
            focusNode: _focusNode,
            onKey: (event) {
              handleEnterKey(event, _login); // Enter → 로그인
              handleEscapeKey(event, context); // ESC → 닫기
            },
            child:
            Scaffold(
                backgroundColor: Colors.transparent,
                body: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/background_image.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/background_color.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      child: Container(
                        width: 215.59.w,
                        height: 74.8.h,
                        child: Text('버전:20250730',style: TextStyle(color: Colors.white,fontSize: 16.sp),),
                      ),
                      bottom: 0.2.h,
                      left: 80.w,
                    ),
                    Positioned(
                      child: Container(
                        width: 215.59.w,
                        height: 74.8.h,
                        child: Image.network(
                          'https://hanlimtwin.kr:3030${SettingService.setting?.logoUrl ?? ''}',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image_not_supported);
                          },
                        )
                      ),
                      bottom: 60.2.h,
                      right: 92.41.w,
                    ),
                    Center(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 380.h,
                          ),
                          // Container(
                          //   width: 1406.w,
                          //   height: 372.h,
                          //   child: Image.asset(
                          //     'assets/images/company_logo_big.png',
                          //   ),
                          // ),

                          Text(
                            SettingService.setting?.title ?? '_',
                            style: TextStyle(
                              fontFamily: 'PretendardGOV',
                              fontWeight: FontWeight.w800,
                              fontSize: 96.sp,
                              color: Color(0xff0B2144),
                            ),
                          ),
                          SizedBox(
                            height: 280.h,
                          ),
                          Container(
                            width: 809.w,
                            height: 953.h,
                            decoration: BoxDecoration(
                              color: AppColors.main1,
                              border: Border.all(
                                color: Color(0xffA0AEC0),
                                width: 2.w,
                              ),
                              borderRadius:
                              BorderRadius.circular(20.r), // 선택사항: 둥근 테두리
                            ),
                            child: Center(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 65.h,
                                    ),
                                    Text(
                                      'Welcome!',
                                      style: TextStyle(
                                        fontFamily: 'PretendardGOV',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 32.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 73.5.h,
                                    ),
                                    AutofillGroup(child: Column(
                                      children: [
                                        Container(
                                          width: 600.w,
                                          child: Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  height: 50.h,
                                                  child: Text(
                                                    '아이디',
                                                    style: TextStyle(
                                                      fontFamily: 'PretendardGOV',
                                                      fontWeight: FontWeight.w400,
                                                      fontSize: 24.sp,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: 600.w,
                                                  height: 80.h,
                                                  // 고정된 입력창 높이
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 16.w),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border.all(
                                                      color: const Color(0xFFE2E8F0),
                                                      width: 1.w,
                                                    ),
                                                    borderRadius:
                                                    BorderRadius.circular(8.r),

                                                  ),

                                                  child: Center(
                                                    child: TextField(

                                                      controller: _idController,
                                                      cursorColor: AppColors.cursorColor,
                                                      decoration: InputDecoration(

                                                        border: InputBorder.none,
                                                        hintText: "아이디 입력",

                                                        hintStyle: TextStyle(
                                                          color: Color(0xffA0AEC0),
                                                          fontSize: 32.sp,
                                                          fontWeight: FontWeight.w400,
                                                          fontFamily: 'PretendardGOV',
                                                        ),
                                                        isDense: true,
                                                        // 👈 여백 자동 줄이기
                                                        contentPadding: EdgeInsets.symmetric(vertical: 16.h),
                                                        // 👈 여백 제거
                                                      ),
                                                      style: TextStyle(
                                                        fontSize: 36.sp,
                                                        color: Color(0xff2d3748),
                                                      ),
                                                      textAlignVertical:
                                                      TextAlignVertical
                                                          .center, // 👈 수직 정렬 핵심
                                                    ),
                                                  ),
                                                ),

                                                Container(
                                                  alignment: Alignment.centerRight,

                                                  height: 50.h,
                                                  child: InkWell(
                                                    onTap: (){
                                                      // 아이디 찾기 클릭 시
                                                      context.go('/find_account?tab=id');

                                                    },
                                                    child: Text(
                                                      '아이디 찾기',
                                                      style: TextStyle(
                                                        fontFamily: 'PretendardGOV',
                                                        fontWeight: FontWeight.w400,
                                                        fontSize: 20.sp,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                )



                                              ]),
                                        ),
                                        Container(
                                          width: 600.w,
                                          child: Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  height: 50.h,
                                                  child: Text(
                                                    '비밀번호',
                                                    style: TextStyle(
                                                      fontFamily: 'PretendardGOV',
                                                      fontWeight: FontWeight.w400,
                                                      fontSize: 24.sp,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: 600.w,
                                                  height: 80.h,
                                                  // 고정된 입력창 높이
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 16.w),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border.all(
                                                      color: const Color(0xFFE2E8F0),
                                                      width: 1.w,
                                                    ),
                                                    borderRadius:
                                                    BorderRadius.circular(8.r),
                                                  ),
                                                  child: Center(
                                                    child: TextField(
                                                      controller: _pwController,
                                                      obscureText: true,
                                                      decoration: InputDecoration(
                                                        border: InputBorder.none,
                                                        contentPadding: EdgeInsets.symmetric(vertical: 16.h),
                                                        hintText: "비밀번호 입력",
                                                        hintStyle: TextStyle(
                                                          color: Color(0xffA0AEC0),
                                                          fontSize: 32.sp,
                                                          fontWeight: FontWeight.w400,
                                                          fontFamily: 'PretendardGOV',
                                                        ),
                                                        isDense: true,
                                                        // 👈 여백 자동 줄이기

                                                      ),
                                                      style: TextStyle(
                                                        fontSize: 36.sp,
                                                        color: Color(0xff2d3748),
                                                      ),
                                                      textAlignVertical:
                                                      TextAlignVertical
                                                          .center, // 👈 수직 정렬 핵심
                                                    ),
                                                  ),
                                                ),


                                                Container(
                                                  alignment: Alignment.centerRight,

                                                  height: 50.h,
                                                  child: InkWell(
                                                    onTap: (){
                                                      context.go('/find_account?tab=pw');
                                                    },
                                                    child: Text(
                                                      '비밀번호 찾기',
                                                      style: TextStyle(
                                                        fontFamily: 'PretendardGOV',
                                                        fontWeight: FontWeight.w400,
                                                        fontSize: 20.sp,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                )

                                              ]),
                                        ),
                                      ],
                                    )),

                                    SizedBox(
                                      height: 31.h,
                                    ),
                                    Container(
                                        width: 600.w,
                                        height: 80.h,
                                        padding: EdgeInsets.only(top: 12.h),
                                        decoration: BoxDecoration(
                                          color: Color(0xff3182ce),

                                          borderRadius: BorderRadius.circular(
                                              8.r), // 둥근 모서리
                                        ),
                                        child: InkWell(
                                          onTap: () async {
                                            final userID =
                                            _idController.text.trim();
                                            final password = _pwController.text;

                                            if (userID.isEmpty ||
                                                password.isEmpty) {
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                // 바깥 클릭 시 닫히지 않도록
                                                builder: (_) => DialogForm(
                                                  mainText: "아이디와 비밀번호를 입력해주세요.",
                                                  btnText: "닫기",
                                                ),
                                              );
                                              return;
                                            }

                                            final errorMessage =
                                            await UserController.login(
                                                userID, password);
                                            if (errorMessage == null) {
                                              context.go('/DashBoard');
                                            } else {
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                // 바깥 클릭 시 닫히지 않도록
                                                builder: (_) => DialogForm(
                                                  mainText: "${errorMessage}",
                                                  btnText: "닫기",
                                                ),
                                              );
                                            }
                                          },
                                          child: (Text(
                                            '로그인',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: 'PretendardGOV',
                                              fontWeight: FontWeight.w800,
                                              fontSize: 36.sp,
                                              color: Color(0xffFFFFFF),
                                            ),
                                          )),
                                        )),
                                    SizedBox(
                                      height: 47.h,
                                    ),
                                    Container(
                                      width: 600.w,
                                      height: 2.h,
                                      color: Color(0xffd9d9d9),
                                    ),
                                    SizedBox(
                                      height: 98.h,
                                    ),
                                    Container(
                                        width: 600.w,
                                        height: 80.h,
                                        padding: EdgeInsets.only(top: 12.h),
                                        decoration: BoxDecoration(
                                          color: Color(0xff84bf3c),

                                          borderRadius: BorderRadius.circular(
                                              8.r), // 둥근 모서리
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              barrierColor: Colors.transparent,
                                              barrierDismissible: true,
                                              // 바깥 터치로 닫기
                                              builder: (BuildContext context) {
                                                return const RegisterWidget();
                                              },
                                            );
                                          },
                                          child: (Text(
                                            '회원 가입',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: 'PretendardGOV',
                                              fontWeight: FontWeight.w800,
                                              fontSize: 36.sp,
                                              color: Color(0xffFFFFFF),
                                            ),
                                          )),
                                        )),
                                  ],
                                )),
                          ),
                          SizedBox(
                            height: 285.h,
                          ),
                        ],
                      ),
                    ),
                  ],
                )));
      },
    );
  }
}
