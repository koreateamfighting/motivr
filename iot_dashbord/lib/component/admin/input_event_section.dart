import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/component/admin/datepicker_field.dart';
import 'package:iot_dashboard/component/admin/image_picker_text_field.dart';
import 'package:iot_dashboard/component/admin/labeled_textfield_section.dart';
import 'package:iot_dashboard/component/admin/action_button.dart';
import 'package:iot_dashboard/component/admin/section_title.dart';
import 'package:iot_dashboard/component/admin/time_picker_row.dart';
import 'package:iot_dashboard/component/admin/custom_divider.dart';
class EventInputSection extends StatefulWidget {
  final TextEditingController? iotHistoryProductIDController;
  final TextEditingController? iotHistoryLocationController;
  final TextEditingController? iotHistoryEventController;
  final String? iotHistoryDate;
  final String? iotHistoryHour;
  final String? iotHistoryMinute;
  final TextEditingController? iotHistoryLogController;
  final TextEditingController? cctvHistoryProductIDController;
  final TextEditingController? cctvHistoryLocationController;
  final TextEditingController? cctvHistoryEventController;
  final String? cctvHistoryDate;
  final String? cctvHistoryHour;
  final String? cctvHistoryMinute;
  final TextEditingController? cctvHistoryLogController;

  const EventInputSection({
    Key? key,
    this.iotHistoryProductIDController,
    this.iotHistoryLocationController,
    this.iotHistoryEventController,
    this.iotHistoryDate,
    this.iotHistoryHour,
    this.iotHistoryMinute,
    this.iotHistoryLogController,
    this.cctvHistoryProductIDController,
    this.cctvHistoryLocationController,
    this.cctvHistoryEventController,
    this.cctvHistoryDate,
    this.cctvHistoryHour,
    this.cctvHistoryMinute,
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
  late TextEditingController iotHistoryLogController;
  late TextEditingController cctvHistoryProductIDController;
  late TextEditingController cctvHistoryLocationController;
  late TextEditingController cctvHistoryEventController;
  late String? cctvHistoryDate;
  late String? cctvHistoryHour;
  late String? cctvHistoryMinute;
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
    cctvHistoryDate = widget.cctvHistoryDate;
    cctvHistoryHour = widget.cctvHistoryHour;
    cctvHistoryMinute = widget.cctvHistoryMinute;
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
                      onHourChanged: (val) => setState(() => iotHistoryHour = val),
                      onMinuteChanged: (val) => setState(() => iotHistoryMinute = val),
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
                      onHourChanged: (val) => setState(() => cctvHistoryHour = val),
                      onMinuteChanged: (val) => setState(() => cctvHistoryMinute = val),
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
