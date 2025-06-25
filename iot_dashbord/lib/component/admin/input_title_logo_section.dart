// input_title_logo_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/component/admin/custom_divider.dart';
import 'package:iot_dashboard/component/admin/image_picker_text_field.dart';
import 'package:iot_dashboard/component/admin/action_button.dart';
import 'package:iot_dashboard/component/admin/labeled_textfield_section.dart';
import 'package:iot_dashboard/component/admin/section_title.dart';
import 'dart:html' as html;
import 'package:iot_dashboard/component/admin/custom_divider.dart';
import 'package:iot_dashboard/utils/setting_service.dart';
import 'package:iot_dashboard/controller/setting_controller.dart';
import 'package:iot_dashboard/component/common/dialog_form.dart';

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

  bool isExpanded = false;
  bool isEditing = false;
  html.File? selectedLogoFile;
  String? logoUrl; // ← ✅ 여기에 선언 추가



  String? initialTitle;
  String? initialLogoFileName;


  @override
  void initState() {
    super.initState();
    _loadInitialSetting();
    widget.titleController.addListener(_handleChange);
  }

  void _handleChange() {
    final currentTitle = widget.titleController.text.trim();
    if (isEditing && currentTitle != initialTitle) {
      setState(() {}); // 버튼 텍스트를 업데이트하기 위해
    }
  }
  Future<void> _loadInitialSetting() async {
    final setting = await SettingController.fetchLatestSetting();
    if (setting != null) {
      final fileName = _extractFileName(setting.logoUrl);
      setState(() {
        logoUrl = setting.logoUrl;
        initialTitle = setting.title;
        initialLogoFileName = fileName;
        widget.titleController.text = setting.title;
      });
    }
  }

  String _extractFileName(String path) {
    return path.split('/').last;
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
                    enabled: isEditing,
                  ),
                ),
                CustomDivider(),
                SizedBox(height: 16.h),
                ImagePickerTextField(
                  title: '로고 변경 :',
                  hint: '예: 이미지 파일을 업로드 하세요',
                  width: 1260,
                  height: 60,
                  initialFileName: logoUrl != null ? _extractFileName(logoUrl!) : null,
                  onFileSelected: (file) {
                    selectedLogoFile = file;
                    widget.onLogoSelected(file);
                  },
                  enabled: isEditing,
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
              isEditing ? '저장' : '수정',
              isEditing ? const Color(0xff3182ce) : const Color(0xff4ead8b),
              onTap: () async {
                if (!isEditing) {
                  setState(() {
                    isEditing = true;
                  });
                  return;
                }
                final currentTitle = widget.titleController.text.trim();
                final selectedFileName = selectedLogoFile?.name;

                final isTitleChanged = currentTitle != initialTitle;
                final isLogoChanged = selectedFileName != null &&
                    selectedFileName != initialLogoFileName;

                if (!isTitleChanged && !isLogoChanged) {
                  showDialog(
                    context: context,
                    builder: (_) => const DialogForm(
                      mainText: '변경된 내용이 없습니다.',
                      btnText: '확인',
                      fontSize: 20,
                    ),
                  );
                  return;
                }

                final result = await SettingController.uploadTitleAndLogo(
                  currentTitle,
                  selectedLogoFile,
                );

                if (result.success) {
                  showDialog(
                    context: context,
                    builder: (_) => const DialogForm(
                      mainText: '저장되었습니다.',
                      btnText: '확인',
                      fontSize: 20,
                    ),
                  );
                  await SettingService.refresh(); // TopAppBar 갱신

                  // ✅ 변경된 값 저장
                  setState(() {
                    initialTitle = currentTitle;
                    initialLogoFileName = selectedFileName;
                  });
                } else {
                  print('❌ ${result.message}');
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
