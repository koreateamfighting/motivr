import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/theme/colors.dart';
import 'package:iot_dashboard/services/hls_player_iframe.dart';
import 'package:flutter/services.dart';
import 'package:iot_dashboard/utils/keyboard_handler.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpandDutySearch extends StatefulWidget {
  const ExpandDutySearch({super.key});

  @override
  State<ExpandDutySearch> createState() => _ExpandDutySearchState();
}

class _ExpandDutySearchState extends State<ExpandDutySearch> {
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
                                  child: Image.asset('assets/icons/duty.png'),
                                ),
                                SizedBox(
                                  width: 14.w,
                                ),
                                Container(
                                  width: 160.w,
                                  child: Text('작업명',
                                      style: TextStyle(
                                          fontFamily: 'PretendardGOV',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 48.sp,
                                          color: Colors.white)),
                                ),
                                Container(
                                  width: 250.w,
                                  height: 60.h,
                                  color: Color(0xff3182ce),
                                  alignment: Alignment.center,
                                  child: InkWell(
                                    onTap: () {},
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          width: 50.w,
                                          height: 50.h,
                                          child: Image.asset(
                                              'assets/icons/upload.png'),
                                        ),

                                        Text(
                                          '파일 업로드',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'PretendardGOV',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 36.sp,
                                            color: Colors.white,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 34.w,
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
                                  width: 16.w,
                                ),
                                Container(
                                  width: 50.w,
                                  height: 50.h,
                                  child:
                                      Image.asset('assets/icons/calendar.png'),
                                ),
                                SizedBox(
                                  width: 11.w,
                                ),
                                Container(
                                  width: 141.w,
                                  height: 50.h,
                                  color: Colors.transparent,
                                  child: Text(
                                    '기간 선택',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 32.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 11.w,
                                ),
                                Container(
                                  width: 200.w,
                                  height: 60.h,
                                  color: Colors.white,
                                ),
                                Container(
                                  width: 50.w,
                                  height: 50.h,
                                  alignment: Alignment.center,
                                  color: Colors.transparent,
                                  child: Text(
                                    '~',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 32.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 200.w,
                                  height: 60.h,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 8.w,
                                ),
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
                                width: 88.w,
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
                                  child: Text('작업명',
                                      style: TextStyle(
                                          fontFamily: 'PretendardGOV',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 36.sp,
                                          color: Color(0xff3182ce))),
                                ),
                              ),
                              SizedBox(
                                width: 293.w,
                              ),
                              Container(
                                width: 150.w,
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
                                  child: Text('진행률',
                                      style: TextStyle(
                                          fontFamily: 'PretendardGOV',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 36.sp,
                                          color: Color(0xff3182ce))),
                                ),
                              ),
                              SizedBox(
                                width: 293.w,
                              ),
                              Container(
                                width: 213.w,
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
                                  child: Text('시작',
                                      style: TextStyle(
                                          fontFamily: 'PretendardGOV',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 36.sp,
                                          color: Color(0xff3182ce))),
                                ),
                              ),
                              SizedBox(
                                width: 228.w,
                              ),
                              Container(
                                width: 213.w,
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
                                  child: Text('완료',
                                      style: TextStyle(
                                          fontFamily: 'PretendardGOV',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 36.sp,
                                          color: Color(0xff3182ce))),
                                ),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                            child: Container(
                          color: Colors.brown,
                        )),
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
              SizedBox(width: 20.w),
              Container(
                  width: 650.w,
                  height: 742.h,
                  color: Color(0xff414c67),
                ),


            ],
          ),
        ),
      ),
    );
  }
}
