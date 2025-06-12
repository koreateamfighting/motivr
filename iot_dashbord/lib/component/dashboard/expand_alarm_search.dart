import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:iot_dashboard/utils/keyboard_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iot_dashboard/controller/alarm_controller.dart';
import 'package:iot_dashboard/model/alarm_model.dart';
import 'package:iot_dashboard/utils/format_timestamp.dart';
import 'package:iot_dashboard/utils/iframe_visibility.dart';
import 'package:iot_dashboard/theme/colors.dart';
class ExpandAlarmSearch extends StatefulWidget {
  const ExpandAlarmSearch({super.key});

  @override
  State<ExpandAlarmSearch> createState() => _ExpandAlarmSearchState();
}

class _ExpandAlarmSearchState extends State<ExpandAlarmSearch> {
  final FocusNode _focusNode = FocusNode();
  bool onCalendar = false;
  List<Alarm> allAlarms = [];
  List<Alarm> filteredAlarms = [];
  int currentPage = 0;
  static const int itemsPerPage = 14;
  TextEditingController _searchController = TextEditingController();
  String currentSortField = '';
  bool isAscending = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    AlarmController.fetchAlarms().then((data) {
      setState(() {
        allAlarms = data;
        filteredAlarms = data; // ✅ 초기에는 전체 데이터
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    showIframes(); // ✅ 다이얼로그 닫히고 나서 실행됨
    super.dispose();
  }

  void _sortBy(String field) {
    setState(() {
      if (currentSortField == field) {
        isAscending = !isAscending;
      } else {
        currentSortField = field;
        isAscending = true;
      }

      filteredAlarms.sort((a, b) {
        int result;
        switch (field) {
          case 'timestamp':
            result = a.timestamp.compareTo(b.timestamp);
            break;
          case 'level':
            result = a.level.compareTo(b.level);
            break;
          case 'message':
            result = a.message.compareTo(b.message);
            break;
          default:
            result = 0;
        }
        return isAscending ? result : -result;
      });
    });
  }


  List<Alarm> getCurrentPageItems() {
    final start = currentPage * itemsPerPage;
    final end = (start + itemsPerPage).clamp(0, filteredAlarms.length);
    return filteredAlarms.sublist(start, end);
  }

  void _filterAlarms() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      currentPage = 0; // 검색 시 첫 페이지로 초기화
      filteredAlarms = allAlarms
          .where((alarm) => alarm.message.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        ScreenUtil.init(context,
            designSize: Size(3812, 2144), minTextAdapt: true);

        return RawKeyboardListener(
          focusNode: _focusNode,
          onKey: (event) {
            handleEscapeKey(event, context);
            handleEnterKey(event, _filterAlarms); // ✅ 엔터키 처리 추가
          },
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
                                      child:
                                          Image.asset('assets/icons/alarm.png'),
                                    ),
                                    SizedBox(
                                      width: 14.w,
                                    ),
                                    Container(
                                      width: 210.w,
                                      child: Text('최근 알람',
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
                                          controller: _searchController,
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
                                                borderSide: BorderSide(
                                                    color: Colors.white),
                                              ),
                                              focusedBorder: AppColors.focusedBorder(2.w), // ✅ 여기에 적용
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

                                        borderRadius:
                                            BorderRadius.circular(4.r),
                                        // child: 이후 실제 위젯 들어갈 수 있도록 구성해둠
                                      ),
                                      child: InkWell(
                                          onTap: _filterAlarms,
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

                                        borderRadius:
                                            BorderRadius.circular(4.r),
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
                                      color: Colors.transparent,
                                      border: Border.all(
                                        color: Color(0xff3182ce),
                                        width: 4.w,
                                      ),
                                      borderRadius: BorderRadius.circular(5.r),
                                    ),
                                    child: InkWell(
                                      onTap: () => _sortBy('timestamp'),
                                      child: Row(
                                        children: [
                                          Text(
                                            '시간',
                                            style: TextStyle(
                                              fontFamily: 'PretendardGOV',
                                              fontWeight: FontWeight.w700,
                                              fontSize: 36.sp,
                                              color: Color(0xff3182ce),
                                            ),
                                          ),
                                          if (currentSortField == 'timestamp') ...[
                                            SizedBox(width: 8.w),
                                            Text(
                                              isAscending ? '▲' : '▼',
                                              style: TextStyle(
                                                fontSize: 28.sp,
                                                color: Color(0xff3182ce),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            )
                                          ],
                                        ],
                                      ),
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
                                      color: Colors.transparent,
                                      border: Border.all(
                                        color: Color(0xff3182ce),
                                        width: 4.w,
                                      ),
                                      borderRadius: BorderRadius.circular(5.r),
                                    ),
                                    child: InkWell(
                                      onTap: () => _sortBy('level'), // 유형
                                      child: Row(
                                        children: [
                                          Text(
                                            '유형',
                                            style: TextStyle(
                                              fontFamily: 'PretendardGOV',
                                              fontWeight: FontWeight.w700,
                                              fontSize: 36.sp,
                                              color: Color(0xff3182ce),
                                            ),
                                          ),
                                          if (currentSortField == 'level') ...[
                                            SizedBox(width: 8.w),
                                            Text(
                                              isAscending ? '▲' : '▼',
                                              style: TextStyle(
                                                fontSize: 28.sp,
                                                color: Color(0xff3182ce),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            )
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),

                                  SizedBox(
                                    width: 234.w,
                                  ),
                              Container(
                                width: 838.w,
                                height: 60.h,
                                padding: EdgeInsets.only(left: 15.w),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border.all(
                                    color: Color(0xff3182ce),
                                    width: 4.w,
                                  ),
                                  borderRadius: BorderRadius.circular(5.r),
                                ),
                                child: InkWell(
                                  onTap: () => _sortBy('message'), // 메시지
                                  child: Row(
                                    children: [
                                      Text(
                                        '메세지',
                                        style: TextStyle(
                                          fontFamily: 'PretendardGOV',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 36.sp,
                                          color: Color(0xff3182ce),
                                        ),
                                      ),
                                      if (currentSortField == 'message') ...[
                                        SizedBox(width: 8.w),
                                        Text(
                                          isAscending ? '▲' : '▼',
                                          style: TextStyle(
                                            fontSize: 28.sp,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xff3182ce),
                                          ),
                                        ),
                                      ]
                                    ],
                                  ),
                                ),
                              ),

                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    height: 2.h,
                                    color: Colors.white,
                                  ),
                                  Expanded(
                                    child: filteredAlarms.isEmpty
                                        ? Center(
                                            child: Text(
                                              '검색 결과가 없습니다.',
                                              style: TextStyle(
                                                fontFamily: 'PretendardGOV',
                                                fontSize: 36.sp,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                            ),
                                          )
                                        : ListView.separated(
                                            itemCount:
                                                getCurrentPageItems().length,
                                            itemBuilder: (context, index) {
                                              final alarm =
                                                  getCurrentPageItems()[index];
                                              return Container(
                                                height: 100.h,
                                                // padding: EdgeInsets.symmetric(horizontal: 0.w),
                                                alignment: Alignment.centerLeft,
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 97.w,
                                                    ),
                                                    SizedBox(
                                                      width: 359.w,
                                                      child: Text(
                                                          formatTimestamp(
                                                              alarm.timestamp),
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'PretendardGOV',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 36.sp,
                                                              color: Colors
                                                                  .white)),
                                                    ),
                                                    SizedBox(
                                                      width: 255.w,
                                                    ),
                                                    SizedBox(
                                                      width: 125.w,
                                                      child: Text(alarm.level,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'PretendardGOV',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 36.sp,
                                                              color: Colors
                                                                  .white)),
                                                    ),
                                                    SizedBox(
                                                      width: 255.w,
                                                    ),
                                                    Expanded(
                                                      child: Text(alarm.message,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'PretendardGOV',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 36.sp,
                                                              color: Colors
                                                                  .white)),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            separatorBuilder:
                                                (context, index) => Container(
                                              height: 2.h,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                  Container(
                                    height: 2.h,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
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
                                      '${currentPage * itemsPerPage + 1}-${(currentPage + 1) * itemsPerPage > filteredAlarms.length ? filteredAlarms.length : (currentPage + 1) * itemsPerPage} of ${filteredAlarms.length}',
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
                                    child: InkWell(
                                      onTap: () {
                                        if (currentPage > 0) {
                                          setState(() {
                                            currentPage--;
                                          });
                                        }
                                      },
                                      child: Image.asset(
                                          'assets/icons/arrow_left.png'),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 62.w,
                                  ),
                                  Container(
                                    width: 20.w,
                                    height: 35.h,
                                    child: InkWell(
                                      onTap: () {
                                        if ((currentPage + 1) * itemsPerPage <
                                            allAlarms.length) {
                                          setState(() {
                                            currentPage++;
                                          });
                                        }
                                      },
                                      child: Image.asset(
                                          'assets/icons/arrow_right.png'),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 27.w,
                                  ),
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
      },
    );
  }
}
