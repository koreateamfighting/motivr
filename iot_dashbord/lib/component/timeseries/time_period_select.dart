import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/component/common/dialog_form.dart';
import 'package:iot_dashboard/component/common/dialog_form2.dart';
import 'package:intl/intl.dart';
import 'package:iot_dashboard/utils/selectable_calendar.dart';
import 'package:provider/provider.dart';
import 'package:iot_dashboard/controller/iot_controller.dart';
import 'dart:html' as html; // Flutter Web 전용
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; // kIsWeb

class TimePeriodSelect extends StatefulWidget {
  final void Function(DateTime from, DateTime to)? onQuery;
  final ValueNotifier<Set<String>> selectedDownloadRids; // ✅ 추가
  final List<String> allRids; // ✅ 추가
  const TimePeriodSelect({super.key, this.onQuery, required this.selectedDownloadRids,    required this.allRids, });

  @override
  State<TimePeriodSelect> createState() => _TimePeriodSelectState();
}

class _TimePeriodSelectState extends State<TimePeriodSelect> {
  String selectedPeriod = '';
  DateTime? startDate;
  DateTime? endDate;
  int startHour = 0,
      startMinute = 0,
      endHour = 23,
      endMinute = 59;


  void _setToday() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = now;
    setState(() {
      selectedPeriod = '오늘';
      startDate = todayStart;
      endDate = todayEnd;
    });
    widget.onQuery?.call(todayStart, todayEnd);  // 날짜 범위를 전달
  }

  void _setOneWeek() {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));
    setState(() {
      selectedPeriod = '1주';
      startDate = weekStart;
      endDate = now;
    });
    widget.onQuery?.call(weekStart, now);  // 날짜 범위를 전달
  }

  void _setOneMonth() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 30));
    setState(() {
      selectedPeriod = '1개월';
      startDate = monthStart;
      endDate = now;
    });
    widget.onQuery?.call(monthStart, now);  // 날짜 범위를 전달
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


  DateTime combineDateTime(DateTime date, int hour, int minute) {
    return DateTime(date.year, date.month, date.day, hour, minute);
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

  Widget _toggleSelectAllButton() {
    final isAllSelectedGlobally = widget.selectedDownloadRids.value.contains('ALL');
    return InkWell(
      onTap: () {
        setState(() {
          widget.selectedDownloadRids.value.clear();
          if (!isAllSelectedGlobally) {
            widget.selectedDownloadRids.value.add('ALL');
          }
          widget.selectedDownloadRids.notifyListeners();
        });
      },
      child: Container(
        width: 55.w,
        height: 55.h,
        decoration: BoxDecoration(
          color: isAllSelectedGlobally ? const Color(0xff3182ce) : Colors.transparent,
          borderRadius: BorderRadius.circular(5.r),
          border: Border.all(color: Colors.white, width: 2.w),
        ),
        child: isAllSelectedGlobally ? Icon(Icons.check, color: Colors.white, size: 28.sp) : null,
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    ScreenUtil.ensureScreenSize();
    return Container(
      width: 3680.w,
      height: 100.h,
      decoration: BoxDecoration(
        color: Color(0xff414c67),
        borderRadius: BorderRadius.all(
          Radius.circular(5.r),
        ),
      ),
      child: Row(
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
              onPressed: () {
                if (startDate != null && endDate != null) {
                  final from = DateTime(
                      startDate!.year, startDate!.month, startDate!.day, startHour, startMinute);
                  final to = DateTime(
                      endDate!.year, endDate!.month, endDate!.day, endHour, endMinute);
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
                onPressed: () async {
                  final now = DateTime.now();

                  final effectiveStartDate = startDate ?? DateTime(now.year, now.month, now.day);
                  final effectiveEndDate = endDate ?? now;

                  final from = DateTime(
                    effectiveStartDate.year,
                    effectiveStartDate.month,
                    effectiveStartDate.day,
                    startHour,
                    startMinute,
                  );
                  final to = DateTime(
                    effectiveEndDate.year,
                    effectiveEndDate.month,
                    effectiveEndDate.day,
                    endHour,
                    endMinute,
                  );

                  final selected = widget.selectedDownloadRids.value;
                  Set<String> finalRids;

                  if (selected.contains('ALL')) {
                    final contextRids = context.read<IotController>()
                        .getFilteredDisplacementGroups()
                        .map((g) => g.rid)
                        .toSet();
                    finalRids = contextRids;
                  } else {
                    finalRids = selected;
                  }

                  if (finalRids.isEmpty) {
                    await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const DialogForm(
                        mainText: "선택된 RID가 없습니다.",
                        btnText: "확인",
                      ),
                    );
                    return;
                  }

                  final startStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(from);
                  final endStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(to);
                  final ridsStr = finalRids.join(',');

                  await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => DialogForm2(
                      mainText: "다운로드 하시겠습니까?",
                      btnText1: "취소",
                      btnText2: "확인",
                      onConfirm: () {
                        final encodedRids = Uri.encodeComponent(ridsStr);
                        final encodedStart = Uri.encodeComponent(startStr);
                        final encodedEnd = Uri.encodeComponent(endStr);

                        final downloadUrl =
                            'https://hanlimtwin.kr:3030/api/download-excel?startDate=$encodedStart&endDate=$encodedEnd&rids=$encodedRids';

                        debugPrint('📁 다운로드 URL: $downloadUrl');

                        if (kIsWeb) {
                          html.AnchorElement(href: downloadUrl)
                            ..setAttribute("download", "")
                            ..target = 'blank'
                            ..click();
                        } else {
                          debugPrint("❌ 현재 플랫폼에서는 다운로드를 지원하지 않습니다.");
                        }
                      },
                    ),
                  );
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
      ),
    );
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

  Widget _dateBox(DateTime? date) {
    return Container(
      width: 288.w,
      height: 60.h,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5.r)),
      alignment: Alignment.center,
      child: Text(
        date == null ? '' : DateFormat('yyyy-MM-dd').format(date),
        style: TextStyle(fontSize: 32.sp),
      ),
    );
  }
  Widget _timeField(String type) {
    return Container(
      width: 80.w,
      height: 60.h,
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5.r)),
      alignment: Alignment.center,
      child: Text(
        type == 'startHour'
            ? startHour.toString().padLeft(2, '0')
            : type == 'startMinute'
            ? startMinute.toString().padLeft(2, '0')
            : type == 'endHour'
            ? endHour.toString().padLeft(2, '0')
            : endMinute.toString().padLeft(2, '0'),
        style: TextStyle(fontSize: 28.sp, color: Colors.black),
      ),
    );
  }

}