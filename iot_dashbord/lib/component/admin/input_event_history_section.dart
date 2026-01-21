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
import 'package:iot_dashboard/component/common/dialog_form.dart';
import 'package:iot_dashboard/model/alarm_history_model.dart';
import 'package:iot_dashboard/controller/alarm_history_controller.dart';

import 'package:intl/intl.dart';

class EventInputSection extends StatefulWidget {
  final TextEditingController? iotHistoryProductIDController;
  final TextEditingController? iotHistoryProductLabelController;
  final TextEditingController? iotHistoryLatitudeController;
  final TextEditingController? iotHistoryLongitudeController;

  final String? iotHistoryDate;
  final String? iotHistoryHour;
  final String? iotHistoryMinute;
  final String? iotHistorySecond;
  final TextEditingController? iotHistoryLogController;
  final TextEditingController? cctvHistoryProductIDController;

  final String? cctvHistoryDate;
  final String? cctvHistoryHour;
  final String? cctvHistoryMinute;
  final String? cctvHistorySecond;
  final TextEditingController? cctvHistoryLogController;

  const EventInputSection({
    Key? key,
    this.iotHistoryProductIDController,
    this.iotHistoryProductLabelController,
    this.iotHistoryLatitudeController,
    this.iotHistoryLongitudeController,
    this.iotHistoryDate,
    this.iotHistoryHour,
    this.iotHistoryMinute,
    this.iotHistorySecond,
    this.iotHistoryLogController,
    this.cctvHistoryProductIDController,
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
  bool isIotDeviceIdEmpty = true;
  bool isIotLabelEmpty = true;
  bool isCctvDeviceIdEmpty = true;

  late TextEditingController iotHistoryProductIDController;
  late TextEditingController iotHistoryProductLabelController;
  late TextEditingController iotHistoryLatitudeController;
  late TextEditingController iotHistoryLongitudeController;

  late String? iotHistoryDate;
  late String? iotHistoryHour;
  late String? iotHistoryMinute;
  late String? iotHistorySecond;
  late TextEditingController iotHistoryLogController;
  late TextEditingController cctvHistoryProductIDController;

  late String? cctvHistoryDate;
  late String? cctvHistoryHour;
  late String? cctvHistoryMinute;
  late String? cctvHistorySecond;
  late TextEditingController cctvHistoryLogController;
  String _selectedIotEvent = '정상';
  String _selectedCctvEvent = '정상';
  String _selectedLocation = '추진구';

  @override
  void initState() {
    super.initState();

    iotHistoryProductIDController =
        widget.iotHistoryProductIDController ?? TextEditingController();
    iotHistoryProductLabelController =
        widget.iotHistoryProductLabelController ?? TextEditingController();
    iotHistoryLatitudeController =
        widget.iotHistoryLatitudeController ?? TextEditingController();
    iotHistoryLongitudeController =
        widget.iotHistoryLongitudeController ?? TextEditingController();

    iotHistoryLogController =
        widget.iotHistoryLogController ?? TextEditingController();

    cctvHistoryProductIDController =
        widget.cctvHistoryProductIDController ?? TextEditingController();

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
    iotHistoryProductIDController.addListener(() {
      final isEmpty = iotHistoryProductIDController.text.trim().isEmpty;
      if (isIotDeviceIdEmpty != isEmpty) {
        setState(() {
          isIotDeviceIdEmpty = isEmpty;
        });
      }
    });
    iotHistoryProductLabelController.addListener(() {
      final isEmpty = iotHistoryProductLabelController.text.trim().isEmpty;
      if (isIotLabelEmpty != isEmpty) {
        setState(() {
          isIotLabelEmpty = isEmpty;
        });
      }
    });


    cctvHistoryProductIDController.addListener(() {
      final isEmpty = cctvHistoryProductIDController.text.trim().isEmpty;
      if (isCctvDeviceIdEmpty != isEmpty) {
        setState(() {
          isCctvDeviceIdEmpty = isEmpty;
        });
      }
    });
  }

  DateTime? _composeTimestamp(
      String? dateStr, String? hour, String? minute, String? second) {
    try {
      if (dateStr == null || dateStr.isEmpty) return null;

      final paddedHour = hour?.padLeft(2, '0') ?? '00';
      final paddedMinute = minute?.padLeft(2, '0') ?? '00';
      final paddedSecond = second?.padLeft(2, '0') ?? '00';

      return DateTime.parse(
              '${dateStr}T$paddedHour:$paddedMinute:$paddedSecond')
          .toLocal();
    } catch (_) {
      return null;
    }
  }

  void _resetIotFields() {
    iotHistoryProductIDController.clear();
    iotHistoryProductLabelController.clear();
    iotHistoryLatitudeController.clear();
    iotHistoryLongitudeController.clear();
    iotHistoryLogController.clear();
    setState(() {
      iotHistoryDate = null;
      iotHistoryHour = '00';
      iotHistoryMinute = '00';
      iotHistorySecond = '00';
      _selectedIotEvent = '정상';
      isIotDeviceIdEmpty = true;
    });
  }

  void _resetCctvFields() {
    cctvHistoryProductIDController.clear();
    cctvHistoryLogController.clear();
    setState(() {
      cctvHistoryDate = null;
      cctvHistoryHour = '00';
      cctvHistoryMinute = '00';
      cctvHistorySecond = '00';
      _selectedCctvEvent = '정상';
      _selectedLocation = '추진구';
      isCctvDeviceIdEmpty = true;
    });
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
            color: Color(0xff414c67),
          ),
          child: Row(
            children: [
              SizedBox(width: 41.w),
              Text(
                '이벤트 관리',
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
          Transform.translate(
              offset: Offset(0, -4.h),
              child: Container(
                width: 2880.w,
                height: 1046.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.r),
                  color: const Color(0xff414c67),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Transform.translate(
                        offset: Offset(0.5.w, 0),
                        child: Container(
                            width: double.infinity,
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              color: Color(0xffe7eaf4),
                            ),
                            child: Transform.translate(
                                offset: Offset(-2.w, 0),
                                child: Container(
                                  color: Color(0xffe7eaf4),
                                  child: Text(
                                    'IoT 알람 히스토리',
                                    style: TextStyle(
                                        fontFamily: 'PretendardGOV',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 32.sp,
                                        color: Color(0xff414c67)),
                                  ),
                                )))),
                    Row(
                      children: [
                        SizedBox(
                          width: 1000.w,
                          height: 85.h,
                          child: labeledTextField(
                              title: 'RID :',
                              hint: '필수입력 :예)S1_001',
                              width: 420,
                              height: 60,
                              textBoxwidth: 400,
                              textBoxHeight: 50,
                              controller: iotHistoryProductIDController,
                              ),
                        ),
                        SizedBox(
                          width: 1000.w,
                          height: 85.h,
                          child: labeledTextField(
                              title: '라벨명 :',
                              hint: '필수입력 : 예)추진구 3층',
                              width: 420,
                              height: 60,
                              textBoxwidth: 270,
                              textBoxHeight: 50,
                              controller: iotHistoryProductLabelController,
                             ),
                        ),
                      ],
                    ),
                    CustomDivider(),
                    Row(
                      children: [
                        SizedBox(
                          width: 1000.w,
                          height: 85.h,
                          child: labeledTextField(
                              title: '위도 :',
                              hint: '',
                              width: 420,
                              height: 60,
                              textBoxwidth: 400,
                              textBoxHeight: 50,
                              controller: iotHistoryLatitudeController,
                              isNumeric: true),
                        ),
                        SizedBox(
                          width: 1000.w,
                          height: 85.h,
                          child: labeledTextField(
                              title: '경도 :',
                              hint: '',
                              width: 420,
                              height: 60,
                              textBoxwidth: 270,
                              textBoxHeight: 50,
                              controller: iotHistoryLongitudeController,
                              isNumeric: true),
                        ),
                      ],
                    ),
                    CustomDivider(),
                    SizedBox(
                      width: 2880.w,
                      height: 85.h,
                      child: LabeledDropdownField(
                        title: '이벤트 :',
                        items: ['정상', '주의', '경고', '점검필요'],
                        selectedValue: _selectedIotEvent,
                        onChanged: (val) =>
                            setState(() => _selectedIotEvent = val!),
                      ),
                    ),
                    CustomDivider(),
                    Row(
                      children: [
                        DatePickerField(
                          label: '날짜/시간 :',
                          initialDate: DateTime.tryParse(iotHistoryDate ?? ''),
                          onDateSelected: (date) {
                            setState(() {
                              iotHistoryDate = date
                                  .toIso8601String()
                                  .substring(0, 10); // 'yyyy-MM-dd' 형식
                            });
                          },
                        ),
                        SizedBox(
                          width: 43.15.w,
                        ),
                        TimePickerRow(
                          selectedHour: iotHistoryHour,
                          selectedMinute: iotHistoryMinute,
                          selectedSecond: iotHistorySecond,
                          onHourChanged: (val) =>
                              setState(() => iotHistoryHour = val),
                          onMinuteChanged: (val) =>
                              setState(() => iotHistoryMinute = val),
                          onSecondChanged: (val) =>
                              setState(() => iotHistorySecond = val),
                        ),
                      ],
                    ),
                    CustomDivider(),
                    Container(
                      width: 2880.w,
                      height: 85.h,
                      child: labeledTextField(
                        title: '로그 :',
                        hint: '',
                        width: 1800,
                        height: 60,
                        textBoxwidth: 400,
                        textBoxHeight: 50,
                        controller: iotHistoryLogController,
                      ),
                    ),
                    SizedBox(height: 5.h),
    Transform.translate(offset: Offset(-1.w,0),child: Container(
      width: 2881.w,
      color: Color(0xffe7eaf4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ActionButton(
            '등록',
            (isIotDeviceIdEmpty || isIotLabelEmpty)
                ? Colors.grey
                : const Color(0xffe98800),
            onTap: (isIotDeviceIdEmpty || isIotLabelEmpty)
                ? null
                : () async {
              final timestamp = _composeTimestamp(
                iotHistoryDate,
                iotHistoryHour,
                iotHistoryMinute,
                iotHistorySecond,
              );

              if (timestamp == null) {
                showDialog(
                  context: context,
                  builder: (_) => const DialogForm(
                    mainText: '날짜 또는 시간 형식이 올바르지 않습니다.',
                    btnText: '확인',
                  ),
                );
                return;
              }

              final success = await AlarmHistoryController.insertIotAlarm(
                rid: iotHistoryProductIDController.text,
                label: iotHistoryProductLabelController.text,
                timestamp: timestamp,
                event: _selectedIotEvent,
                log: iotHistoryLogController.text,
                latitude: double.tryParse(iotHistoryLatitudeController.text),
                longitude: double.tryParse(iotHistoryLongitudeController.text),
              );

              if (success) {
                _resetIotFields(); // ✅ 리셋 함수 사용 시 깔끔하게 처리 가능
              }

              showDialog(
                context: context,
                builder: (_) => DialogForm(
                  mainText: success ? 'IoT 알람 등록 완료!' : 'IoT 알람 등록 실패!',
                  btnText: '확인',
                ),
              );
            },
          )

        ],
      ),
    ),),

                    Transform.translate(
                        offset: Offset(-1.w, -4.h),
                        child: Container(
                            alignment: Alignment.centerLeft,
                            color: Color(0xffe7eaf4),
                            child: Transform.translate(
                                offset: Offset(2.w, 0),
                                child: Container(
                                  width: 2881.w,
                                  color: Color(0xffe7eaf4),
                                  child: Text(
                                    'CCTV 알람 히스토리',
                                    style: TextStyle(
                                        fontFamily: 'PretendardGOV',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 32.sp,
                                        color: Color(0xff414c67)),
                                  ),
                                )))),
                    SizedBox(
                      width: 2880.w,
                      height: 85.h,
                      child: labeledTextField(
                        title: '제품 식별자(ID) :',
                        hint: '필수입력 : 예) cam1',
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
                      child: LabeledDropdownField(
                        title: '설치 위치 :',
                        items: ['추진구', '도달구'],
                        selectedValue: _selectedLocation,
                        onChanged: (val) =>
                            setState(() => _selectedLocation = val!),
                      ),
                    ),
                    CustomDivider(),
                    SizedBox(
                      width: 2880.w,
                      height: 85.h,
                      child: LabeledDropdownField(
                        title: '이벤트 :',
                        items: ['정상', '주의', '경고', '점검필요'],
                        selectedValue: _selectedCctvEvent,
                        onChanged: (val) =>
                            setState(() => _selectedCctvEvent = val!),
                      ),
                    ),
                    CustomDivider(),
                    Row(
                      children: [
                        DatePickerField(
                          label: '날짜/시간 :',
                          initialDate: DateTime.tryParse(cctvHistoryDate ?? ''),
                          onDateSelected: (date) {
                            setState(() {
                              cctvHistoryDate =
                                  date.toIso8601String().substring(0, 10);
                            });
                          },
                        ),
                        SizedBox(
                          width: 43.15.w,
                        ),
                        TimePickerRow(
                          selectedHour: cctvHistoryHour,
                          selectedMinute: cctvHistoryMinute,
                          selectedSecond: cctvHistorySecond,
                          onHourChanged: (val) =>
                              setState(() => cctvHistoryHour = val),
                          onMinuteChanged: (val) =>
                              setState(() => cctvHistoryMinute = val),
                          onSecondChanged: (val) =>
                              setState(() => cctvHistorySecond = val),
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
                        width: 1800,
                        height: 60,
                        textBoxwidth: 400,
                        textBoxHeight: 50,
                        controller: cctvHistoryLogController,
                      ),
                    ),
                  ],
                ),
              )),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ActionButton(
                '등록',
                isCctvDeviceIdEmpty ? Colors.grey : const Color(0xffe98800),
                onTap: isCctvDeviceIdEmpty
                    ? null
                    : () async {
                  final timestamp = _composeTimestamp(
                    cctvHistoryDate,
                    cctvHistoryHour,
                    cctvHistoryMinute,
                    cctvHistorySecond,
                  );

                  if (timestamp == null) {
                    showDialog(
                      context: context,
                      builder: (_) => const DialogForm(
                        mainText: '날짜 또는 시간 형식이 올바르지 않습니다.',
                        btnText: '확인',
                      ),
                    );
                    return;
                  }

                  final success = await AlarmHistoryController.insertCctvAlarm(
                    deviceId: cctvHistoryProductIDController.text,
                    timestamp: timestamp,
                    event: _selectedCctvEvent,
                    log: cctvHistoryLogController.text,
                    label: _selectedLocation,
                  );

                  if (success) {
                    _resetCctvFields(); // ✅ 기존 필드 초기화 코드 대체
                  }

                  showDialog(
                    context: context,
                    builder: (_) => DialogForm(
                      mainText: success ? 'CCTV 알람 등록 완료!' : 'CCTV 알람 등록 실패!',
                      btnText: '확인',
                    ),
                  );
                },
              ),

              SizedBox(width: 400.w),
            ],
          ),
          SizedBox(height: 5.h),
        ],
      ],
    );
  }
}
