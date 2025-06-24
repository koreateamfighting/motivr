import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
class TimePickerRow extends StatelessWidget {
  final String? label;
  final String? selectedHour;
  final String? selectedMinute;
  final void Function(String?) onHourChanged;
  final void Function(String?) onMinuteChanged;

  const TimePickerRow({
    Key? key,
    this.label,
    this.selectedHour,
    this.selectedMinute,
    required this.onHourChanged,
    required this.onMinuteChanged,
  }) : super(key: key);

  List<String> _generateNumberList(int max) {
    return List<String>.generate(max + 1, (index) => index.toString().padLeft(2, '0'));
  }

  @override
  Widget build(BuildContext context) {
    final hourList = _generateNumberList(23);
    final minuteList = _generateNumberList(59);

    return Row(
      children: [
        if (label != null) ...[
          SizedBox(width: 41.w),
          Container(
            width: 400.w,
            height: 50.h,
            alignment: Alignment.centerLeft,
            child: Text(
              label!,
              style: TextStyle(
                fontFamily: 'PretendardGOV',
                fontSize: 36.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 12.w),
        ],

        // ⏰ Hour dropdown
        DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            value: hourList.contains(selectedHour) ? selectedHour : '00',
            buttonStyleData: ButtonStyleData(
              height: 60.h,
              width: 100.w,
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 240.h,
            ),
            menuItemStyleData: MenuItemStyleData(
              height: 50.h,
            ),
            iconStyleData: IconStyleData(
              iconSize: 24.sp,
            ),
            items: hourList.map((hour) {
              return DropdownMenuItem<String>(
                value: hour,
                child: Text(
                  hour,
                  style: TextStyle(fontSize: 28.sp, fontFamily: 'PretendardGOV'),
                ),
              );
            }).toList(),
            onChanged: onHourChanged,
          ),
        ),


        SizedBox(width: 12.w),
        Text(':', style: TextStyle(fontSize: 36.sp, color: Colors.white)),
        SizedBox(width: 12.w),
        DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            value: minuteList.contains(selectedMinute) ? selectedMinute : '00',
            buttonStyleData: ButtonStyleData(
              height: 60.h,
              width: 100.w,
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 240.h,
            ),
            menuItemStyleData: MenuItemStyleData(
              height: 50.h,
            ),
            iconStyleData: IconStyleData(
              iconSize: 24.sp,
            ),
            items: minuteList.map((min) {
              return DropdownMenuItem<String>(
                value: min,
                child: Container(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      min,
                      style: TextStyle(fontSize: 28.sp, fontFamily: 'PretendardGOV'),
                    ),
                  ),
                ),
              );
            }).toList(),

            onChanged: onMinuteChanged,
          ),
        ),
        SizedBox(width: 18.w),
        Container(
          width: 40.w,
          height: 40.h,
          child: Image.asset('assets/icons/clock.png'),
        ),
      ],
    );
  }
}
