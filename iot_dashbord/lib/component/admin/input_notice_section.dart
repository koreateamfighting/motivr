import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/component/admin/datepicker_field.dart';
import 'package:iot_dashboard/component/admin/image_picker_text_field.dart';
import 'package:iot_dashboard/component/admin/labeled_textfield_section.dart';
import 'package:iot_dashboard/component/admin/action_button.dart';
import 'package:iot_dashboard/component/admin/section_title.dart';
import 'package:iot_dashboard/controller/notice_controller.dart';
import 'package:iot_dashboard/component/common/dialog_form.dart';
import 'package:iot_dashboard/component/admin/time_picker_row.dart';
import 'package:iot_dashboard/component/admin/custom_divider.dart';


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
  late String? _noticeDate;
  late String? _noticeHour;
  late String? _noticeMinute;
  late String? _noticeSecond;

  @override
  void initState() {
    super.initState();
    _noticeContentController = widget.noticeContentController ?? TextEditingController();
    _noticeDate = null;
    _noticeHour = '00';
    _noticeMinute = '00';
    _noticeSecond = '00';


  }

  DateTime? _composeTimestamp(String? dateStr, String? hour, String? minute, String? second) {
    try {
      if (dateStr == null || dateStr.isEmpty) return null;
      final paddedHour = hour?.padLeft(2, '0') ?? '00';
      final paddedMinute = minute?.padLeft(2, '0') ?? '00';
      final paddedSecond = second?.padLeft(2, '0') ?? '00';
      return DateTime.parse('${dateStr}T$paddedHour:$paddedMinute:$paddedSecond').toLocal();
    } catch (_) {
      return null;
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
            height: 270.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.r),
              color: const Color(0xff414c67),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 2880.w,
                  height: 180.h, // 기존 85.h → 3줄 정도의 높이로 늘림
                  child: labeledTextField(
                    title: '공지 내용 :',
                    hint: '예: 금주 주간 회의는 3월 12일 3시에 진행됩니다.',
                    width: 1260,
                    height: 150, // 입력창 자체 높이도 늘림
                    textBoxwidth: 400,
                    textBoxHeight: 150, // 높이를 늘려줘야 maxLines가 반영됨
                    controller: _noticeContentController,
                    onChanged: (_) => setState(() {}),
                    minLines: 3,
                    maxLines: null,// ✅ 변경 감지 시 UI 갱신
                  ),
                ),
                CustomDivider(),
                Row(
                  children: [
                    DatePickerField(
                      label: '날짜/시간 :',
                      initialDate: DateTime.tryParse(_noticeDate ?? ''),
                      onDateSelected: (date) {
                        setState(() {
                          _noticeDate = date.toIso8601String().substring(0, 10);
                        });
                      },
                    ),
                    SizedBox(width: 43.15.w),
                    TimePickerRow(
                      selectedHour: _noticeHour,
                      selectedMinute: _noticeMinute,
                      selectedSecond: _noticeSecond,
                      onHourChanged: (val) => setState(() => _noticeHour = val),
                      onMinuteChanged: (val) => setState(() => _noticeMinute = val),
                      onSecondChanged: (val) => setState(() => _noticeSecond = val),
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
            ActionButton(
              '등록',
              _noticeContentController.text.trim().isEmpty
                  ? Colors.grey
                  : const Color(0xffe98800),
              onTap: _noticeContentController.text.trim().isEmpty
                  ? null
                  : () async {
                final content = _noticeContentController.text.trim();

                final timestamp = _composeTimestamp(
                  _noticeDate,
                  _noticeHour,
                  _noticeMinute,
                  _noticeSecond,
                ) ?? DateTime.now().toLocal().add(Duration(hours: 0)); // ⏱ KST 대입


                if (timestamp == null) {
                  showDialog(
                    context: context,
                    builder: (_) => const DialogForm(
                      mainText: '날짜 또는 시간 형식이 잘못되었습니다.',
                      btnText: '확인',
                      fontSize: 20,
                    ),
                  );
                  return;
                }

                final createdAt = timestamp.toIso8601String();

                final success = await NoticeController.addNotice(content, createdAt);

                showDialog(
                  context: context,
                  builder: (_) => DialogForm(
                    mainText: success ? '공지사항이 등록되었습니다.' : '등록 실패',
                    btnText: '확인',
                    fontSize: 20,
                  ),
                );

                if (success) {
                  setState(() {
                    _noticeContentController.clear();
                    _noticeDate = null;
                    _noticeHour = '00';
                    _noticeMinute = '00';
                    _noticeSecond = '00';
                  });
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
