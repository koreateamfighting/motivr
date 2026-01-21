import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/component/admin/datepicker_field.dart';
import 'package:iot_dashboard/component/admin/image_picker_text_field.dart';
import 'package:iot_dashboard/component/admin/labeled_textfield_section.dart';
import 'package:iot_dashboard/component/admin/action_button.dart';
import 'package:iot_dashboard/component/admin/section_title.dart';
import 'package:iot_dashboard/theme/colors.dart';
import 'package:iot_dashboard/component/admin/custom_divider.dart';

class IntputAuthSection extends StatefulWidget {
  final TextEditingController? inclinometerIdController;
  final TextEditingController? inclinometerLocationController;
  final String? inclinometerDate;
  final TextEditingController? inclinometerMeasuredDepthsController;
  final Map<double, TextEditingController>? inclinometerDepthValues;

  final TextEditingController? piezometerIdController;
  final TextEditingController? piezometerLocationController;
  final String? piezometerDate;
  final TextEditingController? piezometerDryDaysController;
  final TextEditingController? piezometerCurrentWaterLevelController;
  final TextEditingController? piezometerGroundLevelController;
  final TextEditingController? piezometerChangeAmountController;
  final TextEditingController? piezometerCumulativeChangeController;

  final TextEditingController? strainGaugeIdController;
  final TextEditingController? strainGaugeLocationController;
  final String? strainGaugeDate;
  final TextEditingController? strainGaugeReadingController;
  final TextEditingController? strainGaugeStressController;
  final TextEditingController? strainGaugeDepthController;

  final TextEditingController? settlementGaugeIdController;
  final TextEditingController? settlementGaugeLocationController;
  final String? settlementGaugeDate;
  final TextEditingController? settlementGaugeDryDaysController;
  final TextEditingController? settlementGaugeAbsoluteValues1;
  final TextEditingController? settlementGaugeAbsoluteValues2;
  final TextEditingController? settlementGaugeAbsoluteValues3;
  final TextEditingController? settlementGaugeSubsidenceValues1;
  final TextEditingController? settlementGaugeSubsidenceValues2;
  final TextEditingController? settlementGaugeSubsidenceValues3;

  const IntputAuthSection({
    Key? key,
    this.inclinometerIdController,
    this.inclinometerLocationController,
    this.inclinometerDate,
    this.inclinometerMeasuredDepthsController,
    this.inclinometerDepthValues,
    this.piezometerIdController,
    this.piezometerLocationController,
    this.piezometerDate,
    this.piezometerDryDaysController,
    this.piezometerCurrentWaterLevelController,
    this.piezometerGroundLevelController,
    this.piezometerChangeAmountController,
    this.piezometerCumulativeChangeController,
    this.strainGaugeIdController,
    this.strainGaugeLocationController,
    this.strainGaugeDate,
    this.strainGaugeReadingController,
    this.strainGaugeStressController,
    this.strainGaugeDepthController,
    this.settlementGaugeIdController,
    this.settlementGaugeLocationController,
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
  State<IntputAuthSection> createState() => _IntputAuthSectionState();
}

class _IntputAuthSectionState extends State<IntputAuthSection> {
  bool isExpanded = true;

  late TextEditingController inclinometerIdController;
  late TextEditingController inclinometerLocationController;
  late String? inclinometerDate;
  late TextEditingController inclinometerMeasuredDepthsController;
  late Map<double, TextEditingController> inclinometerDepthValues;

  late TextEditingController piezometerIdController;
  late TextEditingController piezometerLocationController;
  late String? piezometerDate;
  late TextEditingController piezometerDryDaysController;
  late TextEditingController piezometerCurrentWaterLevelController;
  late TextEditingController piezometerGroundLevelController;
  late TextEditingController piezometerChangeAmountController;
  late TextEditingController piezometerCumulativeChangeController;

  late TextEditingController strainGaugeIdController;
  late TextEditingController strainGaugeLocationController;
  late String? strainGaugeDate;
  late TextEditingController strainGaugeReadingController;
  late TextEditingController strainGaugeStressController;
  late TextEditingController strainGaugeDepthController;

  late TextEditingController settlementGaugeIdController;
  late TextEditingController settlementGaugeLocationController;
  late String? settlementGaugeDate;
  late TextEditingController settlementGaugeDryDaysController;
  late TextEditingController settlementGaugeAbsoluteValues1;
  late TextEditingController settlementGaugeAbsoluteValues2;
  late TextEditingController settlementGaugeAbsoluteValues3;
  late TextEditingController settlementGaugeSubsidenceValues1;
  late TextEditingController settlementGaugeSubsidenceValues2;
  late TextEditingController settlementGaugeSubsidenceValues3;

  @override
  void initState() {
    super.initState();

    inclinometerIdController =
        widget.inclinometerIdController ?? TextEditingController();
    inclinometerLocationController =
        widget.inclinometerLocationController ?? TextEditingController();
    inclinometerDate = widget.inclinometerDate;
    inclinometerMeasuredDepthsController =
        widget.inclinometerMeasuredDepthsController ?? TextEditingController();
    inclinometerDepthValues = widget.inclinometerDepthValues ?? {};

    piezometerIdController =
        widget.piezometerIdController ?? TextEditingController();
    piezometerLocationController =
        widget.piezometerLocationController ?? TextEditingController();
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
    strainGaugeLocationController =
        widget.strainGaugeLocationController ?? TextEditingController();
    strainGaugeDate = widget.strainGaugeDate;
    strainGaugeReadingController =
        widget.strainGaugeReadingController ?? TextEditingController();
    strainGaugeStressController =
        widget.strainGaugeStressController ?? TextEditingController();
    strainGaugeDepthController =
        widget.strainGaugeDepthController ?? TextEditingController();

    settlementGaugeIdController =
        widget.settlementGaugeIdController ?? TextEditingController();
    settlementGaugeLocationController =
        widget.settlementGaugeLocationController ?? TextEditingController();
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
                '인증 및 권한',
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
            height: 4697.h,
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
                  ),
                ),
           CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '설치 위치 :',
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: inclinometerLocationController,
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
                    // 여기에 상태 저장 또는 처리 로직
                  },
                ),
           CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '측정 심도 :',
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: inclinometerMeasuredDepthsController,
                  ),
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
                Container(
                  color: Color(0xffe7eaf4),
                  child: Row(
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
                      '지하수위계',
                      style: TextStyle(
                          fontFamily: 'PretendardGOV',
                          fontWeight: FontWeight.w700,
                          fontSize: 32.sp,
                          color: Color(0xff414c67)),
                    )),

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
                  ),
                ),
           CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '설치 위치 :',
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: piezometerLocationController,
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
                    // 여기에 상태 저장 또는 처리 로직
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
                Container(
                  color: Color(0xffe7eaf4),
                  child: Row(
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
                      '변형률계',
                      style: TextStyle(
                          fontFamily: 'PretendardGOV',
                          fontWeight: FontWeight.w700,
                          fontSize: 32.sp,
                          color: Color(0xff414c67)),
                    )),
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
                  ),
                ),
           CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '설치 위치 :',
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: strainGaugeLocationController,
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
                    // 여기에 상태 저장 또는 처리 로직
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
                Container(
                  color: Color(0xffe7eaf4),
                  child: Row(
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
                      '지표침하계',
                      style: TextStyle(
                          fontFamily: 'PretendardGOV',
                          fontWeight: FontWeight.w700,
                          fontSize: 32.sp,
                          color: Color(0xff414c67)),
                    )),
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
                  ),
                ),
           CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '설치 위치 :',
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: settlementGaugeLocationController,
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
                    // 여기에 상태 저장 또는 처리 로직
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
                  child:    Row(
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
                      SizedBox(width: 200.w,),
                      labeledTextField(
                        hint: '',
                        width: 420,
                        height: 60,
                        textBoxwidth: 400,
                        textBoxHeight: 50,
                        controller: settlementGaugeAbsoluteValues2,
                      ),
                      SizedBox(width: 200.w,),
                      labeledTextField(
                        hint: '',
                        width: 420,
                        height: 60,
                        textBoxwidth: 400,
                        textBoxHeight: 50,
                        controller: settlementGaugeAbsoluteValues3,
                      ),
                    ],
                  ) ,
                ),
           CustomDivider(),
                Container(
                  height: 88.h,
                  alignment: Alignment.centerLeft,
                  child:    Row(
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
                      SizedBox(width: 200.w,),
                      labeledTextField(
                        hint: '',
                        width: 420,
                        height: 60,
                        textBoxwidth: 400,
                        textBoxHeight: 50,
                        controller: settlementGaugeSubsidenceValues2,
                      ),
                      SizedBox(width: 200.w,),
                      labeledTextField(
                        hint: '',
                        width: 420,
                        height: 60,
                        textBoxwidth: 400,
                        textBoxHeight: 50,
                        controller: settlementGaugeSubsidenceValues3,
                      ),
                    ],
                  ) ,
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
