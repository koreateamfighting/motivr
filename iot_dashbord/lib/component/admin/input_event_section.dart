import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/component/admin/datepicker_field.dart';
import 'package:iot_dashboard/component/admin/image_picker_text_field.dart';
import 'package:iot_dashboard/component/admin/labeled_textfield_section.dart';
import 'package:iot_dashboard/component/admin/action_button.dart';
import 'package:iot_dashboard/component/admin/section_title.dart';
import 'package:iot_dashboard/component/admin/time_picker_row.dart';
import 'package:iot_dashboard/component/admin/custom_divider.dart';
import 'package:iot_dashboard/component/common/dialog_form.dart';

class EventInputSection extends StatefulWidget {
  final TextEditingController? iotHistoryProductIDController;
  final TextEditingController? iotHistoryLocationController;
  final TextEditingController? iotHistoryEventController;
  final String? iotHistoryDate;
  final String? iotHistoryHour;
  final String? iotHistoryMinute;
  final String? iotHistorySecond;
  final TextEditingController? iotHistoryLogController;
  final TextEditingController? cctvHistoryProductIDController;
  final TextEditingController? cctvHistoryLocationController;
  final TextEditingController? cctvHistoryEventController;
  final String? cctvHistoryDate;
  final String? cctvHistoryHour;
  final String? cctvHistoryMinute;
  final String? cctvHistorySecond;
  final TextEditingController? cctvHistoryLogController;

  const EventInputSection({
    Key? key,
    this.iotHistoryProductIDController,
    this.iotHistoryLocationController,
    this.iotHistoryEventController,
    this.iotHistoryDate,
    this.iotHistoryHour,
    this.iotHistoryMinute,
    this.iotHistorySecond,
    this.iotHistoryLogController,
    this.cctvHistoryProductIDController,
    this.cctvHistoryLocationController,
    this.cctvHistoryEventController,
    this.cctvHistoryDate,
    this.cctvHistoryHour,
    this.cctvHistoryMinute,
    this.cctvHistorySecond,
    this.cctvHistoryLogController,
  }) : super(key: key);

  @override
  State<EventInputSection> createState() => _EventInputSectionState();
}

class _EventInputSectionState extends State<EventInputSection> {
  bool isExpanded = false; // ✅ 펼침 여부 상태

  late TextEditingController iotHistoryProductIDController;
  late TextEditingController iotHistoryLocationController;
  late TextEditingController iotHistoryEventController;
  late String? iotHistoryDate;
  late String? iotHistoryHour;
  late String? iotHistoryMinute;
  late String? iotHistorySecond;
  late TextEditingController iotHistoryLogController;
  late TextEditingController cctvHistoryProductIDController;
  late TextEditingController cctvHistoryLocationController;
  late TextEditingController cctvHistoryEventController;
  late String? cctvHistoryDate;
  late String? cctvHistoryHour;
  late String? cctvHistoryMinute;
  late String? cctvHistorySecond;
  late TextEditingController cctvHistoryLogController;

  @override
  void initState() {
    super.initState();

    iotHistoryProductIDController =
        widget.iotHistoryProductIDController ?? TextEditingController();
    iotHistoryLocationController =
        widget.iotHistoryLocationController ?? TextEditingController();
    iotHistoryEventController =
        widget.iotHistoryEventController ?? TextEditingController();
    iotHistoryLogController =
        widget.iotHistoryLogController ?? TextEditingController();

    cctvHistoryProductIDController =
        widget.cctvHistoryProductIDController ?? TextEditingController();
    cctvHistoryLocationController =
        widget.cctvHistoryLocationController ?? TextEditingController();
    cctvHistoryEventController =
        widget.cctvHistoryEventController ?? TextEditingController();
    cctvHistoryLogController =
        widget.cctvHistoryLogController ?? TextEditingController();
    iotHistoryDate = widget.iotHistoryDate;
    iotHistoryHour = widget.iotHistoryHour;
    iotHistoryMinute = widget.iotHistoryMinute;
    iotHistorySecond = widget.iotHistorySecond;
    cctvHistoryDate = widget.cctvHistoryDate;
    cctvHistoryHour = widget.cctvHistoryHour;
    cctvHistoryMinute = widget.cctvHistoryMinute;
    cctvHistorySecond = widget.cctvHistorySecond;
  }
  DateTime? _composeTimestamp(String? dateStr, String? hour, String? minute, String? second) {
    final date = DateTime.tryParse(dateStr ?? '');
    if (date == null) return null;
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.tryParse(hour ?? '00') ?? 0,
      int.tryParse(minute ?? '00') ?? 0,
      int.tryParse(second ?? '00') ?? 0,
    );
  }

  // void _submitIotHistory() async {
  //   final timestamp = _composeTimestamp(iotHistoryDate, iotHistoryHour, iotHistoryMinute, iotHistorySecond);
  //   if (timestamp == null) return;
  //   final success = await EventController.submitIotHistory(
  //     timestamp: timestamp,
  //     productId: iotHistoryProductIDController.text.trim(),
  //     location: iotHistoryLocationController.text.trim(),
  //     event: iotHistoryEventController.text.trim(),
  //     log: iotHistoryLogController.text.trim(),
  //   );
  //   if (success) {
  //     showDialog(
  //       context: context,
  //       builder: (_) => const DialogForm(mainText: 'IOT 이벤트가 등록되었습니다.', btnText: '확인'),
  //     );
  //   }
  // }

  // void _submitCctvHistory() async {
  //   final timestamp = _composeTimestamp(cctvHistoryDate, cctvHistoryHour, cctvHistoryMinute, cctvHistorySecond);
  //   if (timestamp == null) return;
  //   final success = await EventController.submitCctvHistory(
  //     timestamp: timestamp,
  //     productId: cctvHistoryProductIDController.text.trim(),
  //     location: cctvHistoryLocationController.text.trim(),
  //     event: cctvHistoryEventController.text.trim(),
  //     log: cctvHistoryLogController.text.trim(),
  //   );
  //   if (success) {
  //     showDialog(
  //       context: context,
  //       builder: (_) => const DialogForm(mainText: 'CCTV 이벤트가 등록되었습니다.', btnText: '확인'),
  //     );
  //   }
  // }
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
                '이벤트 관리(준비중)',
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
                  width: isExpanded?40.w:50.w,
                  height: isExpanded?20.h:30.h,
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
            height: 1046.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.r),
              color: const Color(0xff414c67),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    alignment: Alignment.centerLeft,
                    color: Color(0xffe7eaf4),
                    child: Text(
                      'IoT 알람 히스토리',
                      style: TextStyle(
                          fontFamily: 'PretendardGOV',
                          fontWeight: FontWeight.w400,
                          fontSize: 32.sp,
                          color: Color(0xff414c67)),
                    )),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '제품 식별자(ID) :',
                    hint: 'S1_001',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: iotHistoryProductIDController,
                  ),
                ),
           CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '설치 위치(추진구/도달구) :',
                    hint: '추진구',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: iotHistoryLocationController,
                  ),
                ),
           CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '이벤트 :',
                    hint: '정상',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: iotHistoryEventController,
                  ),
                ),
           CustomDivider(),
                Row(
                  children: [
                    DatePickerField(
                      label: '날짜/시간 :',
                      initialDate: DateTime.tryParse(iotHistoryDate ?? ''),
                      onDateSelected: (date) {},
                    ),
                    SizedBox(
                      width: 43.15.w,
                    ),
                    TimePickerRow(
                      selectedHour: iotHistoryHour,
                      selectedMinute: iotHistoryMinute,
                      selectedSecond: iotHistorySecond,
                      onHourChanged: (val) => setState(() => iotHistoryHour = val),
                      onMinuteChanged: (val) => setState(() => iotHistoryMinute = val),
                      onSecondChanged: (val) => setState(() => iotHistorySecond = val),
                    ),
                  ],

                ),
           CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '로그 :',
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: iotHistoryLogController,
                  ),
                ),
                SizedBox(height: 5.h),
                Container(
                  color: Color(0xffe7eaf4),
                  child:   Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ActionButton('추가', Color(0xffe98800)),
                    ],
                  ),
                ),

                Container(
                    alignment: Alignment.centerLeft,
                    color: Color(0xffe7eaf4),
                    child: Text(
                      'CCTV 알람 히스토리',
                      style: TextStyle(
                          fontFamily: 'PretendardGOV',
                          fontWeight: FontWeight.w400,
                          fontSize: 32.sp,
                          color: Color(0xff414c67)),
                    )),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '제품 식별자(ID) :',
                    hint: 'S1_001',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: cctvHistoryProductIDController,
                  ),
                ),
           CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '설치 위치(추진구/도달구) :',
                    hint: '추진구',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: cctvHistoryLocationController,
                  ),
                ),
           CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '이벤트 :',
                    hint: '정상',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: cctvHistoryEventController,
                  ),
                ),
           CustomDivider(),
                Row(
                  children: [
                    DatePickerField(
                      label: '날짜/시간 :',
                      initialDate: DateTime.tryParse(cctvHistoryDate ?? ''),
                      onDateSelected: (date) {},
                    ),
                    SizedBox(
                      width: 43.15.w,
                    ),
                    TimePickerRow(
                      selectedHour: cctvHistoryHour,
                      selectedMinute: cctvHistoryMinute,
                      selectedSecond: cctvHistorySecond,
                      onHourChanged: (val) => setState(() => cctvHistoryHour = val),
                      onMinuteChanged: (val) => setState(() => cctvHistoryMinute = val),
                      onSecondChanged: (val) => setState(() => cctvHistorySecond = val),
                    ),
                  ],

                ),
           CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '로그 :',
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: cctvHistoryLogController,
                  ),
                ),

              ],
            ),
          ),
          SizedBox(height: 5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ActionButton('추가', Color(0xffe98800)),
              SizedBox(width: 400.w),
            ],
          ),
          SizedBox(height: 5.h),
        ],
      ],
    );
  }
}
