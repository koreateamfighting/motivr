import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/component/admin/datepicker_field.dart';
import 'package:iot_dashboard/component/admin/image_picker_text_field.dart';
import 'package:iot_dashboard/component/admin/textfield_section.dart';
import 'package:iot_dashboard/component/admin/action_button.dart';
import 'package:iot_dashboard/component/admin/section_title.dart';
import 'package:iot_dashboard/controller/notice_controller.dart';
import 'package:iot_dashboard/component/common/dialog_form.dart';



class NoticeInputSection extends StatefulWidget {
  final TextEditingController? noticeContentController;




  const NoticeInputSection({
    Key? key,
    this.noticeContentController,

  }) : super(key: key);

  @override
  State<NoticeInputSection> createState() => _NoticeInputSectionState();
}

class _NoticeInputSectionState extends State<NoticeInputSection> {
  bool isExpanded = false; // ✅ 펼침 여부 상태
  late TextEditingController _noticeContentController;

  @override
  void initState() {
    super.initState();
    _noticeContentController = widget.noticeContentController ?? TextEditingController();


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
                '공지 및 주요 일정',
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
            height: 91.h,
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
                    title: '공지 내용 :',
                    hint: '예: 금주 주간 회의는 3월 12일 3시에 진행됩니다.',
                    width: 1260,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: _noticeContentController,
                    onChanged: (_) => setState(() {}), // ✅ 변경 감지 시 UI 갱신
                  ),
                ),



              ],
            ),
          ),

        ],
        SizedBox(height: 5.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ActionButton(
              '추가',
              _noticeContentController.text.trim().isEmpty
                  ? Colors.grey
                  : const Color(0xffe98800),
              onTap: _noticeContentController.text.trim().isEmpty
                  ? null
                  : () async {
                final content = _noticeContentController.text.trim();

                final success = await NoticeController.addNotice(content);
                if (success) {
                  showDialog(
                    context: context,
                    builder: (_) => const DialogForm(
                      mainText: '공지사항이 등록되었습니다.',
                      btnText: '확인',
                      fontSize: 20,
                    ),
                  );

                  setState(() {
                    _noticeContentController.clear();
                  });
                } else {
                  showDialog(
                    context: context,
                    builder: (_) => const DialogForm(
                      mainText: '등록 실패',
                      btnText: '확인',
                      fontSize: 20,
                    ),
                  );
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
