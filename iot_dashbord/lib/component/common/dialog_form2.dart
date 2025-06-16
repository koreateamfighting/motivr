import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:iot_dashboard/utils/keyboard_handler.dart';
import 'package:iot_dashboard/utils/iframe_visibility.dart';



class DialogForm2 extends StatefulWidget {
  final String mainText;
  final String btnText1;
  final String btnText2;

  final VoidCallback? onConfirm;

  DialogForm2(
      {Key? key,
      required this.mainText,
      required this.btnText1,
      required this.btnText2,
      this.onConfirm})
      : super(key: key);

  @override
  State<DialogForm2> createState() => _DialogForm2State();
}

class _DialogForm2State extends State<DialogForm2> {
  final FocusNode _focusNode = FocusNode();
  static const designWidth = 3812;
  static const designHeight = 2144;

  @override
  void initState() {
    super.initState();
    // 키보드 포커스를 강제로 요청
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
    return      RawKeyboardListener(
        focusNode: _focusNode,
        onKey: (event) {
          handleEscapeKey(event, context); // ESC → 닫기
        },
        child: WillPopScope(
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Center(
                child: Container(
                  width: 1420.w,
                  height: 420.h,
                  decoration: BoxDecoration(
                    color: Color(0xff414c67),
                    border:
                    Border.all(color: Color(0xff9b9c9d), width: 10.w),
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: 80.h,
                        color: Color(0xff272e3f),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 18.w,
                            ),
                            Container(
                              width: 60.w,
                              height: 60.h,
                              child:
                              Image.asset('assets/icons/download.png'),
                            ),
                            Spacer(),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                width: 70.w,
                                height: 70.h,
                                child:
                                Image.asset('assets/icons/close.png'),
                              ),
                            ),
                            SizedBox(
                              width: 18.w,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        height: 1.h,
                      ),
                      SizedBox(
                        height: 62.h,
                      ),
                      SelectableText(
                        widget.mainText,
                        style: TextStyle(
                            fontFamily: 'PretendardGOV',
                            fontWeight: FontWeight.w500,
                            fontSize: 48.sp,
                            color: Colors.white),
                      ),
                      SizedBox(
                        height: 62.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () {
                              hideIframes(); // iframe 숨기기
                          Navigator.of(context).pop();
                              showIframes();
                            },
                            child: Container(
                              width: 200.w,
                              height: 80.h,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Color(0xff3182ce),
                                borderRadius: BorderRadius.circular(5.r),
                              ),
                              child: Text(
                                widget.btnText1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'PretendardGOV',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 40.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              hideIframes(); // iframe 숨기기
                              print("확인 버튼 눌림"); // <- 이게 안 찍히면 위에 iframe이 가리고 있는 것
                              Navigator.of(context).pop();
                              if (widget.onConfirm != null) {
                                widget.onConfirm!();
                              }
                              showIframes();
                            },
                            child: Container(
                              width: 200.w,
                              height: 80.h,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Color(0xff3182ce),
                                borderRadius: BorderRadius.circular(5.r),
                              ),
                              child: Text(
                                widget.btnText2,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'PretendardGOV',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 40.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )



                    ],
                  ),
                ),
              ),
            ),
            onWillPop: () async {
              Navigator.of(context).pop(); // ESC 또는 Android back 버튼 시 닫힘
              return false; // 기본 동작 막기
            }));
  }
}

