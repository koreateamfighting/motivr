import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/component/admin/datepicker_field.dart';
import 'package:iot_dashboard/component/admin/image_picker_text_field.dart';
import 'package:iot_dashboard/component/admin/textfield_section.dart';
import 'package:iot_dashboard/component/admin/action_button.dart';
import 'package:iot_dashboard/component/admin/section_title.dart';



class DutySection extends StatefulWidget {
  final TextEditingController dutyNameController;
  final String? dutyStartDate;
  final String? dutyEndDate;
  final TextEditingController? progressController;



  const DutySection({
    Key? key,
    required this.dutyNameController,
    this.dutyStartDate,
    this.dutyEndDate,
    this.progressController
  }) : super(key: key);

  @override
  State<DutySection> createState() => _DutySectionState();
}

class _DutySectionState extends State<DutySection> {
  bool isExpanded = false; // ✅ 펼침 여부 상태


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
                '작업명',
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
            height: 365.h,
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
                    title: '작업명 :',
                    hint: '예: 안심관로공사',
                    width: 1260,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: widget.dutyNameController,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 2800.w,
                      height: 1.h,
                      color: Colors.white,
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                DatePickerField(
                  label: '시작일 :',
                  initialDate: DateTime.tryParse(widget.dutyStartDate ?? ''),
                  onDateSelected: (date) {
                    // 여기에 상태 저장 또는 처리 로직
                    print('선택된 시작일: $date');
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 2800.w,
                      height: 1.h,
                      color: Colors.white,
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                DatePickerField(
                  label: '종료일 :',
                  initialDate: DateTime.tryParse(widget.dutyEndDate ?? ''),
                  onDateSelected: (date) {
                    // 여기에 상태 저장 또는 처리 로직
                    print('선택된 종료일: $date');
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 2800.w,
                      height: 1.h,
                      color: Colors.white,
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Container(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '공정률(%) :',
                    hint: '%',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: widget.progressController,
                  ),
                ),

              ],
            ),
          ),
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
      ],
    );
  }
}
