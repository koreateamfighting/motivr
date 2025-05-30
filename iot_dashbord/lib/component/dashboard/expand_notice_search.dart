import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/controller/notice_controller.dart';
import 'package:iot_dashboard/model/notice_model.dart';
import 'package:flutter/services.dart';
import 'package:iot_dashboard/utils/keyboard_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iot_dashboard/utils/format_timestamp.dart';
import 'package:iot_dashboard/utils/iframe_visibility.dart';

class ExpandNoticeSearch extends StatefulWidget {
  const ExpandNoticeSearch({super.key});

  @override
  State<ExpandNoticeSearch> createState() => _ExpandNoticeSearchState();
}

class _ExpandNoticeSearchState extends State<ExpandNoticeSearch> {
  final FocusNode _focusNode = FocusNode();
  bool onCalendar = false;
  List<Notice> allNotices = [];
  List<Notice> filteredNotices = [];
  int currentPage = 0;
  static const int itemsPerPage = 14;
  TextEditingController _searchController = TextEditingController();
  String currentSortField = '';
  bool isAscending = true;

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    NoticeController.fetchNotices().then((data) {
      setState(() {
        allNotices = data;
        filteredNotices = data; // ✅ 초기에는 전체 데이터
      });
    });
  }

  @override
  void dispose() {
    showIframes(); // ✅ 다이얼로그 닫히고 나서 실행됨
    _focusNode.dispose();
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

      filteredNotices.sort((a, b) {
        int result;
        switch (field) {
          case 'createdAt':
            result = a.createdAt.compareTo(b.createdAt);
            break;
          case 'content':
            result = a.content.compareTo(b.content);
            break;

          default:
            result = 0;
        }
        return isAscending ? result : -result;
      });
    });
  }
  List<Notice> getCurrentPageItems() {
    final start = currentPage * itemsPerPage;
    final end = (start + itemsPerPage).clamp(0, filteredNotices.length);
    return filteredNotices.sublist(start, end);
  }

  void _filterNotices() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      currentPage = 0; // 검색 시 첫 페이지로 초기화
      filteredNotices = allNotices
          .where((notice) => notice.content.toLowerCase().contains(query))
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
            handleEnterKey(event, _filterNotices); // ✅ 엔터키 처리 추가
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
                                      child: Image.asset(
                                          'assets/icons/notice.png'),
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
                                          onTap: _filterNotices,
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
                                      onTap: () => _sortBy('createdAt'),
                                      child: Row(
                                        children: [

                                          Text('시간',
                                              style: TextStyle(
                                                  fontFamily: 'PretendardGOV',
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 36.sp,
                                                  color: Color(0xff3182ce))),
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
                                      )
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
                                        onTap: () => _sortBy('content'),
                                        child: Row(
                                          children: [

                                            Text('내용',
                                                style: TextStyle(
                                                    fontFamily: 'PretendardGOV',
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 36.sp,
                                                    color: Color(0xff3182ce))),
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
                                        )
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
                                    child: filteredNotices.isEmpty
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
                                              final notice =
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
                                                              notice.createdAt),
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
                                                      child: Text(
                                                          notice.content,
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
                                      '${currentPage * itemsPerPage + 1}-${(currentPage + 1) * itemsPerPage > filteredNotices.length ? filteredNotices.length : (currentPage + 1) * itemsPerPage} of ${filteredNotices.length}',
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
                                            allNotices.length) {
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
                                  )
                                ],
                              ),
                            )
                          ],
                        )),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
