import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/controller/worktask_controller.dart';
import 'package:iot_dashboard/model/worktask_model.dart';
import 'package:flutter/services.dart';
import 'package:iot_dashboard/services/selectable_calendar.dart';
import 'package:iot_dashboard/utils/keyboard_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:iot_dashboard/utils/iframe_visibility.dart';

class ExpandWorkTaskSearch extends StatefulWidget {
  const ExpandWorkTaskSearch({super.key});

  @override
  State<ExpandWorkTaskSearch> createState() => _ExpandWorkTaskSearchState();
}

class _ExpandWorkTaskSearchState extends State<ExpandWorkTaskSearch> {
  final FocusNode _focusNode = FocusNode();
  final dateFormat = DateFormat('yyyy-MM-dd');
  bool onCalendar = false;
  List<WorkTask> allWorkTask = [];
  List<WorkTask> filteredWorkTask = [];
  int currentPage = 0;
  static const int itemsPerPage = 14;
  TextEditingController _searchController = TextEditingController();
  String currentSortField = '';
  bool isAscending = true;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    WorkTaskController.fetchTasks().then((data) {
      setState(() {
        allWorkTask = data;
        filteredWorkTask = data; // ✅ 초기에는 전체 데이터
      });
    });
  }

  @override
  void dispose() {
    showIframes();
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

      filteredWorkTask.sort((a, b) {
        int result;
        switch (field) {
          case 'title':
            result = a.title.compareTo(b.title);
            break;
          case 'progress':
            result = a.progress.compareTo(b.progress);
            break;
          case 'startDate':
            result = a.startDate.toString().compareTo(b.startDate.toString());
            break;
          case 'endDate':
            result = a.endDate.toString().compareTo(b.endDate.toString());
            break;
          default:
            result = 0;
        }
        return isAscending ? result : -result;
      });
    });
  }

  List<WorkTask> getCurrentPageItems() {
    final start = currentPage * itemsPerPage;
    final end = (start + itemsPerPage).clamp(0, filteredWorkTask.length);
    return filteredWorkTask.sublist(start, end);
  }
  void _filterWorkTask() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      currentPage = 0;

      filteredWorkTask = allWorkTask.where((task) {
        final matchQuery = task.title.toLowerCase().contains(query);
        final matchDate = matchDateRange(task);
        return matchQuery && matchDate;
      }).toList();
    });
  }

  bool matchDateRange(WorkTask task) {
    DateTime? taskStart = task.startDate != null ? DateTime.tryParse(task.startDate!) : null;
    DateTime? taskEnd = task.endDate != null ? DateTime.tryParse(task.endDate!) : null;

    if (_selectedStartDate != null && _selectedEndDate != null) {
      // 둘 다 설정된 경우: 작업 시작~종료가 모두 범위 안에 있어야 함
      return taskStart != null &&
          taskEnd != null &&
          !taskStart.isBefore(_selectedStartDate!) &&
          !taskEnd.isAfter(_selectedEndDate!);
    } else if (_selectedStartDate != null) {
      // 시작일만 있는 경우: 작업 시작일이 해당 날짜 이상이어야 함
      return taskStart != null && !taskStart.isBefore(_selectedStartDate!);
    } else if (_selectedEndDate != null) {
      // 종료일만 있는 경우: 작업 종료일이 해당 날짜 이하이어야 함
      return taskEnd != null && !taskEnd.isAfter(_selectedEndDate!);
    }

    return true; // 날짜 필터 없음
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
            handleEnterKey(event, _filterWorkTask); // ✅ 엔터키 처리 추가
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
                                          'assets/icons/work_task.png'),
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
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
                                      width: 16.w,
                                    ),
                                    Container(
                                      width: 50.w,
                                      height: 50.h,
                                      child: Image.asset(
                                          'assets/icons/calendar.png'),
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
                                      alignment: Alignment.center,
                                      child: Text(
                                        _selectedStartDate != null
                                            ? DateFormat('yyyyMMdd').format(_selectedStartDate!)
                                            : '',
                                        style: TextStyle(
                                          fontFamily: 'PretendardGOV',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 28.sp,
                                          color: Colors.black,
                                        ),
                                      ),
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
                                      alignment: Alignment.center,
                                      child: Text(
                                        _selectedEndDate != null
                                            ? DateFormat('yyyyMMdd').format(_selectedEndDate!)
                                            : '',
                                        style: TextStyle(
                                          fontFamily: 'PretendardGOV',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 28.sp,
                                          color: Colors.black,
                                        ),
                                      ),
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

                                        borderRadius:
                                            BorderRadius.circular(4.r),
// child: 이후 실제 위젯 들어갈 수 있도록 구성해둠
                                      ),
                                      child: InkWell(
                                          onTap: _filterWorkTask,
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
                                        onTap: () => _sortBy('title'),
                                        child: Row(
                                          children: [
                                            Text('작업명',
                                                style: TextStyle(
                                                    fontFamily: 'PretendardGOV',
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 36.sp,
                                                    color: Color(0xff3182ce))),
                                            if (currentSortField ==
                                                'title') ...[
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
                                        )),
                                  ),
                                  SizedBox(
                                    width: 273.w,
                                  ),
                                  Container(
                                    width: 170.w,
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
                                        onTap: () => _sortBy('progress'),
                                        child: Row(
                                          children: [
                                            Text('진행률',
                                                style: TextStyle(
                                                    fontFamily: 'PretendardGOV',
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 36.sp,
                                                    color: Color(0xff3182ce))),
                                            if (currentSortField ==
                                                'progress') ...[
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
                                        )),
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
                                      onTap: () => _sortBy('startDate'), // 유형
                                      child: Row(children: [
                                        Text('시작',
                                            style: TextStyle(
                                                fontFamily: 'PretendardGOV',
                                                fontWeight: FontWeight.w700,
                                                fontSize: 36.sp,
                                                color: Color(0xff3182ce))),
                                        if (currentSortField == 'startDate') ...[
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
                                      ]),
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
                                      onTap: () => _sortBy('endDate'), // 유형
                                      child: Row(
                                        children: [
                                          Text('완료',
                                              style: TextStyle(
                                                  fontFamily: 'PretendardGOV',
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 36.sp,
                                                  color: Color(0xff3182ce))),
                                          if (currentSortField == 'endDate') ...[
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
                                  )
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
                                    child: filteredWorkTask.isEmpty
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
                                              final workTask =
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
                                                          workTask.title,
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
                                                      child: Text(
                                                          '${workTask.progress.toString()}%',
                                                          textAlign:
                                                              TextAlign.end,
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
                                                      width: 305.w,
                                                    ),
                                                    SizedBox(
                                                      width: 220.w,
                                                      child: Text(
                                                          workTask.startDate !=
                                                                  null
                                                              ? dateFormat.format(
                                                                  DateTime.parse(
                                                                      workTask
                                                                          .startDate!))
                                                              : '',
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
                                                      width: 220.w,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                          workTask.endDate != null
                                                              ? dateFormat.format(
                                                                  DateTime.parse(
                                                                      workTask
                                                                          .endDate!))
                                                              : '',
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
                                      '${currentPage * itemsPerPage + 1}-${(currentPage + 1) * itemsPerPage > filteredWorkTask.length ? filteredWorkTask.length : (currentPage + 1) * itemsPerPage} of ${filteredWorkTask.length}',
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
                                            allWorkTask.length) {
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
                  SizedBox(width: 20.w),
                  SelectableCalendar(
                    onDateSelected: (start, end) {
                      setState(() {
                        _selectedStartDate = start;
                        _selectedEndDate = end;
                      });
                    },
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
