import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:iot_dashboard/component/login/privacy_policy_page.dart';
import 'package:iot_dashboard/component/login/term_of_use_page.dart';
import 'dart:convert';
import 'package:iot_dashboard/controller/user_controller.dart';
import 'package:iot_dashboard/model/user_model.dart';
import 'package:iot_dashboard/component/login/register_success_dialog.dart';
import 'package:iot_dashboard/component/common/dialog_form.dart';
import 'package:flutter/services.dart';

class RegisterWidget extends StatefulWidget {
  const RegisterWidget({super.key});

  @override
  State<RegisterWidget> createState() => _RegisterWidgetState();
}

class _RegisterWidgetState extends State<RegisterWidget> {
  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  final _pwConfirmController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _companyController = TextEditingController();
  final _deptController = TextEditingController();
  final _positionController = TextEditingController();
  final _roleController = TextEditingController();
  bool checkedID = false;

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    _pwConfirmController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    _deptController.dispose();
    _positionController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _onRegisterTap() async {
    // 👉 ID, PW 둘 다 필수 검사
    if  (_idController.text.trim().isEmpty ||
        _pwController.text.isEmpty ||
        _emailController.text.trim().isEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false, // 바깥 클릭 시 닫히지 않도록
        builder: (_) => DialogForm(
          mainText: "필수항목을 입력해주세요.",
          btnText: "닫기",
        ),
      );
      return;
    }

    // 이메일 형식 검사 (간단한 정규식)
    final emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailPattern.hasMatch(_emailController.text.trim())) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => DialogForm(
          mainText: "유효한 이메일 주소를 입력해주세요.",
          btnText: "닫기",
        ),
      );
      return;
    }

    // 비밀번호 길이 검사 (4자리 이상)
    if (_pwController.text.length < 4) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => DialogForm(
          mainText: "비밀번호는 4자리 이상이어야 합니다.",
          btnText: "닫기",
        ),
      );
      return;
    }


    if (_pwController.text != _pwConfirmController.text) {
      showDialog(
        context: context,
        barrierDismissible: false, // 바깥 클릭 시 닫히지 않도록
        builder: (_) => DialogForm(
          mainText: "비밀번호가 일치 하지 않습니다..",
          btnText: "닫기",
        ),
      );
      return;
    }

    if (checkedID == false) {
      showDialog(
        context: context,
        barrierDismissible: false, // 바깥 클릭 시 닫히지 않도록
        builder: (_) => DialogForm(
          mainText: "아이디 중복체크를 확인 해주세요.",
          btnText: "닫기",
        ),
      );
      return;
    }

    // 나머지는 선택입력
    final user = UserModel(
      userID: _idController.text.trim(),
      password: _pwController.text,
      name: _nameController.text,
      phoneNumber: _phoneController.text,
      email: _emailController.text,
      company: _companyController.text,
      department: _deptController.text,
      position: _positionController.text,
      role: _roleController.text,
    );

    final errorMessage = await UserController.registerUser(user, context);

    if (errorMessage == null) {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        barrierDismissible: false, // 바깥 클릭 시 닫히지 않도록
        builder: (_) => RegisterSuccessDialog(),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false, // 바깥 클릭 시 닫히지 않도록
        builder: (_) => DialogForm(
          mainText: "${errorMessage}",
          btnText: "닫기",
        ),
      );
    }
  }

  static const designWidth = 3812;
  static const designHeight = 2144;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(designWidth.toDouble(), designHeight.toDouble()),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return WillPopScope(
          child: Material(
            color: Colors.transparent, // ✅ 전체 배경 제거
            child: Center(
              child: Container(
                width: 1276.w,
                height: 1984.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                          alignment: Alignment.center,
                          child: Text(
                            'Digital Twin CMS',
                            style: TextStyle(
                              fontFamily: 'PretendardGOV',
                              fontWeight: FontWeight.w800,
                              fontSize: 64.sp,
                              color: Color(0xff0B2144),
                            ),
                          )),
                      SizedBox(
                        height: 64.h,
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 800.w,
                              height: 62.h,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color(0xffd9d9d9), // 선 색상
                                    width: 2.w, // 선 두께
                                  ),
                                ),
                              ),
                              child:  Text.rich(TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: '회원 가입', style: TextStyle(
                                          fontSize: 36.sp,
                                          fontFamily: 'PretendartGOV',
                                          fontWeight: FontWeight.w700,
                                        color: Color(0xff0B2144),
                                      )),

                                      TextSpan(
                                          text:'\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t(', style: TextStyle(
                                          fontSize: 16.sp,
                                          fontFamily: 'PretendartGOV',
                                          fontWeight: FontWeight.w400,
                                          color: Colors.grey)

                                      ),
                                      TextSpan(
                                          text:'*', style: TextStyle(
                                          fontSize: 16.sp,
                                          fontFamily: 'PretendartGOV',
                                          fontWeight: FontWeight.w400,
                                          color: Colors.red)

                                      ),
                                      TextSpan(
                                          text:'표시 항목은 필수 입력 항목입니다.)', style: TextStyle(
                                          fontSize: 16.sp,
                                          fontFamily: 'PretendartGOV',
                                          fontWeight: FontWeight.w400,
                                          color: Colors.grey)

                                      ),
                                    ]
                                ))
                              // child: Text(
                              //   '회원 가입',
                              //   style: TextStyle(
                              //     fontFamily: 'PretendardGOV',
                              //     fontWeight: FontWeight.w700,
                              //     fontSize: 36.sp,
                              //     color: Color(0xff0B2144),
                              //   ),
                              // ),
                            ),
                            SizedBox(
                              height: 44.h,
                            ),

                              formLabel('아이디',true),

                            Container(
                              width: 800.w,
                              child: Row(
                                children: [
                                  formTextField(
                                    '아이디 입력 (6~20자)',
                                    _idController,
                                    borderColor: Color(0xff67788e),
                                    fieldType: FormFieldType.id,
                                    width: 550,
                                  ),
                                  SizedBox(width: 40.w),
                                  InkWell(
                                    onTap: () async {
                                      final userID = _idController.text.trim();

                                      if (userID.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text('아이디를 입력해주세요.')),
                                        );
                                        return;
                                      }

                                      final isAvailable = await UserController
                                          .checkDuplicateUserID(userID);

                                      if (isAvailable) {
                                        setState(() {
                                          checkedID = true;
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            // 바깥 클릭 시 닫히지 않도록
                                            builder: (_) => DialogForm(
                                              mainText: "사용가능한 아이디입니다.",
                                              btnText: "확인",
                                            ),
                                          );
                                        });
                                      } else {
                                        setState(() {
                                          checkedID = false;
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            // 바깥 클릭 시 닫히지 않도록
                                            builder: (_) => DialogForm(
                                              mainText: "이미 사용 중인 아이디입니다.",
                                              btnText: "닫기",
                                            ),
                                          );
                                        });
                                      }
                                    },
                                    child: Container(
                                      width: 210.w,
                                      height: 80.h,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Color(0xff3182ce),
                                        borderRadius: BorderRadius.circular(
                                            8.r), // 둥근 모서리
                                      ),
                                      child: Text(
                                        '중복체크',
                                        style: TextStyle(
                                          fontFamily: 'PretendardGOV',
                                          fontWeight: FontWeight.w800,
                                          fontSize: 36.sp,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            formLabel('비밀번호',true),
                            formTextField('비밀번호 입력 (문자, 숫자 포함)', _pwController,
                                borderColor: Color(0xff67788e),
                                fieldType: FormFieldType.password),
                            formLabel('비밀번호 확인',true),
                            formTextField('비밀번호 재입력', _pwConfirmController,
                                borderColor: Color(0xff67788e),
                                fieldType: FormFieldType.password),
                            SizedBox(
                              height: 37.h,
                            ),
                            Container(
                              width: 800.w,
                              height: 2.h,
                              color: Color(0xffd9d9d9),
                            ),
                            SizedBox(
                              height: 24.h,
                            ),
                            formLabel('이름',false),
                            formTextField('이름을 입력해주세요', _nameController,
                                fieldType: FormFieldType.name),
                            formLabel('연락처',false),
                            formTextField('연락처', _phoneController,
                                fieldType: FormFieldType.phone),
                            formLabel('이메일 주소',true),
                            formTextField('이메일 주소 입력', _emailController,
                                borderColor: Color(0xff67788e),
                                fieldType: FormFieldType.name),
                            formLabel('회사명',false),
                            formTextField('회사명을 입력해주세요', _companyController,
                                fieldType: FormFieldType.normal),
                            formLabel('부서명',false),
                            formTextField('부서명을 입력해주세요', _deptController,
                                fieldType: FormFieldType.normal),
                            formLabel('직급',false),
                            formTextField('직급을 입력해주세요', _positionController,
                                fieldType: FormFieldType.normal),
                            formLabel('담당업무',false),
                            formTextField('담당업무를 입력해주세요', _roleController,
                                fieldType: FormFieldType.normal),
                            SizedBox(
                              height: 54.h,
                            ),
                            Container(
                              width: 800.w,
                              height: 80.h,
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Container(
                                      width: 380.w,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Color(0xffffd900),
                                        borderRadius: BorderRadius.circular(
                                            8.r), // 둥근 모서리
                                      ),
                                      child: Text(
                                        '가입취소',
                                        style: TextStyle(
                                          fontFamily: 'PretendardGOV',
                                          fontWeight: FontWeight.w800,
                                          fontSize: 36.sp,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  InkWell(
                                    onTap: () {
                                      _onRegisterTap();
                                    },
                                    child: Container(
                                      width: 380.w,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Color(0xff84bf3c),
                                        borderRadius: BorderRadius.circular(
                                            8.r), // 둥근 모서리
                                      ),
                                      child: Text(
                                        '가입하기',
                                        style: TextStyle(
                                          fontFamily: 'PretendardGOV',
                                          fontWeight: FontWeight.w800,
                                          fontSize: 36.sp,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 46.h,
                            ),
                            Container(
                              width: 800.w,
                              height: 2.h,
                              color: Color(0xffd9d9d9),
                            ),
                            SizedBox(
                              height: 12.h,
                            ),
                            Container(
                              width: 800.w,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        // 바깥 클릭 시 닫히지 않도록
                                        builder: (_) => TermOfUsePage(),
                                      );
                                    },
                                    child: Container(
                                      width: 109.w,
                                      height: 50.h,
                                      child: Text(
                                        "이용약관",
                                        style: TextStyle(
                                          fontFamily: 'PretendardGOV',
                                          fontSize: 24.sp,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xff0b2144),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Transform.translate(
                                    offset: Offset(0, -4.h),
                                    child: Container(
                                      width: 1.w,
                                      height: 22.h,
                                      color: Color(0xff0b2144),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        // 바깥 클릭 시 닫히지 않도록
                                        builder: (_) => PrivacyPolicyPage(),
                                      );
                                    },
                                    child: Container(
                                      width: 186.w,
                                      height: 50.h,
                                      child: Text(
                                        "개인정보처리방침",
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          fontFamily: 'PretendardGOV',
                                          fontSize: 24.sp,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xff0b2144),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 18.h,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                                width: 800.w,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 130.w,
                                    ),
                                    Container(
                                      width: 151.83.w,
                                      height: 52.68.h,
                                      child: Image.asset(
                                        'assets/images/company_logo_small.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 53.w,
                                    ),

                                    // Copyright (C) 2025 by HANLIM. All rights reserved.
                                    Container(
                                        padding: EdgeInsets.only(top: 16.h),
                                        height: 52.68.h,
                                        child: RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              // 기본 스타일
                                              fontSize: 24,
                                              color: Colors.black,
                                            ),
                                            children: [
                                              TextSpan(
                                                  text:
                                                      'Copyright (C) 2025 by ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      fontSize: 16.sp,
                                                      color: Colors.black,
                                                      fontFamily:
                                                          'PretendardGOV')),
                                              TextSpan(
                                                  text: 'HANLIM. ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 16.sp,
                                                      color: Colors.black,
                                                      fontFamily:
                                                          'PretendardGOV')),
                                              TextSpan(
                                                  text: 'All rights reserved.',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      fontSize: 16.sp,
                                                      color: Colors.black,
                                                      fontFamily:
                                                          'PretendardGOV')),
                                            ],
                                          ),
                                        ))
                                  ],
                                ))
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          onWillPop: () async {
            Navigator.of(context).pop(); // ESC 또는 Android back 버튼 시 닫힘
            return false; // 기본 동작 막기
          },
        );
      },
    );
  }
}

Widget formLabel(String text,bool requireItem) {
  return Container(
    width: 800.w,
    height: 50.h,
    padding: EdgeInsets.only(top: 4.h),
    // child: Text(
    //   text,
    //   style: TextStyle(
    //     fontFamily: 'PretendardGOV',
    //     fontWeight: FontWeight.w400,
    //     fontSize: 24.sp,
    //     color: Color(0xff0B2144),
    //   ),
    // )
    child: Text.rich(TextSpan(
      children: <TextSpan>[
        TextSpan(
          text: text, style: TextStyle(
          fontSize: 24.sp,
          fontFamily: 'PretendartGOV',
          fontWeight: FontWeight.w400,
          color: Color(0xff0B2144)
    )),
        TextSpan(
          text:requireItem? '*':'', style: TextStyle(
            fontSize: 24.sp,
            fontFamily: 'PretendartGOV',
            fontWeight: FontWeight.w400,
            color: Colors.red)

        )
      ]
    )),
  );
}

enum FormFieldType {
  normal,
  id,
  password,
  name,
  phone,
}

Widget formTextField(
  String hintText,
  TextEditingController controller, {
  FormFieldType fieldType = FormFieldType.normal,
  Color borderColor = const Color(0xffe2e8f0),
  double width = 800,
  double height = 80,
}) {
  TextInputType keyboardType = TextInputType.text;
  List<TextInputFormatter> inputFormatters = [];

  // 필드별 입력 제약 설정
  switch (fieldType) {
    case FormFieldType.id:
      inputFormatters
          .add(FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')));
      break;
    case FormFieldType.password:
      // 비밀번호는 obscureText 처리만 별도로
      break;
    case FormFieldType.name:
      // inputFormatters
      //     .add(FilteringTextInputFormatter.allow(RegExp(r'[가-힣a-zA-Z]')));
      break;
    case FormFieldType.phone:
      keyboardType = TextInputType.number;
      inputFormatters.add(FilteringTextInputFormatter.digitsOnly);
      break;
    case FormFieldType.normal:
      inputFormatters.add(FilteringTextInputFormatter.deny(RegExp(r'\s')));
      break;
  }

  // 공백 제거 formatter는 전 필드 공통 적용
  inputFormatters.add(FilteringTextInputFormatter.deny(RegExp(r'\s')));

  return Container(
    // width: 800.w,
    // height: 80.h,
    width: width.w,
    height: height.h,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(2.r),
      border: Border.all(color: borderColor, width: 2.0.w),
    ),
    child: TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: fieldType == FormFieldType.password,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: hintText,
        hintStyle: TextStyle(
          color: Color(0xffA0AEC0),
          fontSize: 32.sp,
          fontWeight: FontWeight.w400,
          fontFamily: 'PretendardGOV',
        ),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
    ),
  );
}
