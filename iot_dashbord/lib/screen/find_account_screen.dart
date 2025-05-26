import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iot_dashboard/component/register.dart';
import 'package:iot_dashboard/theme/colors.dart'; // ✅ 추가
import 'package:iot_dashboard/controller/user_controller.dart';
import 'package:iot_dashboard/component/dialog_form.dart';
import 'package:flutter/services.dart';
import 'package:iot_dashboard/utils/keyboard_handler.dart';

class FindAccountScreen extends StatefulWidget {
  final String tab; // <- ✅ 탭 정보 ('id' or 'pw')

  const FindAccountScreen({Key? key, this.tab = 'id'}) : super(key: key);

  @override
  State<FindAccountScreen> createState() => _FindAccountScreenState();
}

class _FindAccountScreenState extends State<FindAccountScreen> {
  static const designWidth = 3812;
  static const designHeight = 2144;
  final _idController = TextEditingController();
  final _nameController = TextEditingController();

  final FocusNode _focusNode = FocusNode(); // ✅ 키 이벤트 포커스용
  late String selectedTab;
  bool showResult = false; // ✅ 추가

  List<String> foundUserIDs = []; // ✅ 여기에 추가해줘
  @override
  void initState() {
    super.initState();
    // 키보드 포커스를 강제로 요청
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uri = Uri.base;
      final tab = uri.queryParameters['tab'];
      selectedTab = widget.tab == 'pw' ? 'pw' : 'id'; // 안전하게 처리
      _focusNode.requestFocus();
      setState(() {}); // 반영
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
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
            //handleEnterKey(event, _login); // Enter → 로그인
            handleEscapeKey(event, context); // ESC → 닫기
          },
          child: Scaffold(
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
                      child: Image.asset('assets/images/company_logo.png'),
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
                          'Digital Twin CMS',
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
                            color: Color(0xff0b1437),
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
                                height: 66.h,
                              ),
                              Container(
                                height: 42.h,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 217.w,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectedTab = 'id';
                                        });
                                      },
                                      child: Text(
                                        '아이디 찾기',
                                        style: TextStyle(
                                          fontFamily: 'PretendardGOV',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 32.sp,
                                          color: selectedTab == 'id'
                                              ? Color(0xFF3182CE)
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 61.w,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectedTab = 'pw';
                                        });
                                      },
                                      child: Text(
                                        '비밀번호 찾기',
                                        style: TextStyle(
                                          fontFamily: 'PretendardGOV',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 32.sp,
                                          color: selectedTab == 'pw'
                                              ? Color(0xFF3182CE)
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 73.5.h,
                              ),
                              Container(
                                width: 600.w,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 50.h,
                                        child: Text(
                                          selectedTab == 'id' ? '이름' : "아이디",
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
                                            controller: selectedTab == 'id'
                                                ? _nameController
                                                : _idController,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: selectedTab == 'id'
                                                  ? "이름 입력"
                                                  : "아이디 입력",
                                              hintStyle: TextStyle(
                                                color: Color(0xffA0AEC0),
                                                fontSize: 32.sp,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: 'PretendardGOV',
                                              ),
                                              isDense: true,
                                              // 👈 여백 자동 줄이기
                                              contentPadding:
                                                  EdgeInsets.zero, // 👈 여백 제거
                                            ),
                                            style: TextStyle(
                                              fontSize: 36.sp,
                                              color: Color(0xff2d3748),
                                            ),
                                            textAlignVertical: TextAlignVertical
                                                .center, // 👈 수직 정렬 핵심
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 25.h,
                                      ),
                                      Container(
                                        width: 600.w,
                                        height: 2.h,
                                        color: Color(0xffD9D9D9),
                                      ),
                                      SizedBox(
                                        height: 25.h,
                                      ),
                                      Center(
                                        child: Container(
                                          width: 160.w,
                                          height: 80.h,
                                          padding: EdgeInsets.only(top: 20.h),
                                          decoration: BoxDecoration(
                                            color: Color(0xff3182ce),
                                            borderRadius:
                                                BorderRadius.circular(5.r),
                                          ),
                                          child: InkWell(
                                            onTap: () async {
                                              if (selectedTab == 'id') {
                                                final name =
                                                    _nameController.text.trim();

                                                if (name.isEmpty) {
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) => DialogForm(
                                                        mainText: "이름을 입력해주세요.",
                                                        btnText: "확인"),
                                                  );
                                                  return;
                                                }

                                                final ids = await UserController
                                                    .findUserIDsByName(name);
                                                setState(() {
                                                  foundUserIDs = ids;
                                                  showResult = ids
                                                      .isNotEmpty; // ✅ 결과 존재 시 true
                                                });

                                                if (ids.isEmpty) {
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) => DialogForm(
                                                        mainText:
                                                            "일치하는 계정을 찾을 수 없습니다.",
                                                        btnText: "확인"),
                                                  );
                                                }
                                              } else {
                                                showDialog(
                                                  context: context,
                                                  builder: (_) => DialogForm(
                                                      mainText:
                                                          "비밀번호 찾기는 아직 준비중입니다.\n 관리자에게 문의 바랍니다.",
                                                      btnText: "확인"),
                                                );
                                              }
                                            },
                                            child: Text(
                                              "조회",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 32.sp,
                                                  fontFamily: 'PretendardGOV'),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // SizedBox(
                                      //   height: 68.h,
                                      // ),
                                      // Center(
                                      //   child: Text(selectedTab == 'id'?"아이디 찾기가 완료되었습니다.":"비밀번호 찾기가 완료되었습니다.",
                                      //       style: TextStyle(
                                      //           color: Colors.white,
                                      //           fontWeight: FontWeight.w500,
                                      //           fontSize: 24.sp,
                                      //           fontFamily: 'PretendardGOV')),
                                      // ),
                                      SizedBox(height: 39.h)
                                    ]),
                              ),
                              Visibility(
                                  visible: selectedTab == 'id' && showResult,
                                  child: Container(
                                    width: 600.w,
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 600.w,
                                            height: 80.h,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16.w),
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              border: Border.all(
                                                color: const Color(0xFFE2E8F0),
                                                width: 1.w,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                            ),
                                            child: Center(
                                              child: SelectableText(
                                                foundUserIDs.isNotEmpty
                                                    ? '[ ${foundUserIDs.join(' ')} ]' +
                                                        (foundUserIDs.length ==
                                                                1
                                                            ? ' 입니다.'
                                                            : ' 중 하나입니다.')
                                                    : '',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 28.sp,
                                                  fontFamily: 'PretendardGOV',
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 25.h,
                                          ),
                                          Container(
                                            width: 600.w,
                                            height: 2.h,
                                            color: Color(0xffD9D9D9),
                                          ),
                                        ]),
                                  )),
                              SizedBox(
                                height: 66.h,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                      width: 280.w,
                                      height: 80.h,
                                      padding: EdgeInsets.only(top: 16.h),
                                      decoration: BoxDecoration(
                                        color: Color(0xff3182ce),

                                        borderRadius: BorderRadius.circular(
                                            5.r), // 둥근 모서리
                                      ),
                                      child: InkWell(
                                        onTap: () async {
                                          context.go('/login');
                                        },
                                        child: (Text(
                                          '로그인',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'PretendardGOV',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 32.sp,
                                            color: Color(0xffFFFFFF),
                                          ),
                                        )),
                                      )),
                                  SizedBox(
                                    width: 39.w,
                                  ),
                                  Container(
                                      width: 280.w,
                                      height: 80.h,
                                      padding: EdgeInsets.only(top: 16.h),
                                      decoration: BoxDecoration(
                                        color: Color(0xff0b1437),
                                        border: Border.all(
                                            color: Color(0xff3182ce),
                                            width: 4.w),
                                        borderRadius: BorderRadius.circular(
                                            5.r), // 둥근 모서리
                                      ),
                                      child: InkWell(
                                        onTap: () async {
                                          setState(() {
                                            if (selectedTab == 'id') {
                                              selectedTab = 'pw';
                                            } else {
                                              selectedTab = 'id';
                                            }
                                          });
                                        },
                                        child: (Text(
                                          selectedTab == 'id'
                                              ? '비밀번호 찾기'
                                              : "아이디 찾기",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'PretendardGOV',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 32.sp,
                                            color: Color(0xffFFFFFF),
                                          ),
                                        )),
                                      )),
                                ],
                              )
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
              )),
        );
      },
    );
  }
}
