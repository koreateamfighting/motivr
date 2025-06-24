import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/component/admin/datepicker_field.dart';
import 'package:iot_dashboard/component/admin/image_picker_text_field.dart';
import 'package:iot_dashboard/component/admin/textfield_section.dart';
import 'package:iot_dashboard/component/admin/action_button.dart';
import 'package:iot_dashboard/component/admin/section_title.dart';
import 'package:iot_dashboard/component/admin/custom_divider.dart';

class FieldInfoSection extends StatefulWidget {
  final TextEditingController? constructionTypeController;
  final TextEditingController? constructionNameController;
  final TextEditingController? constructionAddressController;
  final TextEditingController? constructionCompanyController;
  final TextEditingController? constructionOrdererController;
  final TextEditingController? constructionLocationController;
  final String? constructStartDate;
  final String? constructEndDate;
  final TextEditingController? latitudeController;
  final TextEditingController? longtitudeController;

  const FieldInfoSection({Key? key,
    this.constructionTypeController,
    this.constructionNameController,
    this.constructionAddressController,
    this.constructionCompanyController,
    this.constructionOrdererController,
    this.constructionLocationController,
    this.constructStartDate,
    this.constructEndDate,
    this.latitudeController,
    this.longtitudeController})
      : super(key: key);

  @override
  State<FieldInfoSection> createState() => _FieldInfoSectionState();
}

class _FieldInfoSectionState extends State<FieldInfoSection> {
  bool isExpanded = false; // ✅ 펼침 여부 상태
  late TextEditingController? constructionTypeController;
  late TextEditingController? constructionNameController;
  late TextEditingController? constructionAddressController;
  late TextEditingController? constructionCompanyController;
  late TextEditingController? constructionOrdererController;
  late TextEditingController? constructionLocationController;
  late String? constructStartDate;
  late String? constructEndDate;
  late TextEditingController? latitudeController;
  late TextEditingController? longtitudeController;


  @override
  void initState() {
    super.initState();
    constructionTypeController =
        widget.constructionTypeController ?? TextEditingController();
    constructionNameController =
        widget.constructionNameController ?? TextEditingController();
    constructionAddressController =
        widget.constructionAddressController ?? TextEditingController();
    constructionCompanyController =
        widget.constructionCompanyController ?? TextEditingController();
    constructionOrdererController =
        widget.constructionOrdererController ?? TextEditingController();
    constructionLocationController =
        widget.constructionLocationController ?? TextEditingController();
    latitudeController =
        widget.latitudeController ?? TextEditingController();
    longtitudeController =
        widget.longtitudeController ?? TextEditingController();

    constructStartDate = widget.constructStartDate ;
    constructEndDate = widget.constructEndDate ;
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
                '현장 정보',
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
            height: 688.h,
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
                    title: '공사 종류 :',
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: constructionTypeController,
                  ),
                ),
           CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '공사명 :',
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: constructionNameController,
                  ),
                ),
           CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '현장 주소 :',
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: constructionTypeController,
                  ),
                ),
           CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '시공사 :',
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: constructionTypeController,
                  ),
                ),
           CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '발주처 :',
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: constructionTypeController,
                  ),
                ),
           CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '공사 위치 :',
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: constructionTypeController,
                  ),
                ),
           CustomDivider(),
                Row(
                  children: [
                    DatePickerField(
                      label: '착공일  :',
                      initialDate: DateTime.tryParse(constructStartDate?? ''),
                      onDateSelected: (date) {
                        // 여기에 상태 저장 또는 처리 로직

                      },
                    ),
                    SizedBox(width: 89.29.w,),
                    DatePickerField(
                      label: '준공일  :',
                      initialDate: DateTime.tryParse(constructStartDate?? ''),
                      onDateSelected: (date) {
                        // 여기에 상태 저장 또는 처리 로직

                      },
                    ),
                  ],
                ),

           CustomDivider(),
                Row(
                  children: [
                    SizedBox(
width: 875.w,
                      height: 85.h,
                      child: labeledTextField(
                        title: '기준 위도 :',
                        hint: '',
                        width: 420,
                        height: 60,
                        textBoxwidth: 400,
                        textBoxHeight: 50,
                        controller: constructionTypeController,
                      ),
                    ),
                    SizedBox(width: 200.w,),
                    SizedBox(
                      width: 875.w,
                      height: 85.h,
                      child: labeledTextField(
                        title: '기준 경도 :',
                        hint: '',
                        width: 420,
                        height: 60,
                        textBoxwidth: 400,
                        textBoxHeight: 50,
                        controller: constructionTypeController,
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),

        ],
        SizedBox(height: 5.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ActionButton('변경', Color(0xff4ead8b)),
            SizedBox(width: 18.w),
            ActionButton('저장', Color(0xff3182ce)),
            SizedBox(width: 400.w),
          ],
        ),
        SizedBox(height: 5.h),
      ],
    );
  }
}
