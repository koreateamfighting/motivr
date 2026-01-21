import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/component/admin/datepicker_field.dart';
import 'package:iot_dashboard/component/admin/image_picker_text_field.dart';
import 'package:iot_dashboard/component/admin/labeled_textfield_section.dart';
import 'package:iot_dashboard/component/admin/action_button.dart';
import 'package:iot_dashboard/component/admin/section_title.dart';
import 'package:iot_dashboard/component/admin/custom_divider.dart';
import 'package:iot_dashboard/controller/duty_controller.dart';
import 'package:iot_dashboard/model/duty_model.dart';
import 'package:iot_dashboard/component/common/dialog_form.dart';


class DutySection extends StatefulWidget {
  final TextEditingController dutyNameController;
  final String? dutyStartDate;
  final String? dutyEndDate;
  final TextEditingController? progressController;

  const DutySection(
      {Key? key,
      required this.dutyNameController,
      this.dutyStartDate,
      this.dutyEndDate,
      this.progressController})
      : super(key: key);

  @override
  State<DutySection> createState() => _DutySectionState();
}

class _DutySectionState extends State<DutySection> {
  bool isExpanded = false; // ✅ 펼침 여부 상태
  bool isEditing = false;

  DateTime? startDate;
  DateTime? endDate;


  @override
  void initState() {
    super.initState();
    _loadLatestDuty();
  }
  Future<void> _loadLatestDuty() async {
    final duty = await DutyController.fetchLatestDuty();
    if (duty != null) {
      widget.dutyNameController.text = duty.dutyName;
      widget.progressController?.text = duty.progress.toString();
      setState(() {
        startDate = duty.startDate;
        endDate = duty.endDate;
      });
    }
  }

  Future<void> _saveDuty() async {
    final name = widget.dutyNameController.text.trim();
    final progress = int.tryParse(widget.progressController?.text ?? '');
    if (name.isEmpty || startDate == null || endDate == null || progress == null) {
      showDialog(
        context: context,
        builder: (_) => const DialogForm(
          mainText: '입력값이 누락되었습니다.',
          btnText: '확인',
          fontSize: 20,
        ),
      );
      return;
    }

    final result = await DutyController.updateLatestDuty(
      Duty(
        id: 0, // 서버에서 최신 Id를 찾기 때문에 의미 없음
        dutyName: name,
        startDate: startDate!,
        endDate: endDate!,
        progress: progress,
      ),
    );

    if (result) {
      showDialog(
        context: context,
        builder: (_) => const DialogForm(
          mainText: '저장되었습니다.',
          btnText: '확인',
          fontSize: 20,
        ),
      );
      setState(() => isEditing = false);
    } else {
      showDialog(
        context: context,
        builder: (_) => const DialogForm(
          mainText: '저장 실패',
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
                    enabled: isEditing, // 🔸 편집 가능 여부
                  ),
                ),
                CustomDivider(),
                SizedBox(height: 16.h),
                DatePickerField(
                  label: '시작일 :',
                  initialDate: startDate, // ⬅️ 이 부분 변경
                  onDateSelected: (date) {
                    setState(() {
                      startDate = date; // ⬅️ 선택된 날짜 저장
                    });
                  },
                  enabled: isEditing,
                ),
                CustomDivider(),
                SizedBox(height: 16.h),
                DatePickerField(
                  label: '종료일 :',
                  initialDate: endDate, // ⬅️ 이 부분 변경
                  onDateSelected: (date) {
                    setState(() {
                      endDate = date; // ⬅️ 선택된 날짜 저장
                    });
                  },
                  enabled: isEditing,
                ),
                CustomDivider(),
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
                    enabled: isEditing, // 🔸 편집 가능 여부
                  ),
                ),
              ],
            ),
          ),
        ],
        SizedBox(height: 5.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children:  [
            ActionButton(
              isEditing ? '완료' : '수정',
              isEditing ? const Color(0xff3182ce) : const Color(0xff4ead8b),
              onTap: () {
                if (isEditing) {
                  _saveDuty();
                } else {
                  setState(() => isEditing = true);
                }
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
