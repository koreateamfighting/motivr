import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/component/common/dialog_form.dart';
import 'package:iot_dashboard/component/common/dialog_form2.dart';
import 'package:intl/intl.dart';
import 'package:iot_dashboard/constants/global_constants.dart';
import 'package:iot_dashboard/controller/alarm_history_controller.dart';
import 'package:iot_dashboard/utils/selectable_calendar.dart';
import 'package:provider/provider.dart';
import 'package:iot_dashboard/controller/cctv_controller.dart';
import 'dart:html' as html; // Flutter Web 전용
import 'package:flutter/foundation.dart';
import 'package:iot_dashboard/utils/auth_service.dart';

class CCTVTimePeriodSelect extends StatefulWidget {
  final void Function(DateTime from, DateTime to)? onQuery;
  final ValueNotifier<Set<String>> selectedDownloadDevices;
  final List<String> allDevices;

  const CCTVTimePeriodSelect({
    super.key,
    this.onQuery,
    required this.selectedDownloadDevices,
    required this.allDevices,
  });

  @override
  State<CCTVTimePeriodSelect> createState() => _CCTVTimePeriodSelectState();
}

class _CCTVTimePeriodSelectState extends State<CCTVTimePeriodSelect> {
  String selectedPeriod = '';
  DateTime? startDate;
  DateTime? endDate;
  int startHour = 0, startMinute = 0, endHour = 23, endMinute = 59;
  bool isAllSelectedGlobally = false;
  @override
  void initState() {
    super.initState();
    widget.selectedDownloadDevices.addListener(_updateGlobalSelectionState);
    _updateGlobalSelectionState();
  }

  @override
  void dispose() {
    widget.selectedDownloadDevices.removeListener(_updateGlobalSelectionState);
    super.dispose();
  }
  void _updateGlobalSelectionState() {
    setState(() {
      isAllSelectedGlobally =
          widget.selectedDownloadDevices.value.length == widget.allDevices.length;
    });
  }

  void applyPreset(String type) {
    final now = DateTime.now();
    setState(() {
      selectedPeriod = type;
      startHour = 0;
      startMinute = 0;
      endHour = 23;
      endMinute = 59;

      if (type == '오늘') {
        startDate = DateTime(now.year, now.month, now.day);
        endDate = now;
      } else if (type == '1주') {
        startDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: 7));
        endDate = now;
      } else if (type == '1개월') {
        startDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: 30));
        endDate = now;
      }
    });
  }
  Widget _periodButton(String label) {
    final bool selected = selectedPeriod == label;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: InkWell(
        onTap: () => applyPreset(label),
        child: Container(
          width: 106.98.w,
          height: 60.h,
          decoration: BoxDecoration(
            color: selected ? Color(0xff3182ce) : Color(0xff414c67),
            border: Border.all(color: Color(0xff3182ce), width: 1.w),
            borderRadius: BorderRadius.circular(5.r),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 32.sp,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
  Widget _timeDropdown(int value, void Function(int?) onChanged, List<int> range) {
    return Container(
      width: 80.w,
      height: 60.h,
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.r),
        border: Border.all(color: Color(0xff3182ce), width: 1.w),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, size: 28.sp, color: Colors.black),
          style: TextStyle(fontSize: 24.sp, color: Colors.black),
          items: range
              .map((v) => DropdownMenuItem(
            value: v,
            child: Center(child: Text(v.toString().padLeft(2, '0'))),
          ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _toggleSelectAllButton() {
    final isAllSelected = widget.selectedDownloadDevices.value.contains('ALL');

    return InkWell(
      onTap: () {
        setState(() {
          widget.selectedDownloadDevices.value.clear();

          if (!isAllSelected) {
            widget.selectedDownloadDevices.value.add('ALL'); // ✅ ALL만 넣기
          }

          // ✅ 강제로 리렌더링 유도
          widget.selectedDownloadDevices.notifyListeners();

          debugPrint('🧪 [toggleSelectAll] selectedDownloadDevices: ${widget.selectedDownloadDevices.value}');
        });
      },
      child: Container(
        width: 55.w,
        height: 55.h,
        decoration: BoxDecoration(
          color: isAllSelected ? const Color(0xff3182ce) : Colors.transparent,
          borderRadius: BorderRadius.circular(5.r),
          border: Border.all(color: Colors.white, width: 2.w),
        ),
        child: isAllSelected
            ? Icon(Icons.check, color: Colors.white, size: 28.sp)
            : null,
      ),
    );
  }
  Future<void> openCalendarDialog() async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: SelectableCalendar(
          autoClose: true, // ✅ 여기서 자동종료 여부 설정
          onDateSelected: (start, end) {
            if (start != null) startDate = start;
            if (end != null) endDate = end;
            setState(() {

            });
          },
        ),
      ),
    );
  }


  Future<void> _downloadExcel() async {
    final isAuthorized = AuthService.isRoot() || AuthService.isStaff();
    if (!isAuthorized) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const DialogForm(mainText: '권한이 없습니다.', btnText: '확인'),
      );
      return;
    }

    final now = DateTime.now();
    final effectiveStartDate = startDate ?? DateTime(now.year, now.month, now.day);
    final effectiveEndDate = endDate ?? now;
    final from = DateTime(effectiveStartDate.year, effectiveStartDate.month, effectiveStartDate.day, startHour, startMinute);
    final to = DateTime(effectiveEndDate.year, effectiveEndDate.month, effectiveEndDate.day, endHour, endMinute);

    final selected = widget.selectedDownloadDevices.value;
    Set<String> finalDeviceIds;
    debugPrint('🧪 선택된 장치들: $selected');



    if (selected.contains('ALL')) {
      finalDeviceIds = context.read<CctvController>().getAllDeviceIds().toSet();
    } else {
      finalDeviceIds = selected;
    }

    if (finalDeviceIds.isEmpty) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const DialogForm(mainText: "선택된 장치가 없습니다.", btnText: "확인"),
      );
      return;
    }

    final startStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(from);
    final endStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(to);
    final deviceStr = finalDeviceIds.join(',');

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => DialogForm2(
        mainText: "다운로드 하시겠습니까?",
        btnText1: "취소",
        btnText2: "확인",
        onConfirm: () async {
          await AlarmHistoryController.downloadCctvLogExcelByPeriod(
            camIds: finalDeviceIds.toList(),
            startDate: from,
            endDate: to,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 생략된 UI 부분은 그대로 유지
    return Row(
      children: [
        SizedBox(
          width: 24.w,
        ),
        Container(
          width: 50.w,
          height: 50.h,
          child: Image.asset('assets/icons/calendar.png'),
        ),
        SizedBox(
          width: 11.w,
        ),
        Container(
          width: 141.w,
          height: 50.h,
          child: Text(
            '기간 선택',
            style: TextStyle(
              fontFamily: 'PretendardGOV',
              fontWeight: FontWeight.w700,
              fontSize: 36.sp,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          width: 6.w,
        ),
        _periodButton('오늘'),
        SizedBox(
          width: 9.9.w,
        ),
        _periodButton('1주'),
        SizedBox(
          width: 9.9.w,
        ),
        _periodButton('1개월'),
        SizedBox(
          width: 15.w,
        ),
        InkWell(
          onTap: openCalendarDialog,
          child: Container(
            width: 288.w * 2 + 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: Color(0xff414c67),
              border: Border.all(color: Color(0xff3182ce), width: 1.w),
              borderRadius: BorderRadius.circular(5.r),
            ),
            alignment: Alignment.center,
            child: Text(
              startDate != null && endDate != null
                  ? '${DateFormat('yyyy-MM-dd').format(startDate!)} ~ ${DateFormat('yyyy-MM-dd').format(endDate!)}'
                  : '날짜 수동 선택',
              style: TextStyle(fontSize: 32.sp, color: Colors.white),
            ),
          ),
        ),
        SizedBox(
          width: 54.w,
        ),
        Container(
          width: 50.w,
          height: 50.h,
          child: Image.asset('assets/icons/clock.png'),
        ),
        SizedBox(
          width: 14.w,
        ),
        Container(
          width: 141.w,
          height: 50.h,
          child: Text(
            '시간 선택',
            style: TextStyle(
              fontFamily: 'PretendardGOV',
              fontWeight: FontWeight.w700,
              fontSize: 36.sp,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          width: 17.w,
        ),
        Container(
          width: 80.w,
          height: 60.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.r),
          ),
          child: _timeDropdown(startHour, (val) {
            if (val != null) setState(() => startHour = val);
          }, List.generate(24, (i) => i)), // 시 0~23
        ),
        SizedBox(
          width: 8.w,
        ),
        Text(
          ':',
          style: TextStyle(
            fontFamily: 'PretendardGOV',
            fontWeight: FontWeight.w700,
            fontSize: 36.sp,
            color: Colors.white,
          ),
        ),
        SizedBox(
          width: 8.w,
        ),
        Container(
          width: 80.w,
          height: 60.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.r),
          ),
          child:  _timeDropdown(startMinute, (val) {
            if (val != null) setState(() => startMinute = val);
          }, List.generate(60, (i) => i)), // 분 0~59

        ),
        SizedBox(
          width: 15.w,
        ),
        Text(
          '~',
          style: TextStyle(
            fontFamily: 'PretendardGOV',
            fontWeight: FontWeight.w700,
            fontSize: 36.sp,
            color: Colors.white,
          ),
        ),
        SizedBox(
          width: 15.w,
        ),
        Container(
          width: 80.w,
          height: 60.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.r),
          ),
          child:     _timeDropdown(endHour, (val) {
            if (val != null) setState(() => endHour = val);
          }, List.generate(24, (i) => i)),
        ),
        SizedBox(
          width: 8.w,
        ),
        Text(
          ':',
          style: TextStyle(
            fontFamily: 'PretendardGOV',
            fontWeight: FontWeight.w700,
            fontSize: 36.sp,
            color: Colors.white,
          ),
        ),
        SizedBox(
          width: 8.w,
        ),
        Container(
          width: 80.w,
          height: 60.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.r),
          ),
          child: _timeDropdown(endMinute, (val) {
            if (val != null) setState(() => endMinute = val);
          }, List.generate(60, (i) => i)),
        ),
        SizedBox(
          width: 95.w,
        ),
        Container(
          width: 100.w,
          height: 60.h,
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: () async {
              if (startDate != null && endDate != null) {
                final from = DateTime(startDate!.year, startDate!.month, startDate!.day, startHour, startMinute);
                final to   = DateTime(endDate!.year, endDate!.month, endDate!.day, endHour, endMinute);

                if (from.isAfter(to)) {
                  await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const DialogForm(mainText: '시작 시간이 종료 시간보다 늦습니다.', btnText: '확인'),
                  );
                  return;
                }
                widget.onQuery?.call(from, to);
              }
            },

            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff3182ce),
              // 파란색
              padding: EdgeInsets.symmetric(
                  horizontal: 20.w, vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
            ),
            child: Text(
              '조회',
              style: TextStyle(
                fontSize: 32.sp,
                fontFamily: 'PretendardGOV',
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 1180.w,
        ),
        Container(
          width: 230.w,
          height: 60.h,
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: _downloadExcel, // ✅ 함수 호출로 대체


            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff3182ce),
              // 파란색
              padding: EdgeInsets.symmetric(
                  horizontal: 20.w, vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
            ),
            child: Text(
              '다운로드',
              style: TextStyle(
                fontSize: 32.sp,
                fontFamily: 'PretendardGOV',
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 30.w,
        ),
        _toggleSelectAllButton(),
      ],
    );
  }
}