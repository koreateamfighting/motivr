import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/component/admin/custom_divider.dart';
import 'package:iot_dashboard/component/admin/datepicker_field.dart';
import 'package:iot_dashboard/component/admin/image_picker_text_field.dart';
import 'package:iot_dashboard/component/admin/labeled_textfield_section.dart';
import 'package:iot_dashboard/component/admin/action_button.dart';
import 'package:iot_dashboard/component/admin/section_title.dart';
import 'package:iot_dashboard/controller/user_controller.dart';
import 'package:iot_dashboard/model/user_model.dart';
import 'package:iot_dashboard/component/common/dialog_form.dart';

class AuthSection extends StatefulWidget {
  final TextEditingController? idController;
  final TextEditingController? pwController;
  final TextEditingController? nameController;
  final TextEditingController? phoneController;
  final TextEditingController? emailController;
  final TextEditingController? companyController;
  final TextEditingController? deptController;
  final TextEditingController? positionController;
  final TextEditingController? roleController;

  const AuthSection({
    Key? key,
    this.idController,
    this.pwController,
    this.nameController,
    this.phoneController,
    this.emailController,
    this.companyController,
    this.deptController,
    this.positionController,
    this.roleController,
  }) : super(key: key);

  @override
  State<AuthSection> createState() => _AuthSectionState();
}

class _AuthSectionState extends State<AuthSection> {
  bool isExpanded = false; // ✅ 펼침 여부 상태
  bool _checkedID = false;
  bool _isCheckingId = false;
  late TextEditingController idController;
  late TextEditingController pwController;
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController companyController;
  late TextEditingController deptController;
  late TextEditingController positionController;
  late TextEditingController roleController;

  @override
  void initState() {
    super.initState();
    idController = widget.idController ?? TextEditingController();
    pwController = widget.pwController ?? TextEditingController();
    nameController = widget.nameController ?? TextEditingController();
    phoneController = widget.phoneController ?? TextEditingController();
    emailController = widget.emailController ?? TextEditingController();
    companyController = widget.companyController ?? TextEditingController();
    deptController = widget.deptController ?? TextEditingController();
    positionController = widget.positionController ?? TextEditingController();
    roleController = widget.roleController ?? TextEditingController();
  }

  bool get _isFormValid {
    final id = idController.text.trim();
    final pw = pwController.text;
    final email = emailController.text.trim();

    // 이메일 정규식 간단 검증
    final emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return id.isNotEmpty &&
        _checkedID &&
        pw.length >= 4 &&
        emailPattern.hasMatch(email);
  }

  Future<void> _checkDuplicateID() async {
    final id = idController.text.trim();
    if (id.isEmpty) {
      _showDialog('아이디를 입력해주세요.');
      return;
    }

    setState(() => _isCheckingId = true);
    final available = await UserController.checkDuplicateUserID(id);
    setState(() {
      _checkedID = available;
      _isCheckingId = false;
    });

    if (available) {
      _showDialog('사용 가능한 아이디입니다.');
    } else {
      _showDialog('이미 사용 중인 아이디입니다.');
    }
  }

  void _showDialog(String text) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => DialogForm(
        mainText: text,
        btnText: '확인',
      ),
    );
  }

  Future<void> _onRegisterTap() async {
    final id = idController.text.trim();
    final pw = pwController.text;
    final email = emailController.text.trim();

    if (id.isEmpty || pw.isEmpty || email.isEmpty) {
      _showDialog('아이디, 비밀번호, 이메일은 필수 입력입니다.');
      return;
    }

    // 이메일 검증
    final emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailPattern.hasMatch(email)) {
      _showDialog('유효한 이메일 주소를 입력해주세요.');
      return;
    }

    // 비밀번호 4자리 이상 검사
    if (pw.length < 4) {
      _showDialog('비밀번호는 4자리 이상이어야 합니다.');
      return;
    }

    if (!_checkedID) {
      _showDialog('아이디 중복체크를 확인해주세요.');
      return;
    }

    // 회원가입 요청 (UserModel은 user_controller.dart에서 임포트 필수)
    final user = UserModel(
      userID: id,
      password: pw,
      email: email,
      name: nameController.text,
      phoneNumber: phoneController.text,
      company: companyController.text,
      department: deptController.text,
      position: positionController.text,
      role: roleController.text,
    );

    final errorMessage = await UserController.registerUser(user, context);

    if (errorMessage == null) {
      _showDialog('회원가입이 성공적으로 완료되었습니다.');
      _clearForm();
    } else {
      _showDialog(errorMessage);
    }
  }

  void _clearForm() {
    idController.clear();
    pwController.clear();
    emailController.clear();
    nameController.clear();
    phoneController.clear();
    companyController.clear();
    deptController.clear();
    positionController.clear();
    roleController.clear();
    _checkedID = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ✅ 헤더 클릭 시 펼침/접힘 전환
        Container(
          width: 2880.w,
          height: 70.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.r),
            color: const Color(0xff414c67),
          ),
          child: Row(
            children: [
              SizedBox(width: 41.w),
              Text(
                '인증 및 권한',
                style: TextStyle(
                  fontFamily: 'PretendardGOV',
                  fontSize: 36.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Image.asset(
                  isExpanded
                      ? 'assets/icons/arrow_down.png'
                      : 'assets/icons/arrow_right2.png',
                  width: isExpanded ? 40.w : 50.w,
                  height: isExpanded ? 20.h : 30.h,
                ),
              ),
              SizedBox(width: 55.w),
            ],
          ),
        ),

        // ✅ 본문 영역 (isExpanded에 따라 표시/숨김)
        if (isExpanded) ...[
          SizedBox(height: 5.h),
          Container(
            width: 2880.w,
            height: 4825.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.r),
              color: const Color(0xff414c67),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      labeledTextField(
                        title: '아이디 :',
                        hint: '(필수입력) 아이디',
                        width: 800,
                        height: 60,
                        textBoxwidth: 401,
                        textBoxHeight: 50,
                        controller: idController,
                        onChanged: (_) => setState(() {}), // ✅ 변경 감지 시 UI 갱신
                      ),
                      SizedBox(width: 20.w),
                      InkWell(
                        onTap: _isCheckingId ? null : _checkDuplicateID,
                        child: Container(
                          width: 180.w,
                          height: 50.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _checkedID
                                ? Colors.green
                                : (_isCheckingId
                                    ? Colors.grey
                                    : Color(0xff3182ce)),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: _isCheckingId
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.h,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3.w,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _checkedID ? '확인됨' : '중복체크',
                                  style: TextStyle(
                                    fontFamily: 'PretendardGOV',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 30.sp,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '비밀번호 :',
                    hint: '(필수입력) 비밀번호 4자리 이상',
                    width: 800,
                    height: 60,
                    textBoxwidth: 401,
                    textBoxHeight: 50,
                    controller: pwController,
                    onChanged: (_) => setState(() {}), // ✅ 변경 감지 시 UI 갱신
                  ),
                ),
                CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '이름 : ',
                    hint: 'ex) 홍길동',
                    width: 800,
                    height: 60,
                    textBoxwidth: 401,
                    textBoxHeight: 50,
                    controller: nameController,
                  ),
                ),
                CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '연락처 :',
                    hint: '- 없이 입력',
                    width: 800,
                    height: 60,
                    textBoxwidth: 401,
                    textBoxHeight: 50,
                    controller: phoneController,
                  ),
                ),
                CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '이메일 주소 :',
                    hint: '(필수 입력) ex): abc@corp.kr',
                    width: 800,
                    height: 60,
                    textBoxwidth: 401,
                    textBoxHeight: 50,
                    controller: emailController,
                    onChanged: (_) => setState(() {}), // ✅ 변경 감지 시 UI 갱신
                  ),
                ),
                CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '회사명 :',
                    hint: 'ex) (주) 한림 기술',
                    width: 800,
                    height: 60,
                    textBoxwidth: 401,
                    textBoxHeight: 50,
                    controller: companyController,
                  ),
                ),
                CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '부서명 :',
                    hint: 'ex) 연구개발',
                    width: 800,
                    height: 60,
                    textBoxwidth: 401,
                    textBoxHeight: 50,
                    controller: deptController,
                  ),
                ),
                CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '직급',
                    hint: 'ex) 과장, 사원, 대리 등',
                    width: 800,
                    height: 60,
                    textBoxwidth: 401,
                    textBoxHeight: 50,
                    controller: positionController,
                  ),
                ),
                CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '담당업무 :',
                    hint: 'ex) 현장관리, 총괄 등',
                    width: 800,
                    height: 60,
                    textBoxwidth: 401,
                    textBoxHeight: 50,
                    controller: roleController,
                  ),
                ),
                CustomDivider(),
                SizedBox(height: 15.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ActionButton(
                      '등록',
                      _isFormValid ? const Color(0xffe98800) : Colors.grey,
                      onTap: _isFormValid ? _onRegisterTap : null,
                    ),
                    SizedBox(width: 34.w),
                  ],
                ),
                SizedBox(height: 5.h),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
