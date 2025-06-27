import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/component/admin/datepicker_field.dart';
import 'package:iot_dashboard/component/admin/image_picker_text_field.dart';
import 'package:iot_dashboard/component/admin/labeled_textfield_section.dart';
import 'package:iot_dashboard/component/admin/action_button.dart';
import 'package:iot_dashboard/component/admin/section_title.dart';
import 'package:iot_dashboard/component/admin/time_picker_row.dart';
import 'package:iot_dashboard/component/admin/custom_divider.dart';
import 'package:iot_dashboard/component/admin/labeled_dropdown_field.dart';
import 'package:iot_dashboard/controller/alarm_controller.dart';
import 'package:iot_dashboard/component/common/dialog_form.dart';

class EventAlarmSection extends StatefulWidget {
  final String? alarmDate;
  final String? alarmHour;
  final String? alarmMinute;
  final String? alarmSecond;
  final TextEditingController? alarmMessageController;

  const EventAlarmSection(
      {Key? key,
      this.alarmDate,
      this.alarmHour,
      this.alarmMinute,
      this.alarmSecond,
      this.alarmMessageController})
      : super(key: key);

  @override
  State<EventAlarmSection> createState() => _EventAlarmSectionState();
}

class _EventAlarmSectionState extends State<EventAlarmSection> {
  bool isExpanded = false; // ✅ 펼침 여부 상태

  late TextEditingController _messageController;
  late TextEditingController _alarmTypeController;
  late String? alarmHour;
  late String? alarmMinute;
  late String? alarmSecond;
  DateTime? _selectedDate;
  String? _selectedAlarmType = '정보'; // ✅ 기본값

  @override
  void initState() {
    super.initState();
    _messageController =
        widget.alarmMessageController ?? TextEditingController();
    _selectedDate = DateTime.tryParse(widget.alarmDate ?? '');

    // ⚠️ 이 두 줄이 꼭 필요합니다!
    alarmHour = widget.alarmHour ?? '00';
    alarmMinute = widget.alarmMinute ?? '00';
    alarmSecond = widget.alarmSecond ?? '00';
  }
  bool get isFormValid {
    return _selectedDate != null &&
        alarmHour != null &&
        alarmMinute != null &&
        _selectedAlarmType != null &&
        _selectedAlarmType!.trim().isNotEmpty &&
        _messageController.text.trim().isNotEmpty;
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ✅ 헤더 클릭 시 펼침/접힘 전환
        Container(
          width: 2880.w,
          height: 70.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.r),
            color: const Color(0xff414c67),
          ),
          child: Row(
            children: [
              SizedBox(width: 41.w),
              Text(
                '최근 알람 / 이벤트',
                style: TextStyle(
                  fontFamily: 'PretendardGOV',
                  fontSize: 36.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Image.asset(
                  isExpanded
                      ? 'assets/icons/arrow_down.png'
                      : 'assets/icons/arrow_right2.png',
                  width: isExpanded ? 40.w : 50.w,
                  height: isExpanded ? 20.h : 30.h,
                ),
              ),
              SizedBox(width: 55.w),
            ],
          ),
        ),

        // ✅ 본문 영역 (isExpanded에 따라 표시/숨김)
        if (isExpanded) ...[
          SizedBox(height: 5.h),
          Container(
            width: 2880.w,
            height: 365.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.r),
              color: const Color(0xff414c67),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DatePickerField(
                  label: '날짜  :',
                  initialDate: DateTime.tryParse(widget.alarmDate ?? ''),
                  onDateSelected: (date) => setState(() => _selectedDate = date),
                ),
                CustomDivider(),
                Container(
                  width: 2880.w,
                  height: 85.h,
                  child: TimePickerRow(
                    label: '시간 :',
                    selectedHour: alarmHour,
                    selectedMinute: alarmMinute,
                    selectedSecond: alarmSecond,
                    onHourChanged: (val) => setState(() => alarmHour = val),
                    onMinuteChanged: (val) => setState(() => alarmMinute = val),
                      onSecondChanged: (val) => setState(() => alarmSecond = val)
                  ),
                ),
                CustomDivider(),
                Container(
                  width: 2880.w,
                  height: 85.h,
                  child: LabeledDropdownField(
                    title: '유형 :',
                    items: ['정보', '주의', '경고', '점검'],
                    selectedValue: _selectedAlarmType,
                    onChanged: (val) => setState(() {
                      _selectedAlarmType = val;
                    }),
                  ),
                ),
                CustomDivider(),
                Container(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '메세지 :',
                    hint: '예: 오늘 오후 3시 레미콘 차량 진입 예정',
                    width: 1260,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: _messageController,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
          ),
        ],
        SizedBox(height: 5.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ActionButton(
              '추가',
              isFormValid ? const Color(0xffe98800) : Colors.grey,
              onTap: isFormValid
                  ? () async {
                final timestamp = DateTime(
                  _selectedDate!.year,
                  _selectedDate!.month,
                  _selectedDate!.day,
                  int.tryParse(alarmHour!) ?? 0,
                  int.tryParse(alarmMinute!) ?? 0,
                  int.tryParse(alarmSecond!) ?? 0, // ✅ 초 반영
                );


                final success = await AlarmController.addAlarm(
                        timestamp: timestamp,
                        level: _selectedAlarmType!,
                        message: _messageController.text.trim(),
                      );

                      if (success) {
                        showDialog(
                          context: context,
                          builder: (_) => const DialogForm(
                            mainText: '알람이 등록되었습니다.',
                            btnText: '확인',
                            fontSize: 20,
                          ),
                        );

                        setState(() {
                          _messageController.clear();
                          _selectedDate = null;
                          alarmHour = '00';
                          alarmMinute = '00';
                          _selectedAlarmType = '정보';
                        });
                      }

              }
                  : null,
            ),
            SizedBox(width: 400.w),
          ],
        ),
        SizedBox(height: 5.h),
      ],
    );
  }
}
