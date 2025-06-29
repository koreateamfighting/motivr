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
import 'package:iot_dashboard/component/common/dialog_form.dart';
class ExpandAlarmSearch extends StatefulWidget {

  final VoidCallback? onDataUploaded;
  const ExpandAlarmSearch({super.key,this.onDataUploaded});

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
  final List<String> levelOptions = ['정보', '주의', '경고', '점검'];


  bool isEditing = false;
  Map<int, Alarm> editedAlarms = {};
  Map<int, TextEditingController> messageControllers = {};
  Map<int, String> levelValues = {}; // 🔹 각 alarm id별 선택된 level 저장용
  Set<int> deletedAlarmIds = {};



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


  Future<void> _loadAlarms() async {
    final data = await AlarmController.fetchAlarms();
    setState(() {
      allAlarms = data;
      filteredAlarms = data;
    });
  }


  void _toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
      if (isEditing) {
        editedAlarms.clear();
        deletedAlarmIds.clear();
        messageControllers.clear();
        levelValues.clear(); // 🔹 추가

        for (final alarm in allAlarms) {
          messageControllers[alarm.id] = TextEditingController(text: alarm.message);
          levelValues[alarm.id] = alarm.level; // 🔹 현재 level 저장
        }
      }
    });
  }


  bool get isNothingChanged {
    if (deletedAlarmIds.isNotEmpty) return false;
    for (final entry in editedAlarms.entries) {
      final original = allAlarms.firstWhere((a) => a.id == entry.key);
      final edited = entry.value;

      if (original.message != edited.message || original.level != edited.level) {
        return false;
      }
    }
    return true;
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
      currentPage = 0;
      filteredAlarms = allAlarms.where((alarm) => alarm.message.toLowerCase().contains(query)).toList();
    });
  }

  Future<void> _saveChanges() async {
    List<Alarm> modified = [];

    for (final alarm in getCurrentPageItems()) {
      final newMessage = messageControllers[alarm.id]?.text ?? alarm.message;
      final newLevel = levelValues[alarm.id] ?? alarm.level;

      if (alarm.message != newMessage || alarm.level != newLevel) {
        modified.add(alarm.copyWith(message: newMessage, level: newLevel));
      }
    }

    if (deletedAlarmIds.isNotEmpty) {
      await AlarmController.deleteAlarms(deletedAlarmIds.toList());
    }

    if (modified.isNotEmpty) {
      await AlarmController.updateAlarms(modified);
    }

    await _loadAlarms();

    setState(() {
      currentPage = 0;
      isEditing = false;
      editedAlarms.clear();
      deletedAlarmIds.clear();
    });

    if (widget.onDataUploaded != null) {
      widget.onDataUploaded!();
    }
  }


  @override
  void dispose() {
    for (var controller in messageControllers.values) {
      controller.dispose();
    }
    _focusNode.dispose();
    showIframes();
    super.dispose();
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
                                          onTap: isEditing && isNothingChanged
                                              ? null
                                              : () async {
                                            final currentItems =
                                            getCurrentPageItems();
                                            List<Alarm> modified = [];
                                            if (isEditing) {
                                              for (final notice
                                              in currentItems) {
                                                final edited =
                                                editedAlarms[
                                                notice.id];
                                                if (edited != null) {
                                                  modified.add(edited);
                                                }
                                              }

                                              try {
                                                // ✅ 1. 삭제 먼저 처리
                                                if (deletedAlarmIds
                                                    .isNotEmpty) {
                                                  await AlarmController
                                                      .deleteAlarms(
                                                      deletedAlarmIds
                                                          .toList());
                                                }

                                                // ✅ 2. 수정 처리
                                                if (modified.isNotEmpty) {
                                                  final success =
                                                  await AlarmController
                                                      .updateAlarms(
                                                      modified);
                                                  if (success) {
                                                    final updatedAlarms =
                                                    await AlarmController
                                                      .fetchAlarms();
                                                    setState(() {
                                                      allAlarms =
                                                          updatedAlarms;
                                                      filteredAlarms=
                                                          updatedAlarms;
                                                      currentPage = 0;
                                                    });
                                                    await _saveChanges(); // ✅ 저장/삭제 처리 포함
                                                    // ✅ 콜백 실행
                                                    if (widget.onDataUploaded != null) {
                                                      widget.onDataUploaded!();
                                                    }
                                                    showDialog(
                                                      context: context,
                                                      builder: (_) =>
                                                      const DialogForm(
                                                        mainText:
                                                        '수정 및 삭제가 완료되었습니다.',
                                                        btnText: '확인',
                                                        fontSize: 16,
                                                      ),
                                                    );
                                                  }
                                                } else if (deletedAlarmIds
                                                    .isNotEmpty) {
                                                  // 수정 없이 삭제만 했을 때도 목록 갱신
                                                  final updatedAlarms =
                                                  await AlarmController.fetchAlarms();
                                                  setState(() {
                                                    allAlarms =
                                                        updatedAlarms;
                                                    filteredAlarms =
                                                        updatedAlarms;
                                                    currentPage = 0;
                                                  });
                                                  if (widget
                                                      .onDataUploaded !=
                                                      null) {
                                                    widget
                                                        .onDataUploaded!();
                                                  }

                                                  showDialog(
                                                    context: context,
                                                    builder: (_) =>
                                                    const DialogForm(
                                                      mainText:
                                                      '삭제가 완료되었습니다.',
                                                      btnText: '확인',
                                                      fontSize: 16,
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                showDialog(
                                                  context: context,
                                                  builder: (_) =>
                                                      DialogForm(
                                                        mainText:
                                                        '저장 중 오류 발생: $e',
                                                        btnText: '닫기',
                                                      ),
                                                );
                                              }
                                            }

                                            _toggleEditMode();
                                          },
                                          child: Text(
                                            isEditing ? '완료' : '편집',
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
                                      itemCount: getCurrentPageItems().length,
                                      itemBuilder: (context, index) {
                                        final alarm = getCurrentPageItems()[index];
                                        final messageController = messageControllers.putIfAbsent(
                                          alarm.id,
                                              () => TextEditingController(text: alarm.message),
                                        );

                                        return Container(
                                          height: 100.h,
                                          alignment: Alignment.centerLeft,
                                          child: Row(
                                            children: [
                                              SizedBox(width: 97.w),

                                              // 🔹 Timestamp
                                              SizedBox(
                                                width: 359.w,
                                                child: Text(
                                                  formatTimestamp(alarm.timestamp),
                                                  style: TextStyle(
                                                    fontFamily: 'PretendardGOV',
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 36.sp,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),

                                              SizedBox(width: isEditing ? 150.w : 255.w),

                                              // 🔹 Level (Dropdown or Text)
                                              SizedBox(
                                                width: isEditing? 400.w:125.w,
                                                child: isEditing
                                                    ? Row(
                                                  children: [
                                                    SizedBox(width: 80.w,),
                                                    Container(
                                                      width: 250.w,
                                                        color: Colors.white,
                                                        child: DropdownButton<String>(
                                                          value: levelValues[alarm.id],
                                                          dropdownColor: Colors.white,
                                                          icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                                                          style: TextStyle(
                                                            fontSize: 32.sp,
                                                            color: Colors.black,
                                                            fontFamily: 'PretendardGOV',
                                                          ),
                                                          items: levelOptions.map((level) => DropdownMenuItem(
                                                            value: level,
                                                            child: Text(level),
                                                          )).toList(),
                                                          onChanged: (newLevel) {
                                                            if (newLevel == null) return;
                                                            setState(() {
                                                              levelValues[alarm.id] = newLevel;

                                                              final prev = editedAlarms[alarm.id] ?? alarm;
                                                              editedAlarms[alarm.id] = prev.copyWith(
                                                                level: newLevel,
                                                                message: messageControllers[alarm.id]?.text ?? prev.message, // 병합
                                                              );
                                                            });
                                                          },


                                                        )
                                                    )

                                                  ],
                                                )
                                                    : Text(
                                                  alarm.level,
                                                  style: TextStyle(
                                                    fontFamily: 'PretendardGOV',
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 36.sp,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),

                                              SizedBox(width: isEditing?0.w: 255.w),

                                              // 🔹 Message (TextField or Text)
                                              Expanded(
                                                child: isEditing
                                                    ?  Container(
                                                  width: 1200.w,
                                                  color: Colors.white,
                                                  child: TextField(
                                                    controller: messageController,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        final prev = editedAlarms[alarm.id] ?? alarm;
                                                        editedAlarms[alarm.id] = prev.copyWith(
                                                          message: value,
                                                          level: levelValues[alarm.id] ?? prev.level, // 병합
                                                        );
                                                      });
                                                    },


                                                    style: TextStyle(
                                                      fontFamily: 'PretendardGOV',
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 36.sp,
                                                      color: Colors.black,
                                                    ),
                                                    decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
                                                    ),
                                                  ),
                                                )

                                                    : Text(
                                                  alarm.message,
                                                  style: TextStyle(
                                                    fontFamily: 'PretendardGOV',
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 36.sp,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),

                                              // 🔹 Delete button
                                              if (isEditing)
                                                Container(
                                                  width: 70.w,
                                                  height: 70.h,
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        deletedAlarmIds.add(alarm.id);
                                                        allAlarms.removeWhere((a) => a.id == alarm.id);
                                                        filteredAlarms.removeWhere((a) => a.id == alarm.id);
                                                      });
                                                    },
                                                    child: Image.asset(
                                                      'assets/icons/color_close.png',
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        );
                                      },
                                      separatorBuilder: (context, index) => Container(
                                        height: 2.h,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
,
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
