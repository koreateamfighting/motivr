import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:iot_dashboard/utils/selectable_calendar2.dart';

class DatePickerField extends StatefulWidget {
  final String label;
  final DateTime? initialDate;
  final void Function(DateTime) onDateSelected;

  const DatePickerField({
    Key? key,
    required this.label,
    this.initialDate,
    required this.onDateSelected,
    thi
  }) : super(key: key);

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
  }

  Future<void> _pickDate() async {
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: SelectableCalendar(), // ✅ 더 이상 콜백 필요 없음
      ),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
      widget.onDateSelected(picked);
    }
  }

  void _selectToday() {
    final today = DateTime.now();
    setState(() {
      selectedDate = today;
    });
    widget.onDateSelected(today);
  }

  @override
  Widget build(BuildContext context) {
    String displayText = selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(selectedDate!)
        : 'YYYY-MM-DD';

    return Container(
        height: 75.h,
        child: Row(
          children: [
            SizedBox(width: 41.w),
            Container(
              width: 400.w,
              height: 60.h,
              alignment: Alignment.centerLeft,
              child: Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'PretendardGOV',
                  fontSize: 36.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Container(
              width: 420.w,
              height: 60.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    displayText,
                    style: TextStyle(
                      fontSize: 36.sp,
                      fontFamily: 'PretendardGOV',
                      fontWeight: FontWeight.w300,
                      color: selectedDate == null
                          ? Color(0xffD0D0D0)
                          : Colors.black,
                    ),
                  ),
                  InkWell(
                    onTap: _pickDate,
                    child: Icon(Icons.calendar_today,
                        size: 28.sp, color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            InkWell(
              onTap: _selectToday,
              child: Container(
                width: 100.85.w,
                height: 60.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color(0xff3182ce),
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: Text(
                  '오늘',
                  style: TextStyle(
                    fontSize: 30.sp,
                    fontFamily: 'PretendardGOV',
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
