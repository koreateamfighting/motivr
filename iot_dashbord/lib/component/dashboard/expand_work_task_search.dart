import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/controller/worktask_controller.dart';
import 'package:iot_dashboard/model/worktask_model.dart';
import 'package:flutter/services.dart';
import 'package:iot_dashboard/utils/selectable_calendar.dart';
import 'package:iot_dashboard/utils/keyboard_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:iot_dashboard/utils/iframe_visibility.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:iot_dashboard/component/common/dialog_form.dart';
import 'package:iot_dashboard/theme/colors.dart';
import 'dart:convert';
import 'package:iot_dashboard/utils/auth_service.dart';
class ExpandWorkTaskSearch extends StatefulWidget {
  final VoidCallback? onDataUploaded; // ✅ 콜백 추가

  const ExpandWorkTaskSearch({super.key, this.onDataUploaded});

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
  bool _isUploading = false;
  bool isEditing = false;

  bool _canDelete = false;
  Map<int, WorkTask> editedTasks = {};
  Map<int, TextEditingController> titleControllers = {};
  Map<int, TextEditingController> progressControllers = {};
  Map<int, TextEditingController> startDateControllers = {};
  Map<int, TextEditingController> endDateControllers = {};
  Set<int> deletedTaskIds = {}; // ✅ 삭제된 ID들을 모아둘 집합

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

  void _initializeControllers() {
    for (final task in allWorkTask) {
      final id = task.id;
      editedTasks[id] = task.copyWith();
      titleControllers.putIfAbsent(
          id, () => TextEditingController(text: task.title));
      progressControllers.putIfAbsent(
          id, () => TextEditingController(text: task.progress.toString()));
      startDateControllers.putIfAbsent(
          id, () => TextEditingController(text: task.startDate ?? ""));
      endDateControllers.putIfAbsent(
          id, () => TextEditingController(text: task.endDate ?? ""));
    }
  }

  void _toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
      if (!isEditing) {
        editedTasks.clear();
        deletedTaskIds.clear();
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

  @override
  void dispose() {
    for (var controller in titleControllers.values) {
      controller.dispose();
    }
    for (var controller in progressControllers.values) {
      controller.dispose();
    }
    for (var controller in startDateControllers.values) {
      controller.dispose();
    }
    for (var controller in endDateControllers.values) {
      controller.dispose();
    }

    _focusNode.dispose();
    showIframes();
    super.dispose();
  }

  bool _isValidDate(String? date) {
    if (date == null || date.isEmpty) return true;
    try {
      DateTime.parse(date);
      return true;
    } catch (_) {
      return false;
    }
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
    DateTime? taskStart =
        task.startDate != null ? DateTime.tryParse(task.startDate!) : null;
    DateTime? taskEnd =
        task.endDate != null ? DateTime.tryParse(task.endDate!) : null;

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

  Future<void> uploadCsvFile() async {
    if (_isUploading) return;
    _isUploading = true;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true, // ✅ Web에서 필수
      );

      if (result == null || result.files.isEmpty) return;

      final fileBytes = result.files.first.bytes;
      final fileName = result.files.first.name;

      if (fileBytes == null) return;

      final uri = Uri.parse('https://hanlimtwin.kr:3030/api/upload-csv');
      final request = http.MultipartRequest('POST', uri)
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
        ));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        final inserted = data['inserted'] ?? 0;
        final duplicated = data['duplicated'] ?? 0;

        String mainText;
        if (inserted == 0 && duplicated > 0) {
          mainText = '모든 항목이 중복되어\n업로드된 데이터가 없습니다.';
        } else {
          mainText = '작업명 리스트가 갱신되었습니다.\n'
              '(추가: $inserted개 / 중복 제외: $duplicated개)';
        }
        // ✅ 콜백 실행
        if (widget.onDataUploaded != null) {
          widget.onDataUploaded!();
        }
        showDialog(
          context: context,
          builder: (_) => DialogForm(
            mainText: mainText,
            btnText: '확인',
            fontSize: 16,
          ),
        );

        // 🔁 목록 재갱신
        final updatedTasks = await WorkTaskController.fetchTasks();
        setState(() {
          allWorkTask = updatedTasks;
          filteredWorkTask = updatedTasks;
          currentPage = 0;
        });
      } else if (response.statusCode == 400) {
        // ❗ 서버에서 CSV 컬럼 오류 응답 시
        showDialog(
          context: context,
          builder: (_) => const DialogForm(
            mainText:
                'CSV 형식이 잘못되었습니다.\n필수 컬럼(title, progress, start_date, end_date)이 없습니다.',
            btnText: '확인',
            fontSize: 16,
          ),
        );
      } else {
        // 기타 실패
        showDialog(
          context: context,
          builder: (_) => DialogForm(
            mainText: '업로드 실패: 서버 오류 (${response.statusCode})',
            btnText: '닫기',
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => DialogForm(
          mainText: '업로드 중 예외 발생: ${e.toString()}',
          btnText: '닫기',
        ),
      );
    } finally {
      _isUploading = false;
    }
  }

  bool get isNothingChanged {
    // 삭제가 하나라도 있으면 false
    if (deletedTaskIds.isNotEmpty) return false;

    // 수정된 항목이 원본과 동일한지 비교
    for (final entry in editedTasks.entries) {
      final original = allWorkTask.firstWhere((t) => t.id == entry.key, orElse: () => WorkTask(id: -1, title: '', progress: 0));
      final edited = entry.value;

      if (original.id == -1) continue; // 삭제되었거나 없으면 생략

      if (original.title != edited.title ||
          original.progress != edited.progress ||
          original.startDate != edited.startDate ||
          original.endDate != edited.endDate) {
        return false; // 값이 실제로 다르면 변경 있음
      }
    }

    return true; // 수정 및 삭제 모두 없을 때만 true
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
                                      color: isEditing? Colors.grey:Color(0xff3182ce),
                                      alignment: Alignment.center,
                                      child: _isUploading
                                          ? SizedBox(
                                              width: 30.w,
                                              height: 30.h,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 4.w,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Color(0xff3182ce)),
                                              ),
                                            )
                                          :  InkWell(
                                        onTap: isEditing
                                            ? null
                                            : () async {
                                          final isAuthorized = AuthService.isRoot() || AuthService.isStaff(); // ✅ 권한 확인
                                          if (!isAuthorized) {
                                            await showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (_) => const DialogForm(
                                                mainText: '권한이 없습니다.',
                                                btnText: '확인',
                                              ),
                                            );
                                            return;
                                          }
                                          uploadCsvFile(); // ✅ 권한 있으면 업로드 실행
                                        },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
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
                                                      fontFamily:
                                                          'PretendardGOV',
                                                      fontWeight:
                                                          FontWeight.w700,
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
                                              focusedBorder:
                                                  AppColors.focusedBorder(2.w),
                                              // ✅ 여기에 적용
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
                                            ? DateFormat('yyyyMMdd')
                                                .format(_selectedStartDate!)
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
                                            ? DateFormat('yyyyMMdd')
                                                .format(_selectedEndDate!)
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
                                        color: isEditing? Colors.grey:Color(0xff3182ce),

                                        borderRadius:
                                            BorderRadius.circular(4.r),
// child: 이후 실제 위젯 들어갈 수 있도록 구성해둠
                                      ),
                                      child: InkWell(
                                          onTap: isEditing? null:_filterWorkTask,
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
                                            final isAuthorized = AuthService.isRoot() || AuthService.isStaff(); // ✅ 권한 확인
                                            if (!isAuthorized) {
                                              await showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (_) => const DialogForm(
                                                  mainText: '권한이 없습니다.',
                                                  btnText: '확인',
                                                ),
                                              );
                                              return;
                                            }
                                                  final currentItems =
                                                      getCurrentPageItems();
                                                  List<WorkTask> modified = [];
                                                  if (isEditing) {
                                                    for (final task
                                                        in currentItems) {
                                                      final edited =
                                                          editedTasks[task.id];
                                                      if (edited != null) {
                                                        // 🔍 진행률 유효성 검사
                                                        if (edited.progress <
                                                                0 ||
                                                            edited.progress >
                                                                100) {
                                                          showDialog(
                                                            context: context,
                                                            builder: (_) =>
                                                                const DialogForm(
                                                              mainText:
                                                                  '진행률은 0~100 사이여야 합니다.',
                                                              btnText: '확인',
                                                              fontSize: 16,
                                                            ),
                                                          );
                                                          return;
                                                        }

                                                        // 🔍 날짜 형식 유효성 검사
                                                        if (!_isValidDate(
                                                            edited.startDate)) {
                                                          showDialog(
                                                            context: context,
                                                            builder: (_) =>
                                                                const DialogForm(
                                                              mainText:
                                                                  '시작일 형식이 잘못되었습니다.',
                                                              btnText: '확인',
                                                              fontSize: 16,
                                                            ),
                                                          );
                                                          return;
                                                        }

                                                        if (!_isValidDate(
                                                            edited.endDate)) {
                                                          showDialog(
                                                            context: context,
                                                            builder: (_) =>
                                                                const DialogForm(
                                                              mainText:
                                                                  '종료일 형식이 잘못되었습니다.',
                                                              btnText: '확인',
                                                              fontSize: 16,
                                                            ),
                                                          );
                                                          return;
                                                        }

                                                        // 🔍 시작일 > 종료일 여부 검사
                                                        if (edited.startDate !=
                                                                null &&
                                                            edited.endDate !=
                                                                null &&
                                                            edited.startDate!
                                                                .isNotEmpty &&
                                                            edited.endDate!
                                                                .isNotEmpty) {
                                                          final start = DateTime
                                                              .tryParse(edited
                                                                  .startDate!);
                                                          final end = DateTime
                                                              .tryParse(edited
                                                                  .endDate!);
                                                          if (start != null &&
                                                              end != null &&
                                                              start.isAfter(
                                                                  end)) {
                                                            showDialog(
                                                              context: context,
                                                              builder: (_) =>
                                                                  const DialogForm(
                                                                mainText:
                                                                    '시작일은 종료일보다 빠르거나 같아야 합니다.',
                                                                btnText: '확인',
                                                                fontSize: 16,
                                                              ),
                                                            );
                                                            return;
                                                          }
                                                        }

                                                        modified.add(edited);
                                                      }
                                                    }

                                                    try {
                                                      // ✅ 1. 삭제 먼저 처리
                                                      if (deletedTaskIds
                                                          .isNotEmpty) {
                                                        await WorkTaskController
                                                            .deleteTasks(
                                                                deletedTaskIds
                                                                    .toList());
                                                      }

                                                      // ✅ 2. 수정 처리
                                                      if (modified.isNotEmpty) {
                                                        final success =
                                                            await WorkTaskController
                                                                .updateTasks(
                                                                    modified);
                                                        if (success) {
                                                          final updatedTasks =
                                                              await WorkTaskController
                                                                  .fetchTasks();
                                                          setState(() {
                                                            allWorkTask =
                                                                updatedTasks;
                                                            filteredWorkTask =
                                                                updatedTasks;
                                                            currentPage = 0;
                                                          });
                                                          // ✅ 콜백 실행
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
                                                                  '수정 및 삭제가 완료되었습니다.',
                                                              btnText: '확인',
                                                              fontSize: 16,
                                                            ),
                                                          );
                                                        }
                                                      } else if (deletedTaskIds
                                                          .isNotEmpty) {
                                                        // 수정 없이 삭제만 했을 때도 목록 갱신
                                                        final updatedTasks =
                                                            await WorkTaskController
                                                                .fetchTasks();
                                                        setState(() {
                                                          allWorkTask =
                                                              updatedTasks;
                                                          filteredWorkTask =
                                                              updatedTasks;
                                                          currentPage = 0;
                                                        });
                                                        // ✅ 콜백 실행
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

                                                  // // ✅ 편집 종료 처리
                                                  // setState(() {
                                                  //   isEditing = !isEditing;
                                                  //   if (!isEditing)
                                                  //     editedTasks.clear();
                                                  //   deletedTaskIds
                                                  //       .clear(); // 삭제 ID도 초기화
                                                  // });
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
                                        if (currentSortField ==
                                            'startDate') ...[
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
                                          if (currentSortField ==
                                              'endDate') ...[
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
                                              final globalIndex =
                                                  allWorkTask.indexOf(workTask);
                                              final titleController =
                                                  titleControllers.putIfAbsent(
                                                      workTask.id, () {
                                                return TextEditingController(
                                                  text: editedTasks[workTask.id]
                                                          ?.title ??
                                                      workTask.title,
                                                );
                                              });
                                              final progressController =
                                                  progressControllers
                                                      .putIfAbsent(workTask.id,
                                                          () {
                                                return TextEditingController(
                                                  text:
                                                      (editedTasks[workTask.id]
                                                                  ?.progress ??
                                                              workTask.progress)
                                                          .toString(),
                                                );
                                              });
                                              final startDateController =
                                                  startDateControllers
                                                      .putIfAbsent(workTask.id,
                                                          () {
                                                return TextEditingController(
                                                  text:
                                                      (editedTasks[workTask.id]
                                                                  ?.startDate ??
                                                              workTask
                                                                  .startDate)
                                                          .toString(),
                                                );
                                              });
                                              final endDateController =
                                                  endDateControllers
                                                      .putIfAbsent(workTask.id,
                                                          () {
                                                return TextEditingController(
                                                  text:
                                                      (editedTasks[workTask.id]
                                                                  ?.endDate ??
                                                              workTask.endDate)
                                                          .toString(),
                                                );
                                              });
                                              return Container(
                                                key: ValueKey(workTask.id),
                                                height: 100.h,
                                                // padding: EdgeInsets.symmetric(horizontal: 0.w),
                                                alignment: Alignment.centerLeft,
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 97.w,
                                                    ),
                                                    isEditing
                                                        ? Container(
                                                            width: 359.w,
                                                            color: Colors.white,
                                                            child: TextField(
                                                              controller:
                                                                  titleController,
                                                              onChanged:
                                                                  (value) {
                                                                setState(() {
                                                                  editedTasks[
                                                                      workTask
                                                                          .id] = (editedTasks[workTask
                                                                              .id] ??
                                                                          workTask)
                                                                      .copyWith(
                                                                          title:
                                                                              value);
                                                                });
                                                              },
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'PretendardGOV',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 36.sp,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              decoration:
                                                                  InputDecoration(
                                                                border:
                                                                    InputBorder
                                                                        .none,
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .zero,
                                                              ),
                                                            ))
                                                        : SizedBox(
                                                            width: 359.w,
                                                            child: Text(
                                                                workTask.title,
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'PretendardGOV',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        36.sp,
                                                                    color: Colors
                                                                        .white)),
                                                          ),
                                                    SizedBox(
                                                      width: 255.w,
                                                    ),
                                                    isEditing
                                                        ? Container(
                                                            width: 125.w,
                                                            color: Colors.white,
                                                            child: TextField(
                                                              controller:
                                                                  progressController,
                                                              onChanged:
                                                                  (value) {
                                                                setState(() {
                                                                  final parsed =
                                                                      int.tryParse(
                                                                              value) ??
                                                                          0;
                                                                  editedTasks[
                                                                      index] = (editedTasks[
                                                                              index] ??
                                                                          workTask)
                                                                      .copyWith(
                                                                          progress:
                                                                              parsed);
                                                                });
                                                              },
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'PretendardGOV',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 36.sp,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              decoration:
                                                                  InputDecoration(
                                                                border:
                                                                    InputBorder
                                                                        .none,
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .zero,
                                                              ),
                                                            ))
                                                        : SizedBox(
                                                            width: 125.w,
                                                            child: Text(
                                                                '${workTask.progress.toString()}%',
                                                                textAlign:
                                                                    TextAlign
                                                                        .end,
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'PretendardGOV',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        36.sp,
                                                                    color: Colors
                                                                        .white)),
                                                          ),
                                                    SizedBox(
                                                      width: 305.w,
                                                    ),
                                                    isEditing
                                                        ? Container(
                                                            width: 220.w,
                                                            color: Colors.white,
                                                            child: TextField(
                                                              controller:
                                                                  startDateController,
                                                              onChanged:
                                                                  (value) {
                                                                setState(() {
                                                                  editedTasks[
                                                                      index] = (editedTasks[
                                                                              index] ??
                                                                          workTask)
                                                                      .copyWith(
                                                                          startDate:
                                                                              value);
                                                                });
                                                              },
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'PretendardGOV',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 36.sp,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              decoration:
                                                                  InputDecoration(
                                                                border:
                                                                    InputBorder
                                                                        .none,
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .zero,
                                                              ),
                                                            ),
                                                          )
                                                        : SizedBox(
                                                            width: 220.w,
                                                            child: Text(
                                                                workTask.startDate !=
                                                                        null
                                                                    ? dateFormat.format(DateTime.parse(
                                                                        workTask
                                                                            .startDate!))
                                                                    : '',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'PretendardGOV',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        36.sp,
                                                                    color: Colors
                                                                        .white)),
                                                          ),
                                                    SizedBox(
                                                      width: 220.w,
                                                    ),
                                                    isEditing
                                                        ?
                                                    Expanded(
                                                            child: Row(
                                                              children: [
                                                                Container(
                                                                    width:
                                                                        220.w,
                                                                    color: Colors
                                                                        .white,
                                                                    child:
                                                                        TextField(
                                                                      controller:
                                                                          endDateController,
                                                                      onChanged:
                                                                          (value) {
                                                                        setState(
                                                                            () {
                                                                          editedTasks[index] =
                                                                              (editedTasks[index] ?? workTask).copyWith(endDate: value);
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
                                                                            EdgeInsets.zero,
                                                                      ),
                                                                    )),
                                                                SizedBox(
                                                                  width: 16.w,
                                                                ),
                                                                Container(
                                                                  width: 70.w,
                                                                  height: 70.h,
                                                                  child:
                                                                      InkWell(
                                                                    onTap: () {
                                                                      if (isEditing) {
                                                                        // ✅ 편집 모드일 때만 삭제 작동
                                                                        setState(
                                                                            () {
                                                                          deletedTaskIds
                                                                              .add(workTask.id);
                                                                          editedTasks
                                                                              .remove(workTask.id);

                                                                          // 1. 삭제
                                                                          allWorkTask.removeWhere((task) =>
                                                                              task.id ==
                                                                              workTask.id);
                                                                          filteredWorkTask = allWorkTask
                                                                              .where((task) => task.title.toLowerCase().contains(_searchController.text.toLowerCase()) && matchDateRange(task))
                                                                              .toList();

                                                                          // 2. 페이지 범위 초과 시 페이지 이동
                                                                          if (currentPage * itemsPerPage >= filteredWorkTask.length &&
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
                                                            ),
                                                          )
                                                        : Expanded(
                                                            child: Text(
                                                                workTask.endDate !=
                                                                        null
                                                                    ? dateFormat.format(DateTime.parse(
                                                                        workTask
                                                                            .endDate!))
                                                                    : '',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'PretendardGOV',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        36.sp,
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
                 Visibility(child:    SelectableCalendar(
                   onDateSelected: (start, end) {
                     setState(() {
                       _selectedStartDate = start;
                       _selectedEndDate = end;
                     });
                   },
                 ),visible: !isEditing,)

                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
