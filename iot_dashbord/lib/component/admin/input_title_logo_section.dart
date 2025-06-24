// input_title_logo_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/component/admin/image_picker_text_field.dart';
import 'package:iot_dashboard/component/admin/action_button.dart';
import 'package:iot_dashboard/component/admin/textfield_section.dart';
import 'package:iot_dashboard/component/admin/section_title.dart';
import 'dart:html' as html;

class TitleLogoSection extends StatefulWidget {
  final TextEditingController titleController;
  final void Function(html.File?) onLogoSelected;

  const TitleLogoSection({
    Key? key,
    required this.titleController,
    required this.onLogoSelected,
  }) : super(key: key);

  @override
  State<TitleLogoSection> createState() => _TitleLogoSectionState();
}

class _TitleLogoSectionState extends State<TitleLogoSection> {
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
                '전체 타이틀',
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
            height: 181.h,
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
                    title: '타이틀 이름 :',
                    hint: '예: Digital Twin EMS > 스마트 안전 시스템',
                    width: 1260,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: widget.titleController,
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
                ImagePickerTextField(
                  title: '로고 변경 :',
                  hint: '예: 이미지 파일을 업로드 하세요',
                  width: 1260,
                  height: 60,
                  onFileSelected: widget.onLogoSelected,
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
