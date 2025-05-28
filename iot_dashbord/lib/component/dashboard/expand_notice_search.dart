import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/theme/colors.dart';
import 'package:iot_dashboard/services/hls_player_iframe.dart';
import 'package:flutter/services.dart';
import 'package:iot_dashboard/utils/keyboard_handler.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpandNoticeSearch extends StatefulWidget {
  const ExpandNoticeSearch({super.key});

  @override
  State<ExpandNoticeSearch> createState() => _ExpandNoticeSearchState();
}

class _ExpandNoticeSearchState extends State<ExpandNoticeSearch> {
  final FocusNode _focusNode = FocusNode();
  bool onCalendar = false;

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
    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: (event) => handleEscapeKey(event, context),
      child: Material(
        // ✅ 필수
        color: Colors.transparent,
        child: Container(
          width: 2750.w,
          height: 1803.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 2080.w,
                height: double.infinity,
                color: Color.fromRGBO(255, 255, 255, 0.6),
                padding: EdgeInsets.fromLTRB(41.w, 34.h, 39.w, 34.h),
                child: Container(
                    width: 2000.w,
                    height: 1732.h,
                    color: Color(0xff272e3f),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            height: 100.h,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 35.w,
                                ),
                                Container(
                                  width: 50.w,
                                  height: 50.h,
                                  child: Image.asset('assets/icons/notice.png'),
                                ),
                                SizedBox(
                                  width: 14.w,
                                ),
                                Container(
                                  width: 350.w,
                                  child: Text('공지 및 주요 일정',
                                      style: TextStyle(
                                          fontFamily: 'PretendardGOV',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 48.sp,
                                          color: Colors.white)),
                                ),
                                Container(
                                    width: 400.w,
                                    height: 60.h,
                                    child: TextField(
                                      style: TextStyle(
                                        fontFamily: 'PretendardGOV',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 32.sp,
                                        color: Colors.black,
                                      ),
                                      decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          hintText: '검색',
                                          hintStyle: TextStyle(
                                            fontFamily: 'PretendardGOV',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 32.sp,
                                            color: Color(0xffa0aec0),
                                          ),
                                          prefixIcon: Container(
                                            width: 35.w,
                                            height: 40.h,
                                            child: Icon(
                                              Icons.search,
                                              color: Color(0xffa0aec0),
                                            ),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(5.r),
                                            borderSide:
                                            BorderSide(color: Colors.white),
                                          ),
                                          contentPadding: EdgeInsets.only(
                                            bottom: 25.h,
                                          )),
                                    )),
                                SizedBox(
                                  width: 29.w,
                                ),
                                Container(
                                  width: 140.w,
                                  height: 60.h,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    //color: Color(0xff111c44),
                                    color: Color(0xff3182ce),

                                    borderRadius: BorderRadius.circular(4.r),
                                    // child: 이후 실제 위젯 들어갈 수 있도록 구성해둠
                                  ),
                                  child: InkWell(
                                      onTap: () {},
                                      child: Text(
                                        '검색',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'PretendardGOV',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 36.sp,
                                          color: Colors.white,
                                        ),
                                      )),
                                ),
                                Spacer(),
                                Container(
                                  width: 100.w,
                                  height: 60.h,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    //color: Color(0xff111c44),
                                    color: Color(0xff3182ce),

                                    borderRadius: BorderRadius.circular(4.r),
                                    // child: 이후 실제 위젯 들어갈 수 있도록 구성해둠
                                  ),
                                  child: InkWell(
                                      onTap: () {},
                                      child: Text(
                                        '편집',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'PretendardGOV',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 36.sp,
                                          color: Colors.white,
                                        ),
                                      )),
                                ),
                                SizedBox(
                                  width: 24.w,
                                ),
                                Container(
                                    width: 70.w,
                                    height: 70.h,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Image.asset(
                                          'assets/icons/color_close.png'),
                                    )),
                                SizedBox(
                                  width: 13.w,
                                ),
                              ],
                            )),
                        Container(
                          width: 2000.w,
                          height: 2.h,
                          color: Colors.white,
                        ),
                        Container(
                          height: 100.h,
                          color: Color(0xff414c67),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 92.w,
                              ),
                              Container(
                                width: 314.w,
                                height: 60.h,
                                padding: EdgeInsets.only(left: 15.w),
                                decoration: BoxDecoration(
                                  //color: Color(0xff111c44),
                                  color: Colors.transparent,
                                  border: Border.all(
                                    color: Color(0xff3182ce),
                                    width: 4.w,
                                  ),
                                  borderRadius: BorderRadius.circular(5.r),
                                  // child: 이후 실제 위젯 들어갈 수 있도록 구성해둠
                                ),
                                child: InkWell(
                                  onTap: () {},
                                  child: Text('시간',
                                      style: TextStyle(
                                          fontFamily: 'PretendardGOV',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 36.sp,
                                          color: Color(0xff3182ce))),
                                ),
                              ),
                              SizedBox(
                                width: 224.w,
                              ),

                              Container(
                                width: 1308.w,
                                height: 60.h,
                                padding: EdgeInsets.only(left: 15.w),
                                decoration: BoxDecoration(
                                  //color: Color(0xff111c44),
                                  color: Colors.transparent,
                                  border: Border.all(
                                    color: Color(0xff3182ce),
                                    width: 4.w,
                                  ),
                                  borderRadius: BorderRadius.circular(5.r),
                                  // child: 이후 실제 위젯 들어갈 수 있도록 구성해둠
                                ),
                                child: InkWell(
                                  onTap: () {},
                                  child: Text('내용',
                                      style: TextStyle(
                                          fontFamily: 'PretendardGOV',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 36.sp,
                                          color: Color(0xff3182ce))),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(child: Container(color: Colors.brown,)),
                        Container(
                          height: 100.h,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 126.w,
                                child: Text(
                                  'pages',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 32.sp,
                                    fontWeight: FontWeight.w500,
                                  ),

                                ),
                              ),
                              Container(
                                width: 184.w,
                                height: 42.h,
                                child: Text(
                                  '1-14 of 500',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 32.sp,
                                    fontWeight: FontWeight.w500,
                                  ),

                                ),
                              ),
                              Container(
                                width: 20.w,
                                height: 35.h,
                                child:
                                Image.asset('assets/icons/arrow_left.png'),
                              ),
                              SizedBox(
                                width: 62.w,
                              ),
                              Container(
                                width: 20.w,
                                height: 35.h,
                                child:
                                Image.asset('assets/icons/arrow_right.png'),
                              ),
                              SizedBox(
                                width: 27.w,
                              )
                            ],
                          ),
                        )
                      ],
                    )),
              ),
              // SizedBox(width: 20.w),
              // Visibility(
              //   child: Container(
              //     width: 650.w,
              //     height: 742.h,
              //     color: Color(0xff414c67),
              //   ),
              //   visible: onCalendar,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
