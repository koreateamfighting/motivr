import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/component/admin/datepicker_field.dart';
import 'package:iot_dashboard/component/admin/image_picker_text_field.dart';
import 'package:iot_dashboard/theme/colors.dart';
import 'package:iot_dashboard/component/admin/labeled_textfield_section.dart';
import 'package:iot_dashboard/component/admin/action_button.dart';
import 'package:iot_dashboard/component/admin/section_title.dart';
import 'package:iot_dashboard/component/admin/custom_divider.dart';
import 'package:iot_dashboard/controller/iot_controller.dart';
import 'package:provider/provider.dart';
import 'package:iot_dashboard/model/iot_model.dart';
import 'dart:convert';
import 'package:iot_dashboard/component/admin/time_picker_row.dart';
import 'package:iot_dashboard/component/admin/labeled_dropdown_field.dart';
import 'package:flutter/services.dart';
import 'package:iot_dashboard/component/common/dialog_form.dart';


class IotInputSection extends StatefulWidget {
  final TextEditingController? iotProductIDController;
  final TextEditingController? labelController;
  final TextEditingController? latitudeController;
  final TextEditingController? longitudeController;
  final TextEditingController? x_DegController;
  final TextEditingController? y_DegController;
  final TextEditingController? z_DegController;
  final TextEditingController? x_MMController;
  final TextEditingController? y_MMController;
  final TextEditingController? z_MMController;
  final String? createdAtDate;
  final String? createdAtHour;
  final String? createdAtMinute;
  final String? createdAtSecond;
  final TextEditingController? batteryVoltageController;
  final TextEditingController? batteryInfoController;

  const IotInputSection({
    Key? key,
    this.iotProductIDController,
    this.labelController,
    this.longitudeController,
    this.latitudeController,
    this.x_MMController,
    this.y_MMController,
    this.z_MMController,
    this.x_DegController,
    this.y_DegController,
    this.z_DegController,
    this.createdAtDate,
    this.createdAtHour,
    this.createdAtMinute,
    this.createdAtSecond,
    this.batteryVoltageController,
    this.batteryInfoController,
  }) : super(key: key);

  @override
  State<IotInputSection> createState() => _IotInputSectionState();
}

class _IotInputSectionState extends State<IotInputSection> {
  bool isExpanded = false; // ✅ 펼침 여부 상태
  bool _isFormValid = false;
  late TextEditingController iotProductIDController;
  late TextEditingController labelController;
  late TextEditingController longitudeController;
  late TextEditingController latitudeController;
  late TextEditingController x_MMController;
  late TextEditingController y_MMController;
  late TextEditingController z_MMController;
  late TextEditingController x_DegController;
  late TextEditingController y_DegController;
  late TextEditingController z_DegController;
  late String? createdAtHour;
  late String? createdAtMinute;
  late String? createdAtSecond;
  late String? createdAtDate;
  late TextEditingController batteryVoltageController;
  late TextEditingController batteryInfoController;
  String _selectedEventType = '주기데이터';
  String iotSenSorType = '변위';





  @override
  void initState() {
    super.initState();

    iotProductIDController =
        widget.iotProductIDController ?? TextEditingController();
    labelController =
        widget.labelController ?? TextEditingController();
    latitudeController = widget.latitudeController ?? TextEditingController();
    longitudeController = widget.longitudeController ??
        TextEditingController();
    x_MMController = widget.x_MMController ?? TextEditingController();
    y_MMController = widget.y_MMController ?? TextEditingController();
    z_MMController = widget.z_MMController ?? TextEditingController();
    x_DegController = widget.x_DegController ?? TextEditingController();
    y_DegController = widget.y_DegController ?? TextEditingController();
    z_DegController = widget.z_DegController ?? TextEditingController();

    x_DegController.addListener(_checkAngleThreshold);
    y_DegController.addListener(_checkAngleThreshold);
    z_DegController.addListener(_checkAngleThreshold);


    batteryVoltageController =
        widget.batteryVoltageController ?? TextEditingController();
    batteryInfoController =
        widget.batteryInfoController ?? TextEditingController();
    iotProductIDController.addListener(_validateForm);
    labelController.addListener(_validateForm);
    createdAtDate = widget.createdAtDate;
    createdAtHour = widget.createdAtHour ?? '00';
    createdAtMinute = widget.createdAtMinute ?? '00';
    createdAtSecond = widget.createdAtSecond ?? '00';

  }

  String _pad(String? value) {
    if (value == null || value.isEmpty) return '00';
    return value.padLeft(2, '0');
  }

  void _validateForm() {
    setState(() {
      _isFormValid =
          iotProductIDController.text.trim().isNotEmpty && labelController.text.trim().isNotEmpty;
    });
  }


  @override
  void dispose() {
    // 컨트롤러 리스너 해제
    iotProductIDController.removeListener(_validateForm);
    labelController.removeListener(_validateForm);
    x_DegController.removeListener(_checkAngleThreshold);
    y_DegController.removeListener(_checkAngleThreshold);
    z_DegController.removeListener(_checkAngleThreshold);

    super.dispose();
  }
  void _checkAngleThreshold() {
    double parseValue(String text) {
      return double.tryParse(text.trim()) ?? 0.0;
    }

    final x = parseValue(x_DegController.text).abs();
    final y = parseValue(y_DegController.text).abs();
    final z = parseValue(z_DegController.text).abs();

    final isWarning = x >= 5 || y >= 5 || z >= 5;
    final isCaution = !isWarning && (x >= 3 || y >= 3 || z >= 3);

    if (isWarning && _selectedEventType != '경고') {
      setState(() {
        _selectedEventType = '경고';
      });

      showDialog(
        context: context,
        builder: (_) => const DialogForm(
          mainText: 'X, Y, Z 각도 중 하나의 절댓값이 5 이상으로 상태가 경고로 설정되었습니다.',
          btnText: '확인',
        ),
      );
    } else if (isCaution && _selectedEventType != '주의') {
      setState(() {
        _selectedEventType = '주의';
      });

      showDialog(
        context: context,
        builder: (_) => const DialogForm(
          mainText: 'X, Y, Z 각도 중 하나의 절댓값이 3 이상 5 미만으로 상태가 주의로 설정되었습니다.',
          btnText: '확인',
        ),
      );
    }
  }



  Future<void> _handleSubmit() async {
    final controller = Provider.of<IotController>(context, listen: false);

    final item = IotItem(
      id: iotProductIDController.text.trim(),
      label: labelController.text.trim(),
      sensortype: '변위',
      eventtype: _selectedEventType,
      latitude: latitudeController.text.trim(),
      longitude: longitudeController.text.trim(),
      battery: batteryVoltageController.text.trim(),
      X_MM: x_MMController.text.trim(),
      Y_MM: y_MMController.text.trim(),
      Z_MM: z_MMController.text.trim(),
      X_Deg: x_DegController.text.trim(),
      Y_Deg: y_DegController.text.trim(),
      Z_Deg: z_DegController.text.trim(),
      batteryInfo: batteryInfoController.text.trim(),
      download: '다운로드 파일 준비',
      createAt: (createdAtDate != null && createdAtDate!.isNotEmpty)
          ? DateTime.parse('${createdAtDate!}T${_pad(createdAtHour)}:${_pad(createdAtMinute)}:${_pad(createdAtSecond)}').toLocal()
          : DateTime.now(),




    );

    final success = await controller.submitIotItem(item);


    if (success) {

      iotProductIDController.clear();
      labelController.clear();
      latitudeController.clear();
      longitudeController.clear();
      x_MMController.clear();
      y_MMController.clear();
      z_MMController.clear();
      x_DegController.clear();
      y_DegController.clear();
      z_DegController.clear();
      batteryVoltageController.clear();
      batteryInfoController.clear();

      // ✅ 날짜/시간 초기화
      setState(() {
        createdAtDate = null;
        createdAtHour = '00';
        createdAtMinute = '00';
        createdAtSecond = '00';

        // ✅ 드롭다운 초기화
        _selectedEventType = '주기데이터';

        // ✅ 유효성 검사 재실행 (버튼 비활성화 위해)
        _isFormValid = false;
      });
      showDialog(
        context: context,
        builder: (context) => DialogForm(
          mainText: '센서 데이터가 저장되었습니다.',
          btnText: '닫기',
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => DialogForm(
          mainText: '저장 중 오류가 발생했습니다.\n서버 상태를 확인하세요.',
          btnText: '닫기',
          fontSize: 20,
        ),
      );
    }


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
                'IoT 정보 입력',
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
            height: 718.h + 85.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.r),
              color: const Color(0xff414c67),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 1035.w,
                      height: 85.h,
                      child: labeledTextField(
                        title: '제품 식별자(ID) :',
                        hint: '필수 입력',
                        width: 420,
                        height: 60,
                        textBoxwidth: 400,
                        textBoxHeight: 50,
                        controller: iotProductIDController,
                      ),
                    ),
                    Container(
                      width: 300.w,
                      height: 50.h,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '센서타입 :',
                        style: TextStyle(
                          fontFamily: 'PretendardGOV',
                          fontSize: 36.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      width: 192.87.w,
                      height: 50.h,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '변위',
                        style: TextStyle(
                          fontFamily: 'PretendardGOV',
                          fontSize: 36.sp,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
                CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '라벨명 :',
                    hint: '필수 입력',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: labelController,
                  ),
                ),
                CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: LabeledDropdownField(
                    title: '상태 :',
                    items: ['주기데이터', '주의','경고','GPS'],
                    selectedValue: _selectedEventType,
                    onChanged: (val) => setState(() => _selectedEventType = val!),
                  ),
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
                        controller: latitudeController,
                          isNumeric: true
                      ),
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
                        controller: longitudeController,
                          isNumeric: true
                      ),
                    ),
                  ],
                ),
                CustomDivider(),
                SizedBox(
                    width: 2880.w,
                    height: 85.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 40.w,
                        ),
                        Container(
                          width: 400.w,
                          height: 50.h,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'X,Y,Z (0°) :',
                            style: TextStyle(
                              fontFamily: 'PretendardGOV',
                              fontSize: 36.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.h),
                        Container(
                            width: 420.w,
                            height: 60.h,
                            child: TextField(
                              controller: x_DegController,
                              style: TextStyle(color: Colors.black,fontSize: 36.sp),
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              inputFormatters:[FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))],
                              decoration: InputDecoration(
                                hintText: '',
                                hintStyle: TextStyle(
                                    color: Color(0xff9eaea2),
                                    fontSize: 36.sp,
                                    fontWeight: FontWeight.w300,
                                    fontFamily: 'PretendardGOV'),
                                filled: true,
                                fillColor: Colors.white,

                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: AppColors.focusedBorder(2.w),
                                // ✅ 여기에 적용
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 12.h),
                              ),
                            )),
                        SizedBox(
                          width: 200.w,
                        ),
                        Container(
                            width: 420.w,
                            height: 60.h,
                            child: TextField(
                              controller: y_DegController,
                              style: TextStyle(color: Colors.black,fontSize: 36.sp),
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              inputFormatters:[FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))],
                              decoration: InputDecoration(
                                hintText: '',
                                hintStyle: TextStyle(
                                    color: Color(0xff9eaea2),
                                    fontSize: 36.sp,
                                    fontWeight: FontWeight.w300,
                                    fontFamily: 'PretendardGOV'),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: AppColors.focusedBorder(2.w),
                                // ✅ 여기에 적용
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 12.h),
                              ),
                            )),
                        SizedBox(
                          width: 200.w,
                        ),
                        Container(
                            width: 420.w,
                            height: 60.h,
                            child: TextField(
                              controller: z_DegController,
                              style: TextStyle(color: Colors.black,fontSize: 36.sp),
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              inputFormatters:[FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))],
                              decoration: InputDecoration(
                                hintText: '',
                                hintStyle: TextStyle(
                                    color: Color(0xff9eaea2),
                                    fontSize: 36.sp,
                                    fontWeight: FontWeight.w300,
                                    fontFamily: 'PretendardGOV'),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: AppColors.focusedBorder(2.w),
                                // ✅ 여기에 적용
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 12.h),
                              ),
                            ))
                      ],
                    )),
                CustomDivider(),
                SizedBox(
                    width: 2880.w,
                    height: 85.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 40.w,
                        ),
                        Container(
                          width: 400.w,
                          height: 50.h,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'X,Y,Z (mm) :',
                            style: TextStyle(
                              fontFamily: 'PretendardGOV',
                              fontSize: 36.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,

                            ),
                          ),
                        ),
                        SizedBox(width: 12.h),
                        Container(
                            width: 420.w,
                            height: 60.h,
                            child: TextField(
                              controller: x_MMController,
                              style: TextStyle(color: Colors.black,fontSize: 36.sp),
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              inputFormatters:[FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))],
                              decoration: InputDecoration(
                                hintText: '',
                                hintStyle: TextStyle(
                                    color: Color(0xff9eaea2),
                                    fontSize: 36.sp,
                                    fontWeight: FontWeight.w300,
                                    fontFamily: 'PretendardGOV'),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: AppColors.focusedBorder(2.w),
                                // ✅ 여기에 적용
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 12.h),
                              ),
                            )),
                        SizedBox(
                          width: 200.w,
                        ),
                        Container(
                            width: 420.w,
                            height: 60.h,
                            child: TextField(
                              controller: y_MMController,
                              style: TextStyle(color: Colors.black,fontSize: 36.sp),
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              inputFormatters:[FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))],
                              decoration: InputDecoration(
                                hintText: '',
                                hintStyle: TextStyle(
                                    color: Color(0xff9eaea2),
                                    fontSize: 36.sp,
                                    fontWeight: FontWeight.w300,
                                    fontFamily: 'PretendardGOV'),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: AppColors.focusedBorder(2.w),
                                // ✅ 여기에 적용
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 12.h),
                              ),
                            )),
                        SizedBox(
                          width: 200.w,
                        ),
                        Container(
                            width: 420.w,
                            height: 60.h,
                            child: TextField(
                              controller: z_MMController,
                              style: TextStyle(color: Colors.black,fontSize: 36.sp),
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              inputFormatters:[FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))],
                              decoration: InputDecoration(
                                hintText: '',
                                hintStyle: TextStyle(
                                    color: Color(0xff9eaea2),
                                    fontSize: 36.sp,
                                    fontWeight: FontWeight.w300,
                                    fontFamily: 'PretendardGOV'),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: AppColors.focusedBorder(2.w),
                                // ✅ 여기에 적용
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 12.h),
                              ),
                            ))
                      ],
                    )),
                CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '배터리 전압:',
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: batteryVoltageController,
                    isNumeric: true
                  ),
                ),
                CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '배터리 정보 :',
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: batteryInfoController,
                      isNumeric: true
                  ),
                ),
                CustomDivider(),
                CustomDivider(),
                SizedBox(
                  height: 8.h,
                ),
                Row(
                  children: [
                    DatePickerField(
                      label: '수신 날짜 :',
                      initialDate: DateTime.tryParse( createdAtDate?? ''),
                      onDateSelected: (date) {
                        setState(() {
                          createdAtDate = date.toIso8601String().substring(0, 10);
                        });
                      },
                    ),
                    SizedBox(width: 136.15.w,),
                    Column(
                      children: [
                        SizedBox(height: 8.h,),
                        Container(
                          alignment: Alignment.center,
                          child: TimePickerRow(
                            label: '수신 시간 :',
                            selectedHour: createdAtHour,
                            selectedMinute: createdAtMinute,
                            selectedSecond: createdAtSecond,
                            onHourChanged: (val) => setState(() => createdAtHour = val),
                            onMinuteChanged: (val) => setState(() => createdAtMinute = val),
                            onSecondChanged: (val) => setState(() => createdAtSecond = val),
                          ),
                        ),
                      ],
                    )

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
              _isFormValid ? const Color(0xffe98800) : Colors.grey, // ✅ 색상 전환
              onTap: _isFormValid
                  ? () {
                      _handleSubmit();
                    }
                  : null, // ✅ 비활성 상태에서는 null
            ),
            SizedBox(width: 400.w),
          ],
        ),
        SizedBox(height: 5.h),
      ],
    );
  }
}
