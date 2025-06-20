import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/controller/user_controller.dart';
import 'package:iot_dashboard/utils/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:iot_dashboard/utils/keyboard_handler.dart';
import 'dialog_form.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final currentPwController = TextEditingController();
  final newPwController = TextEditingController();
  final confirmPwController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
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
      designSize: Size(3812, 2144),
      builder: (context, child) {
        return RawKeyboardListener(
          focusNode: _focusNode,
          onKey: (event) {
            handleEscapeKey(event, context);
          },
          child: WillPopScope(
            onWillPop: () async {
              Navigator.of(context).pop();
              return false;
            },
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Center(
                child: Container(
                  width: 1420.w,
                  height: 750.h,
                  decoration: BoxDecoration(
                    color: const Color(0xff414c67),
                    border: Border.all(color: const Color(0xff9b9c9d), width: 10.w),
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 80.h,
                        color: const Color(0xff272e3f),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: 18.w),
                            Image.asset('assets/icons/download.png', width: 60.w, height: 60.h),
                            const Spacer(),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Image.asset('assets/icons/close.png', width: 70.w, height: 70.h),
                            ),
                            SizedBox(width: 18.w),
                          ],
                        ),
                      ),
                      Container(height: 1.h, color: Colors.white),
                      SizedBox(height: 32.h),
                      _passwordField("현재 비밀번호", currentPwController),
                      _passwordField("새 비밀번호", newPwController),
                      _passwordField("새 비밀번호 확인", confirmPwController),
                      SizedBox(height: 24.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _actionButton("취소", onTap: () => Navigator.pop(context)),
                          SizedBox(width: 40.w),
                          _actionButton("변경", onTap: _changePassword),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _passwordField(String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 100.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 36.sp,
                  fontFamily: 'PretendardGOV',
                  fontWeight: FontWeight.w400)),
          SizedBox(height: 10.h),
          Container(
            height: 80.h,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE2E8F0), width: 2.w),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: TextField(
              controller: controller,
              obscureText: true,
              style: TextStyle(fontSize: 36.sp),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String text, {required VoidCallback onTap}) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: 220.w,
        height: 80.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xff3182ce),
          borderRadius: BorderRadius.circular(5.r),
        ),
        child: Text(
          text,
          style: TextStyle(
              fontFamily: 'PretendardGOV',
              fontSize: 36.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _changePassword() async {
    final currentPw = currentPwController.text;
    final newPw = newPwController.text;
    final confirmPw = confirmPwController.text;

    if (newPw != confirmPw) {
      _showDialog("새 비밀번호가 일치하지 않습니다.");
      return;
    }

    final userID = await AuthService.getUserID();
    if (userID == null) return;

    setState(() => isLoading = true);
    final success = await UserController.changePassword(userID, currentPw, newPw);
    setState(() => isLoading = false);

    if (success && context.mounted) {
      Navigator.of(context).pop(); // 다이얼로그 닫기
      await UserController.logout(userID); // 로그아웃
      context.go('/login');
    } else {
      _showDialog("비밀번호 변경에 실패했습니다.");
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => DialogForm(mainText: message, btnText: "확인"),
    );
  }
}
