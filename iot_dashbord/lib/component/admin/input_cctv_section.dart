import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/component/admin/datepicker_field.dart';
import 'package:iot_dashboard/component/admin/image_picker_text_field.dart';
import 'package:iot_dashboard/component/admin/labeled_textfield_section.dart';
import 'package:iot_dashboard/component/admin/time_picker_row.dart';
import 'package:iot_dashboard/component/admin/action_button.dart';
import 'package:iot_dashboard/component/admin/section_title.dart';
import 'package:iot_dashboard/component/admin/custom_divider.dart';
import 'package:iot_dashboard/component/common/dialog_form.dart';
import 'package:iot_dashboard/controller/cctv_controller.dart';
import 'package:iot_dashboard/component/admin/labeled_dropdown_field.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:iot_dashboard/constants/global_constants.dart';




class CCTVInputSection extends StatefulWidget {
  final TextEditingController? cctvProductIDController;
  final TextEditingController? imageAnalysisController;
  final TextEditingController? cctvAddressController;
  final String? lastReceiveDate;
  final String? lastReceiveHour;
  final String? lastReceiveMinute;
  final String? lastReceiveSecond;

  const CCTVInputSection({
    Key? key,
    this.cctvProductIDController,
    this.imageAnalysisController,
    this.cctvAddressController,
    this.lastReceiveDate,
    this.lastReceiveHour,
    this.lastReceiveMinute,
    this.lastReceiveSecond,
  }) : super(key: key);


  @override
  State<CCTVInputSection> createState() => _CCTVInputSectionState();
}

class _CCTVInputSectionState extends State<CCTVInputSection> {
  bool isExpanded = false; // ✅ 펼침 여부 상태
  bool isEditing = false;
  late TextEditingController cctvProductIDController;
  late String _selectedLocation;  // 설치 위치
  late String _selectedConnection; // 연결
  late String _selectedEvent; // 이벤트
  late TextEditingController imageAnalysisController;
  late TextEditingController cctvAddressController;
  late String? lastReceiveDate;
  late String? lastReceiveHour;
  late String? lastReceiveMinute;
  late String? lastReceiveSecond;

  @override
  void initState() {
    super.initState();

    cctvProductIDController =
        widget.cctvProductIDController ?? TextEditingController();
    _selectedLocation = '추진구';
    _selectedConnection = '정상';
    _selectedEvent = '정상';
    imageAnalysisController =
        widget.imageAnalysisController ?? TextEditingController();
    cctvAddressController =
        widget.cctvAddressController ?? TextEditingController();
    lastReceiveDate = widget.lastReceiveDate;
    lastReceiveHour = widget.lastReceiveHour ?? '00';
    lastReceiveMinute = widget.lastReceiveMinute ?? '00';
    lastReceiveSecond = widget.lastReceiveSecond ?? '00';

  }
  DateTime? combineToDateTime(String? date, String? hour, String? minute) {
    if (date == null || date.isEmpty) return null;

    final h = int.tryParse(hour ?? '0') ?? 0;
    final m = int.tryParse(minute ?? '0') ?? 0;

    try {
      final dateTimeOnly = DateTime.parse(date);
      return DateTime(dateTimeOnly.year, dateTimeOnly.month, dateTimeOnly.day, h, m, 0, 0);
    } catch (e) {
      return null;
    }
  }

  String formatDateTimeForServer(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    final ms = dt.millisecond.toString().padLeft(3, '0');

    return '$y-$m-$d $h:$min:$s.$ms';
  }


  Future<void> postCctvData() async {
    final camID = cctvProductIDController.text.trim();
    if (camID.isEmpty) {
      // 필수값 체크 다이얼로그 표시
      showDialog(
        context: context,
        builder: (_) => const DialogForm(
          mainText: '제품 식별자(ID)를 입력하세요.',
          btnText: '확인',
        ),
      );
      return;
    }

    // // 연결 상태 변환
    // int? isConnectedBit;
    // final connectedText = isConnectedController.text.trim();
    // if (connectedText == '정상') {
    //   isConnectedBit = 0;
    // } else if (connectedText == '비정상') {
    //   isConnectedBit = 1;
    // } else {
    //   isConnectedBit = null;
    // }

    // 이미지 분석 숫자 변환
    double imageAnalysisValue = 0;
    try {
      imageAnalysisValue = double.parse(imageAnalysisController.text.trim());
    } catch (_) {
      imageAnalysisValue = 0;
    }

    // 수신 날짜와 시간 합치기
    String lastRecDate = lastReceiveDate ?? '';
    String lastRecHour = lastReceiveHour ?? '00';
    String lastRecMinute = lastReceiveMinute ?? '00';
    DateTime? lastRecordedDateTime;
    // 연결 상태 변환 (드롭다운 문자열 -> 0/1)
    int isConnectedBit = _selectedConnection == '정상' ? 0 : 1;
    try {
      lastRecordedDateTime = DateTime.parse('$lastRecDate $lastRecHour:$lastRecMinute:00');
    } catch (_) {
      lastRecordedDateTime = null;
    }

    final body = {
      'camID': camID,
      'location': _selectedLocation,
      'isConnected': isConnectedBit,
      'eventState': _selectedEvent,
      'imageAnalysis': imageAnalysisValue,
      'streamUrl': cctvAddressController.text.trim(),
      'lastRecorded': lastRecordedDateTime?.toIso8601String(),
    };

    body.removeWhere((key, value) => value == null || value == '');

    try {
      final response = await http.post(
        Uri.parse('${baseUrl4040}/api/cctvs'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 저장 성공시 다이얼로그 보여주기
        showDialog(
          context: context,
          builder: (_) => const DialogForm(
            mainText: 'CCTV 정보가 성공적으로 저장되었습니다.',
            btnText: '확인',
          ),
        );

        // 컨트롤러, 상태 변수 초기화 및 UI 갱신
        setState(() {
          cctvProductIDController.clear();
          _selectedLocation = '추진구';
          _selectedConnection = '정상';
          _selectedEvent = '정상';

          imageAnalysisController.clear();
          cctvAddressController.clear();
          lastReceiveDate = null;
          lastReceiveHour = null;
          lastReceiveMinute = null;
          // 필요 시 isEditing 초기화도 가능
          isEditing = false;
        });
      } else {
        showDialog(
          context: context,
          builder: (_) => DialogForm(
            mainText: '서버 오류: ${response.statusCode}',
            btnText: '닫기',
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => DialogForm(
          mainText: '네트워크 오류: $e',
          btnText: '닫기',
        ),
      );
    }
  }

  void _onAnyFieldChanged() {
    if (!isEditing) {
      setState(() {
        isEditing = true;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    // nullable 없이 bool로 선언하고, 바로 값 할당
    final bool isCamIdEmpty = cctvProductIDController.text.trim().isEmpty;
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
                'CCTV 정보 입력',
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
            height: 616.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.r),
              color: const Color(0xff414c67),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '제품 식별자(ID) :',
                    hint: '예 ) S1_001',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: cctvProductIDController,
                    onChanged: (val) {
                      setState(() {}); // 재빌드하여 isCamIdEmpty 반영
                      _onAnyFieldChanged();
                    },
                  ),
                ),
           CustomDivider(),
                Container(
                  width: 2880.w,
                  height: 85.h,
                  child: LabeledDropdownField(
                    title: '설치 위치 :',
                    items: ['추진구', '도달구'],
                    selectedValue: _selectedLocation,
                    onChanged: (val) => setState(() => _selectedLocation = val!),
                  ),
                ),
                CustomDivider(),
           CustomDivider(),
                Container(
                  width: 2880.w,
                  height: 85.h,
                  child: LabeledDropdownField(
                    title: '연결 :',
                    items: ['정상', '비정상'],
                    selectedValue: _selectedConnection,
                    onChanged: (val) => setState(() => _selectedConnection = val!),
                  ),
                ),
           CustomDivider(),
                Container(
                  width: 2880.w,
                  height: 85.h,
                  child: LabeledDropdownField(
                    title: '이벤트 :',
                    items: ['정상', '비정상'],
                    selectedValue: _selectedEvent,
                    onChanged: (val) => setState(() => _selectedEvent = val!),
                  ),
                ),
           CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '이미지 분석 :',
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: imageAnalysisController,
                  ),
                ),
           CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '주소 :',
                    hint: '',
                    width: 1260,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: cctvAddressController,
                  ),
                ),
           CustomDivider(),
                SizedBox(height: 8.h,),
                Row(
                  children: [
                    DatePickerField(
                      label: '수신 날짜 :',
                      initialDate: DateTime.tryParse( lastReceiveDate?? ''),
                      onDateSelected: (date) {
                        setState(() {
                          lastReceiveDate = date.toIso8601String().substring(0, 10);
                        });
                      },
                    ),
                    SizedBox(width: 136.15.w,),
                    Container(
                      alignment: Alignment.center,
                      child: TimePickerRow(
                        label: '수신 시간 :',
                        selectedHour: lastReceiveHour,
                        selectedMinute: lastReceiveMinute,
                        selectedSecond: lastReceiveSecond,
                        onHourChanged: (val) => setState(() => lastReceiveHour = val),
                        onMinuteChanged: (val) => setState(() => lastReceiveMinute = val),
                        onSecondChanged: (val) => setState(() => lastReceiveSecond = val),
                      ),
                    ),
                  ],
                )

              ],
            ),
          ),

        ],
        SizedBox(height: 5.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ActionButton(
              '등록',
              isCamIdEmpty ? Colors.grey : const Color(0xffe98800),
              onTap: isCamIdEmpty
                  ? null
                  : () async {
                await postCctvData();
              },
            ),
            SizedBox(width: 400.w),
          ],
        ),

        SizedBox(height: 5.h),
      ],
    );
  }
}
