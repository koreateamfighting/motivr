import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/component/admin/datepicker_field.dart';
import 'package:iot_dashboard/component/admin/image_picker_text_field.dart';
import 'package:iot_dashboard/component/admin/labeled_textfield_section.dart';
import 'package:iot_dashboard/component/admin/action_button.dart';
import 'package:iot_dashboard/component/admin/section_title.dart';
import 'package:iot_dashboard/theme/colors.dart';
import 'package:iot_dashboard/component/admin/custom_divider.dart';
import 'package:iot_dashboard/model/special_sensor_model.dart';
import 'package:iot_dashboard/controller/special_sensor_controller.dart';
import 'package:iot_dashboard/component/common/dialog_form.dart';
import 'package:iot_dashboard/component/admin/labeled_dropdown_field.dart';

class InputSpecialSensorSection extends StatefulWidget {
  final TextEditingController? inclinometerIdController;
  final String? inclinometerDate;
  final Map<double, TextEditingController>? inclinometerDepthValues;

  final TextEditingController? piezometerIdController;
  final String? piezometerDate;
  final TextEditingController? piezometerDryDaysController;
  final TextEditingController? piezometerCurrentWaterLevelController;
  final TextEditingController? piezometerGroundLevelController;
  final TextEditingController? piezometerChangeAmountController;
  final TextEditingController? piezometerCumulativeChangeController;

  final TextEditingController? strainGaugeIdController;
  final String? strainGaugeDate;
  final TextEditingController? strainGaugeReadingController;
  final TextEditingController? strainGaugeStressController;
  final TextEditingController? strainGaugeDepthController;

  final TextEditingController? settlementGaugeIdController;
  final String? settlementGaugeDate;
  final TextEditingController? settlementGaugeDryDaysController;
  final TextEditingController? settlementGaugeAbsoluteValues1;
  final TextEditingController? settlementGaugeAbsoluteValues2;
  final TextEditingController? settlementGaugeAbsoluteValues3;
  final TextEditingController? settlementGaugeSubsidenceValues1;
  final TextEditingController? settlementGaugeSubsidenceValues2;
  final TextEditingController? settlementGaugeSubsidenceValues3;

  const InputSpecialSensorSection({
    Key? key,
    this.inclinometerIdController,
    this.inclinometerDate,
    this.inclinometerDepthValues,
    this.piezometerIdController,
    this.piezometerDate,
    this.piezometerDryDaysController,
    this.piezometerCurrentWaterLevelController,
    this.piezometerGroundLevelController,
    this.piezometerChangeAmountController,
    this.piezometerCumulativeChangeController,
    this.strainGaugeIdController,
    this.strainGaugeDate,
    this.strainGaugeReadingController,
    this.strainGaugeStressController,
    this.strainGaugeDepthController,
    this.settlementGaugeIdController,
    this.settlementGaugeDate,
    this.settlementGaugeDryDaysController,
    this.settlementGaugeAbsoluteValues1,
    this.settlementGaugeAbsoluteValues2,
    this.settlementGaugeAbsoluteValues3,
    this.settlementGaugeSubsidenceValues1,
    this.settlementGaugeSubsidenceValues2,
    this.settlementGaugeSubsidenceValues3,
  }) : super(key: key);

  @override
  State<InputSpecialSensorSection> createState() =>
      _InputSpecialSensorSectionSectionState();
}

class _InputSpecialSensorSectionSectionState
    extends State<InputSpecialSensorSection> {
  bool isExpanded = false;

  bool get isInclinometerIdValid =>
      inclinometerIdController.text.trim().isNotEmpty;
  late String _selectedInclinometerLocation; // 연결
  late TextEditingController inclinometerIdController;
  late String? inclinometerDate;
  late TextEditingController inclinometerMeasuredDepthsController;
  late Map<double, TextEditingController> inclinometerDepthValues;
  DateTime? _selectedInclinometerDate;

  late TextEditingController piezometerIdController;
  late String _selectedPiezometerLocation; // 연결
  late String? piezometerDate;
  late TextEditingController piezometerDryDaysController;
  late TextEditingController piezometerCurrentWaterLevelController;
  late TextEditingController piezometerGroundLevelController;
  late TextEditingController piezometerChangeAmountController;
  late TextEditingController piezometerCumulativeChangeController;
  DateTime? _selectedPiezometerDate;

  late TextEditingController strainGaugeIdController;
  late String _selectedStrainGaugeLocation; // 연결
  late String? strainGaugeDate;
  late TextEditingController strainGaugeReadingController;
  late TextEditingController strainGaugeStressController;
  late TextEditingController strainGaugeDepthController;
  DateTime? _selectedStrainGaugeDate;

  late TextEditingController settlementGaugeIdController;
  late String _selectedSettlementGaugeLocation; // 연결
  late String? settlementGaugeDate;
  late TextEditingController settlementGaugeDryDaysController;
  late TextEditingController settlementGaugeAbsoluteValues1;
  late TextEditingController settlementGaugeAbsoluteValues2;
  late TextEditingController settlementGaugeAbsoluteValues3;
  late TextEditingController settlementGaugeSubsidenceValues1;
  late TextEditingController settlementGaugeSubsidenceValues2;
  late TextEditingController settlementGaugeSubsidenceValues3;
  DateTime? _selectedSettlementGaugeDate;

  @override
  void initState() {
    super.initState();

    inclinometerIdController =
        widget.inclinometerIdController ?? TextEditingController();
    _selectedInclinometerLocation = '추진구';
    inclinometerDate = widget.inclinometerDate;

    inclinometerDepthValues = widget.inclinometerDepthValues ?? {};

    piezometerIdController =
        widget.piezometerIdController ?? TextEditingController();
    _selectedPiezometerLocation = '추진구';
    piezometerDate = widget.piezometerDate;
    piezometerDryDaysController =
        widget.piezometerDryDaysController ?? TextEditingController();
    piezometerCurrentWaterLevelController =
        widget.piezometerCurrentWaterLevelController ?? TextEditingController();
    piezometerGroundLevelController =
        widget.piezometerGroundLevelController ?? TextEditingController();
    piezometerChangeAmountController =
        widget.piezometerChangeAmountController ?? TextEditingController();
    piezometerCumulativeChangeController =
        widget.piezometerCumulativeChangeController ?? TextEditingController();

    strainGaugeIdController =
        widget.strainGaugeIdController ?? TextEditingController();
    _selectedStrainGaugeLocation = '추진구';
    strainGaugeDate = widget.strainGaugeDate;
    strainGaugeReadingController =
        widget.strainGaugeReadingController ?? TextEditingController();
    strainGaugeStressController =
        widget.strainGaugeStressController ?? TextEditingController();
    strainGaugeDepthController =
        widget.strainGaugeDepthController ?? TextEditingController();

    settlementGaugeIdController =
        widget.settlementGaugeIdController ?? TextEditingController();
    _selectedSettlementGaugeLocation = '추진구';
    settlementGaugeDate = widget.settlementGaugeDate;
    settlementGaugeDryDaysController =
        widget.settlementGaugeDryDaysController ?? TextEditingController();
    settlementGaugeAbsoluteValues1 =
        widget.settlementGaugeAbsoluteValues1 ?? TextEditingController();
    settlementGaugeAbsoluteValues2 =
        widget.settlementGaugeAbsoluteValues2 ?? TextEditingController();
    settlementGaugeAbsoluteValues3 =
        widget.settlementGaugeAbsoluteValues3 ?? TextEditingController();
    settlementGaugeSubsidenceValues1 =
        widget.settlementGaugeSubsidenceValues1 ?? TextEditingController();
    settlementGaugeSubsidenceValues2 =
        widget.settlementGaugeSubsidenceValues2 ?? TextEditingController();
    settlementGaugeSubsidenceValues3 =
        widget.settlementGaugeSubsidenceValues3 ?? TextEditingController();
    if (widget.inclinometerDate != null) {
      try {
        _selectedInclinometerDate = DateTime.parse(widget.inclinometerDate!);
      } catch (_) {
        _selectedInclinometerDate = null;
      }
    }
    if (widget.piezometerDate != null) {
      try {
        _selectedPiezometerDate = DateTime.parse(widget.piezometerDate!);
      } catch (_) {
        _selectedPiezometerDate = null;
      }
    }
    if (widget.strainGaugeDate != null) {
      try {
        _selectedStrainGaugeDate = DateTime.parse(widget.strainGaugeDate!);
      } catch (_) {
        _selectedStrainGaugeDate = null;
      }
    }
    if (widget.settlementGaugeDate != null) {
      try {
        _selectedSettlementGaugeDate =
            DateTime.parse(widget.settlementGaugeDate!);
      } catch (_) {
        _selectedSettlementGaugeDate = null;
      }
    }
  }

  Future<void> _saveInclinometer() async {
    final data = SpecialSensorData(
      installationID: inclinometerIdController.text.trim(),
      type: '지중경사계',
      installationLocation: _selectedInclinometerLocation,
      measurementDate: _selectedInclinometerDate,
      measurementDepth: '15m',
      measurementInterval: '0.5m',
      depthMinus0_0: double.tryParse(inclinometerDepthValues[-0.0]?.text ?? ''),
      depthMinus0_5: double.tryParse(inclinometerDepthValues[-0.5]?.text ?? ''),
      depthMinus1_0: double.tryParse(inclinometerDepthValues[-1.0]?.text ?? ''),
      depthMinus1_5: double.tryParse(inclinometerDepthValues[-1.5]?.text ?? ''),
      depthMinus2_0: double.tryParse(inclinometerDepthValues[-2.0]?.text ?? ''),
      depthMinus2_5: double.tryParse(inclinometerDepthValues[-2.5]?.text ?? ''),
      depthMinus3_0: double.tryParse(inclinometerDepthValues[-3.0]?.text ?? ''),
      depthMinus3_5: double.tryParse(inclinometerDepthValues[-3.5]?.text ?? ''),
      depthMinus4_0: double.tryParse(inclinometerDepthValues[-4.0]?.text ?? ''),
      depthMinus4_5: double.tryParse(inclinometerDepthValues[-4.5]?.text ?? ''),
      depthMinus5_0: double.tryParse(inclinometerDepthValues[-5.0]?.text ?? ''),
      depthMinus5_5: double.tryParse(inclinometerDepthValues[-5.5]?.text ?? ''),
      depthMinus6_0: double.tryParse(inclinometerDepthValues[-6.0]?.text ?? ''),
      depthMinus6_5: double.tryParse(inclinometerDepthValues[-6.5]?.text ?? ''),
      depthMinus7_0: double.tryParse(inclinometerDepthValues[-7.0]?.text ?? ''),
      depthMinus7_5: double.tryParse(inclinometerDepthValues[-7.5]?.text ?? ''),
      depthMinus8_0: double.tryParse(inclinometerDepthValues[-8.0]?.text ?? ''),
      depthMinus8_5: double.tryParse(inclinometerDepthValues[-8.5]?.text ?? ''),
      depthMinus9_0: double.tryParse(inclinometerDepthValues[-9.0]?.text ?? ''),
      depthMinus9_5: double.tryParse(inclinometerDepthValues[-9.5]?.text ?? ''),
      depthMinus10_0:
          double.tryParse(inclinometerDepthValues[-10.0]?.text ?? ''),
      depthMinus10_5:
          double.tryParse(inclinometerDepthValues[-10.5]?.text ?? ''),
      depthMinus11_0:
          double.tryParse(inclinometerDepthValues[-11.0]?.text ?? ''),
      depthMinus11_5:
          double.tryParse(inclinometerDepthValues[-11.5]?.text ?? ''),
      depthMinus12_0:
          double.tryParse(inclinometerDepthValues[-12.0]?.text ?? ''),
      depthMinus12_5:
          double.tryParse(inclinometerDepthValues[-12.5]?.text ?? ''),
      depthMinus13_0:
          double.tryParse(inclinometerDepthValues[-13.0]?.text ?? ''),
      depthMinus13_5:
          double.tryParse(inclinometerDepthValues[-13.5]?.text ?? ''),
      depthMinus14_0:
          double.tryParse(inclinometerDepthValues[-14.0]?.text ?? ''),
      depthMinus14_5:
          double.tryParse(inclinometerDepthValues[-14.5]?.text ?? ''),
      depthMinus15_0:
          double.tryParse(inclinometerDepthValues[-15.0]?.text ?? ''),
    );

    final success = await SpecialSensorController.upsertSensorData(data);

    if (success) {
      setState(() {
        inclinometerIdController.clear();
        _selectedInclinometerLocation = '추진구';
        _selectedInclinometerDate = null;
        for (final controller in inclinometerDepthValues.values) {
          controller.clear();
        }
      });

      showDialog(
        context: context,
        builder: (context) => DialogForm(
          mainText: '지중경사계 데이터가 저장되었습니다..',
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

  Future<void> _savePiezometer() async {
    final data = SpecialSensorData(
      installationID: piezometerIdController.text.trim(),
      type: '지하수위계',
      installationLocation: _selectedPiezometerLocation,
      measurementDate: _selectedPiezometerDate,
      elapsedDays: int.tryParse(piezometerDryDaysController.text),
      currentWaterLevel:
          double.tryParse(piezometerCurrentWaterLevelController.text),
      excavationLevel: double.tryParse(piezometerGroundLevelController.text),
      changeAmount: double.tryParse(piezometerChangeAmountController.text),
      cumulativeDisplacement:
          double.tryParse(piezometerCumulativeChangeController.text),
    );

    final success = await SpecialSensorController.upsertSensorData(data);

    if (success) {
      setState(() {
        piezometerIdController.clear();
        _selectedPiezometerLocation = '추진구';
        _selectedPiezometerDate = null;
        piezometerDryDaysController.clear();
        piezometerCurrentWaterLevelController.clear();
        piezometerGroundLevelController.clear();
        piezometerChangeAmountController.clear();
        piezometerCumulativeChangeController.clear();
      });

      showDialog(
        context: context,
        builder: (context) => DialogForm(
          mainText: '지하수위계 데이터가 저장되었습니다.',
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

  Future<void> _saveStrainGauge() async {
    final data = SpecialSensorData(
      installationID: strainGaugeIdController.text.trim(),
      type: '변형률계',
      installationLocation: _selectedStrainGaugeLocation,
      measurementDate: _selectedStrainGaugeDate,
      strainGaugeReading: double.tryParse(strainGaugeReadingController.text),
      stress: double.tryParse(strainGaugeStressController.text),
      excavationDepth: double.tryParse(strainGaugeDepthController.text),
    );

    final success = await SpecialSensorController.upsertSensorData(data);

    if (success) {
      setState(() {
        strainGaugeIdController.clear();
        _selectedStrainGaugeLocation = '추진구';
        _selectedStrainGaugeDate = null;
        strainGaugeReadingController.clear();
        strainGaugeStressController.clear();
        strainGaugeDepthController.clear();
      });

      showDialog(
        context: context,
        builder: (_) => DialogForm(
          mainText: '변형률계 데이터가 저장되었습니다.',
          btnText: '닫기',
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => DialogForm(
          mainText: '저장 중 오류가 발생했습니다.\n서버 상태를 확인하세요.',
          btnText: '닫기',
          fontSize: 20,
        ),
      );
    }
  }

  Future<void> _saveSettlementGauge() async {
    final data = SpecialSensorData(
      installationID: settlementGaugeIdController.text.trim(),
      type: '지표침하계',
      installationLocation: _selectedSettlementGaugeLocation,
      measurementDate: _selectedSettlementGaugeDate,
      elapsedDays: int.tryParse(settlementGaugeDryDaysController.text),
      absoluteAltitude1: double.tryParse(settlementGaugeAbsoluteValues1.text),
      absoluteAltitude2: double.tryParse(settlementGaugeAbsoluteValues2.text),
      absoluteAltitude3: double.tryParse(settlementGaugeAbsoluteValues3.text),
      subsidence1: double.tryParse(settlementGaugeSubsidenceValues1.text),
      subsidence2: double.tryParse(settlementGaugeSubsidenceValues2.text),
      subsidence3: double.tryParse(settlementGaugeSubsidenceValues3.text),
    );

    final success = await SpecialSensorController.upsertSensorData(data);

    if (success) {
      setState(() {
        settlementGaugeIdController.clear();
        _selectedSettlementGaugeLocation = '추진구';
        _selectedSettlementGaugeDate = null;
        settlementGaugeDryDaysController.clear();
        settlementGaugeAbsoluteValues1.clear();
        settlementGaugeAbsoluteValues2.clear();
        settlementGaugeAbsoluteValues3.clear();
        settlementGaugeSubsidenceValues1.clear();
        settlementGaugeSubsidenceValues2.clear();
        settlementGaugeSubsidenceValues3.clear();
      });
      showDialog(
        context: context,
        builder: (_) => DialogForm(
          mainText: '지표침하계 데이터가 저장되었습니다.',
          btnText: '닫기',
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => DialogForm(
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
                '센서 정보',
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
          Row(
            children: [
              SizedBox(
                width: 400.w,
              ),
              Container(
                  alignment: Alignment.centerLeft,
                  color: Color(0xffe7eaf4),
                  child: Text(
                    '지중경사계',
                    style: TextStyle(
                        fontFamily: 'PretendardGOV',
                        fontWeight: FontWeight.w700,
                        fontSize: 32.sp,
                        color: Color(0xff414c67)),
                  )),
            ],
          ),
          Container(
            width: 2880.w,
            height: 4787.h,
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
                    title: '설치번호(ID) :',
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: inclinometerIdController,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: LabeledDropdownField(
                    title: '설치 위치 :',
                    items: ['추진구', '도달구'],
                    selectedValue: _selectedInclinometerLocation,
                    onChanged: (val) =>
                        setState(() => _selectedInclinometerLocation = val!),
                  ),
                ),
                CustomDivider(),

                SizedBox(
                  height: 16.h,
                ),
                DatePickerField(
                  label: '측정 날짜  :',
                  initialDate: DateTime.tryParse(inclinometerDate ?? ''),
                  onDateSelected: (date) {
                    setState(() {
                      _selectedInclinometerDate = date;
                    });
                  },
                ),
                CustomDivider(),
                //      SizedBox(
                //        width: 2880.w,
                //        height: 85.h,
                //        child: labeledTextField(
                //          title: '측정 심도 :',
                //          hint: '',
                //          width: 420,
                //          height: 60,
                //          textBoxwidth: 400,
                //          textBoxHeight: 50,
                //          controller: inclinometerMeasuredDepthsController,
                //        ),
                //      ),

                //      CustomDivider(),
                //      SizedBox(
                //        width: 2880.w,
                //        height: 85.h,
                //        child: labeledTextField(
                //          title: '측정 간격 :',
                //          hint: '',
                //          width: 420,
                //          height: 60,
                //          textBoxwidth: 400,
                //          textBoxHeight: 50,
                //          controller: inclinometerMeasuredDepthsController,
                //        ),
                //      ),
                Row(
                  children: [
                    SizedBox(
                      width: 41.w,
                    ),
                    Container(
                      width: 192.87.w,
                      height: 50.h,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '측정 심도',
                        style: TextStyle(
                          fontFamily: 'PretendardGOV',
                          fontSize: 36.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 250.h),
                    Container(
                      width: 192.87.w,
                      height: 50.h,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '15m',
                        style: TextStyle(
                          fontFamily: 'PretendardGOV',
                          fontSize: 36.sp,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                CustomDivider(),
                Row(
                  children: [
                    SizedBox(
                      width: 41.w,
                    ),
                    Container(
                      width: 192.87.w,
                      height: 50.h,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '측정 간격',
                        style: TextStyle(
                          fontFamily: 'PretendardGOV',
                          fontSize: 36.sp,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 250.h),
                    Container(
                      width: 192.87.w,
                      height: 50.h,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '0.5m',
                        style: TextStyle(
                          fontFamily: 'PretendardGOV',
                          fontSize: 36.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                CustomDivider(),
// 깊이 입력 헤더
                Padding(
                  padding: EdgeInsets.only(left: 41.w, bottom: 12.h, top: 12.h),
                  child: Text(
                    '깊이(Depth)(m) 입력 :',
                    style: TextStyle(
                      fontFamily: 'PretendardGOV',
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),

// 깊이 입력 리스트
                Column(
                  children: List.generate(31, (index) {
                    final depth = -0.5 * index;
                    final controller = inclinometerDepthValues.putIfAbsent(
                        depth, () => TextEditingController());

                    return Padding(
                      padding: EdgeInsets.only(bottom: 10.h), // 🔸 행 간 간격
                      child: Row(
                        children: [
                          SizedBox(width: 403.w),
                          Container(
                            alignment: Alignment.centerRight,
                            width: 160.w,
                            height: 50.h,
                            child: Text(
                              '${depth.toStringAsFixed(1)}m',
                              style: TextStyle(
                                fontSize: 36.sp,
                                fontFamily: 'PretendardGOV',
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 75.w),
                          Container(
                            width: 230.w,
                            height: 60.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: TextField(
                              controller: controller,
                              style: TextStyle(fontSize: 36.sp),
                              decoration: InputDecoration(
                                hintText: '0.00',
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
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 12.h),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
                SizedBox(height: 5.h),
                Transform.translate(
                    offset: Offset(-1.w, 0),
                    child: Container(
                      color: Color(0xffe7eaf4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ActionButton(
                            '저장',
                            isInclinometerIdValid
                                ? Color(0xff3182ce)
                                : Colors.grey,
                            onTap: isInclinometerIdValid
                                ? () async {
                                    await _saveInclinometer();
                                  }
                                : null,
                          ),
                        ],
                      ),
                    )),
                Transform.translate(
                  offset: Offset(-1.w, -2.h),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    color: Color(0xffe7eaf4),
                    child: Transform.translate(
                        offset: Offset(2.w, 0),
                        child: Container(
                            width: 2881.w,
                            color: Color(0xffe7eaf4),
                            child: Text(
                              '지하수위계',
                              style: TextStyle(
                                  fontFamily: 'PretendardGOV',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 32.sp,
                                  color: Color(0xff414c67)),
                            ))),
                  ),
                ),

                SizedBox(height: 5.h),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '설치번호(ID) :',
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: piezometerIdController,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: LabeledDropdownField(
                    title: '설치 위치 :',
                    items: ['추진구', '도달구'],
                    selectedValue: _selectedPiezometerLocation,
                    onChanged: (val) =>
                        setState(() => _selectedPiezometerLocation = val!),
                  ),
                ),
                CustomDivider(),

                SizedBox(
                  height: 16.h,
                ),
                DatePickerField(
                  label: '측정 날짜  :',
                  initialDate: DateTime.tryParse(piezometerDate ?? ''),
                  onDateSelected: (date) {
                    setState(() {
                      _selectedPiezometerDate = date;
                    });
                  },
                ),
                CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '경과 일수 (일) :',
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: piezometerDryDaysController,
                  ),
                ),
                CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '현재 수위(G.L -m) :',
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: piezometerCurrentWaterLevelController,
                  ),
                ),
                CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '굴착LEVEL(G.L -m) :',
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: piezometerGroundLevelController,
                  ),
                ),
                CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '변화량(m) :',
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: piezometerChangeAmountController,
                  ),
                ),
                CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '누적변위량(m) :',
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: piezometerCumulativeChangeController,
                  ),
                ),
                CustomDivider(),
                Transform.translate(
                  offset: Offset(-1.w, 0),
                  child: Container(
                    color: Color(0xffe7eaf4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ActionButton(
                          '저장',
                          piezometerIdController.text.trim().isNotEmpty
                              ? Color(0xff3182ce)
                              : Colors.grey,
                          onTap: piezometerIdController.text.trim().isNotEmpty
                              ? () async {
                                  await _savePiezometer();
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),

                Transform.translate(
                  offset: Offset(-1.w, -2.h),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    color: Color(0xffe7eaf4),
                    child: Transform.translate(
                        offset: Offset(2.w, 0),
                        child: Container(
                            width: 2881.w,
                            color: Color(0xffe7eaf4),
                            child: Text(
                              '변형률계',
                              style: TextStyle(
                                  fontFamily: 'PretendardGOV',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 32.sp,
                                  color: Color(0xff414c67)),
                            ))),
                  ),
                ),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '설치번호(ID) :',
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: strainGaugeIdController,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: LabeledDropdownField(
                    title: '설치 위치 :',
                    items: ['추진구', '도달구'],
                    selectedValue: _selectedStrainGaugeLocation,
                    onChanged: (val) =>
                        setState(() => _selectedStrainGaugeLocation = val!),
                  ),
                ),
                CustomDivider(),

                SizedBox(
                  height: 16.h,
                ),
                DatePickerField(
                  label: '측정 날짜  :',
                  initialDate: DateTime.tryParse(strainGaugeDate ?? ''),
                  onDateSelected: (date) {
                    setState(() {
                      _selectedStrainGaugeDate = date;
                      /* print('측정날짜는 ? : ${_selectedStrainGaugeDate}');*/
                    });
                  },
                ),
                CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '스트레인 게이지 측정값:',
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: strainGaugeReadingController,
                  ),
                ),
                CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '응력 (kg/cm²) :',
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: strainGaugeStressController,
                  ),
                ),
                CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '굴착 깊이(m):',
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: strainGaugeDepthController,
                  ),
                ),
                CustomDivider(),
                Transform.translate(
                  offset: Offset(-1.w, 0),
                  child: Container(
                    color: Color(0xffe7eaf4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ActionButton(
                          '저장',
                          strainGaugeIdController.text.trim().isNotEmpty
                              ? Color(0xff3182ce)
                              : Colors.grey,
                          onTap: strainGaugeIdController.text.trim().isNotEmpty
                              ? () async {
                                  await _saveStrainGauge();
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),

                Transform.translate(
                  offset: Offset(-1.w, -2.h),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    color: Color(0xffe7eaf4),
                    child: Transform.translate(
                        offset: Offset(2.w, 0),
                        child: Container(
                            width: 2881.w,
                            color: Color(0xffe7eaf4),
                            child: Text(
                              '지표침하계',
                              style: TextStyle(
                                  fontFamily: 'PretendardGOV',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 32.sp,
                                  color: Color(0xff414c67)),
                            ))),
                  ),
                ),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '설치번호(ID) :',
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: settlementGaugeIdController,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: LabeledDropdownField(
                    title: '설치 위치 :',
                    items: ['추진구', '도달구'],
                    selectedValue: _selectedSettlementGaugeLocation,
                    onChanged: (val) =>
                        setState(() => _selectedSettlementGaugeLocation = val!),
                  ),
                ),
                CustomDivider(),

                SizedBox(
                  height: 16.h,
                ),
                DatePickerField(
                  label: '측정 날짜  :',
                  initialDate: DateTime.tryParse(settlementGaugeDate ?? ''),
                  onDateSelected: (date) {
                    _selectedSettlementGaugeDate = date;
                  },
                ),
                SizedBox(
                  height: 16.h,
                ),
                CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '경과 일수 (일):',
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: settlementGaugeDryDaysController,
                  ),
                ),
                CustomDivider(),
                Container(
                  height: 88.h,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      labeledTextField(
                        title: '절대고도 값(m) :',
                        hint: '',
                        width: 420,
                        height: 60,
                        textBoxwidth: 400,
                        textBoxHeight: 50,
                        controller: settlementGaugeAbsoluteValues1,
                      ),
                      SizedBox(
                        width: 200.w,
                      ),
                      labeledTextField(
                        hint: '',
                        width: 420,
                        height: 60,
                        textBoxwidth: 400,
                        textBoxHeight: 50,
                        controller: settlementGaugeAbsoluteValues2,
                      ),
                      SizedBox(
                        width: 200.w,
                      ),
                      labeledTextField(
                        hint: '',
                        width: 420,
                        height: 60,
                        textBoxwidth: 400,
                        textBoxHeight: 50,
                        controller: settlementGaugeAbsoluteValues3,
                      ),
                    ],
                  ),
                ),
                CustomDivider(),
                Container(
                  height: 88.h,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      labeledTextField(
                        title: '침하량 (mm) :',
                        hint: '',
                        width: 420,
                        height: 60,
                        textBoxwidth: 400,
                        textBoxHeight: 50,
                        controller: settlementGaugeSubsidenceValues1,
                      ),
                      SizedBox(
                        width: 200.w,
                      ),
                      labeledTextField(
                        hint: '',
                        width: 420,
                        height: 60,
                        textBoxwidth: 400,
                        textBoxHeight: 50,
                        controller: settlementGaugeSubsidenceValues2,
                      ),
                      SizedBox(
                        width: 200.w,
                      ),
                      labeledTextField(
                        hint: '',
                        width: 420,
                        height: 60,
                        textBoxwidth: 400,
                        textBoxHeight: 50,
                        controller: settlementGaugeSubsidenceValues3,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ActionButton(
                '저장',
                settlementGaugeIdController.text.trim().isNotEmpty
                    ? Color(0xff3182ce)
                    : Colors.grey,
                onTap: settlementGaugeIdController.text.trim().isNotEmpty
                    ? () async {
                        await _saveSettlementGauge();
                      }
                    : null,
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
