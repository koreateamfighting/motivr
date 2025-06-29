import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/controller/notice_controller.dart';
import 'package:iot_dashboard/model/notice_model.dart';
import 'package:flutter/services.dart';
import 'package:iot_dashboard/utils/keyboard_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iot_dashboard/utils/format_timestamp.dart';
import 'package:iot_dashboard/utils/iframe_visibility.dart';
import 'package:iot_dashboard/theme/colors.dart';
import 'package:iot_dashboard/component/common/dialog_form.dart';

class ExpandNoticeSearch extends StatefulWidget {

  final VoidCallback? onDataUploaded;

  const ExpandNoticeSearch({super.key,this.onDataUploaded});

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
  bool _isUploading = false;
  bool isEditing = false;
  bool _canDelete = false;
  Map<int, Notice> editedNotices = {};
  Map<int, TextEditingController> contentControllers = {};
  Set<int> deletedNoticeIds = {}; // ✅ 삭제된 ID들을 모아둘 집합
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

  void _initializeControllers() {
    for (final notice in allNotices) {
      final id = notice.id;
      editedNotices[id] = notice.copyWith();
      contentControllers.putIfAbsent(
          id, () => TextEditingController(text: notice.content));
    }
  }

  void _toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
      if (!isEditing) {
        editedNotices.clear();
        deletedNoticeIds.clear();
        _canDelete = false;
      } else {
        _initializeControllers();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _canDelete = true;
          });
        });
      }
    });
  }

  bool get isNothingChanged {
    // 삭제가 하나라도 있으면 false
    if (deletedNoticeIds.isNotEmpty) return false;

    // 수정된 항목이 원본과 동일한지 비교
    for (final entry in editedNotices.entries) {
      final original = allNotices.firstWhere((t) => t.id == entry.key,
          orElse: () => Notice(id: -1, content: '', createdAt: ''));
      final edited = entry.value;

      if (original.id == -1) continue; // 삭제되었거나 없으면 생략

      if (original.content != edited.content) {
        return false; // 값이 실제로 다르면 변경 있음
      }
    }

    return true; // 수정 및 삭제 모두 없을 때만 true
  }

  @override
  void dispose() {
    for (var controller in contentControllers.values) {
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
                                              focusedBorder:
                                                  AppColors.focusedBorder(2.w),
                                              // ✅ 여기에 적용
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

                                        color: isEditing? Colors.grey:Color(0xff3182ce),

                                        borderRadius:
                                            BorderRadius.circular(4.r),
                                        // child: 이후 실제 위젯 들어갈 수 있도록 구성해둠
                                      ),
                                      child: InkWell(
                                          onTap:
                                              isEditing ? null : _filterNotices,
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
                                        color: isEditing && isNothingChanged
                                            ? const Color(0xFF888888) // 회색
                                            : const Color(0xff3182ce), // 기본 파랑

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
                                                  List<Notice> modified = [];
                                                  if (isEditing) {
                                                    for (final notice
                                                        in currentItems) {
                                                      final edited =
                                                          editedNotices[
                                                              notice.id];
                                                      if (edited != null) {
                                                        modified.add(edited);
                                                      }
                                                    }

                                                    try {
                                                      // ✅ 1. 삭제 먼저 처리
                                                      if (deletedNoticeIds
                                                          .isNotEmpty) {
                                                        await NoticeController
                                                            .deleteNotices(
                                                                deletedNoticeIds
                                                                    .toList());
                                                      }

                                                      // ✅ 2. 수정 처리
                                                      if (modified.isNotEmpty) {
                                                        final success =
                                                            await NoticeController
                                                                .updateNotices(
                                                                    modified);
                                                        if (success) {
                                                          final updatedNotices =
                                                              await NoticeController
                                                                  .fetchNotices();
                                                          setState(() {
                                                            allNotices =
                                                                updatedNotices;
                                                            filteredNotices =
                                                                updatedNotices;
                                                            currentPage = 0;
                                                          });
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
                                                      } else if (deletedNoticeIds
                                                          .isNotEmpty) {
                                                        // 수정 없이 삭제만 했을 때도 목록 갱신
                                                        final updatedNotices =
                                                            await NoticeController
                                                                .fetchNotices();
                                                        setState(() {
                                                          allNotices =
                                                              updatedNotices;
                                                          filteredNotices =
                                                              updatedNotices;
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
                                            if (currentSortField ==
                                                'timestamp') ...[
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
                                            if (currentSortField ==
                                                'timestamp') ...[
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
                                              final globalIndex =
                                                  allNotices.indexOf(notice);
                                              final contentController =
                                                  contentControllers
                                                      .putIfAbsent(notice.id,
                                                          () {
                                                return TextEditingController(
                                                  text: editedNotices[notice.id]
                                                          ?.content ??
                                                      notice.content,
                                                );
                                              });
                                              return Container(
                                                key: ValueKey(notice.id),
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
                                                      width: isEditing
                                                          ? 150.w
                                                          : 255.w,
                                                    ),
                                                    isEditing
                                                        ?
                                                    Row(
                                                            children: [
                                                              Container(
                                                                  width: 1200.w,
                                                                  color: Colors
                                                                      .white,
                                                                  child:
                                                                      TextField(
                                                                    controller:
                                                                        contentController,
                                                                    onChanged:
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        editedNotices[
                                                                            notice.id] = (editedNotices[notice.id] ??
                                                                                notice)
                                                                            .copyWith(content: value);
                                                                      });
                                                                    },
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'PretendardGOV',
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontSize:
                                                                          36.sp,
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                    decoration:
                                                                        InputDecoration(
                                                                      border: InputBorder
                                                                          .none,
                                                                      contentPadding:
                                                                          EdgeInsets
                                                                              .zero,
                                                                    ),
                                                                  )),
                                                              SizedBox(
                                                                width: 16.w,
                                                              ),
                                                              Container(
                                                                width: 70.w,
                                                                height: 70.h,
                                                                child: InkWell(
                                                                    onTap: () {
                                                                      if (isEditing) {
                                                                        setState(() {
                                                                          deletedNoticeIds.add(notice.id);
                                                                          editedNotices.remove(notice.id);

                                                                          // ✅ 수정: 특정 항목만 삭제
                                                                          allNotices.removeWhere((item) => item.id == notice.id);
                                                                          filteredNotices = allNotices
                                                                              .where((item) => item.content
                                                                              .toLowerCase()
                                                                              .contains(_searchController.text.toLowerCase()))
                                                                              .toList();

                                                                          // ✅ 페이지 조정
                                                                          if (currentPage * itemsPerPage >= filteredNotices.length &&
                                                                              currentPage > 0) {
                                                                            currentPage--;
                                                                          }
                                                                        });
                                                                      }
                                                                    },

                                                                  child: Image
                                                                      .asset(
                                                                          'assets/icons/color_close.png'),
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        : Expanded(
                                                            child: isEditing
                                                                ? Container(
                                                                    color: Colors
                                                                        .white,
                                                                    child:
                                                                        TextField(
                                                                      controller:
                                                                          contentController,
                                                                      onChanged:
                                                                          (value) {
                                                                        setState(
                                                                            () {
                                                                          editedNotices[notice.id] =
                                                                              (editedNotices[notice.id] ?? notice).copyWith(content: value);
                                                                        });
                                                                      },
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'PretendardGOV',
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        fontSize:
                                                                            36.sp,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                      decoration:
                                                                          InputDecoration(
                                                                        border:
                                                                            InputBorder.none,
                                                                        contentPadding:
                                                                            EdgeInsets.symmetric(horizontal: 10.w),
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Text(
                                                                    notice
                                                                        .content,
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'PretendardGOV',
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontSize:
                                                                          36.sp,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
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
