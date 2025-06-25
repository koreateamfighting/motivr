import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/component/admin/datepicker_field.dart';
import 'package:iot_dashboard/component/admin/image_picker_text_field.dart';
import 'package:iot_dashboard/component/admin/labeled_textfield_section.dart';
import 'package:iot_dashboard/component/admin/action_button.dart';
import 'package:iot_dashboard/component/admin/section_title.dart';
import 'package:iot_dashboard/component/admin/custom_divider.dart';
import 'package:iot_dashboard/controller/field_info_controller.dart';
import 'package:iot_dashboard/model/field_info_model.dart';
import 'package:iot_dashboard/component/common/dialog_form.dart';
import 'package:intl/intl.dart';  // DateFormat 임포트 추가

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

  const FieldInfoSection({
    Key? key,
    this.constructionTypeController,
    this.constructionNameController,
    this.constructionAddressController,
    this.constructionCompanyController,
    this.constructionOrdererController,
    this.constructionLocationController,
    this.constructStartDate,
    this.constructEndDate,
    this.latitudeController,
    this.longtitudeController,
  }) : super(key: key);


  @override
  State<FieldInfoSection> createState() => _FieldInfoSectionState();
}

class _FieldInfoSectionState extends State<FieldInfoSection> {
  bool isExpanded = false;
  bool isEditing = false;
  bool _isLoading = true; // 로딩 상태 추가

  late TextEditingController constructionTypeController;
  late TextEditingController constructionNameController;
  late TextEditingController constructionAddressController;
  late TextEditingController constructionCompanyController;
  late TextEditingController constructionOrdererController;
  late TextEditingController constructionLocationController;
  DateTime? constructStartDate;
  DateTime? constructEndDate;
  late TextEditingController latitudeController;
  late TextEditingController longtitudeController;

  @override
  void initState() {
    super.initState();

    // 컨트롤러 초기화: 위젯에서 넘어온 게 있으면 사용, 없으면 새로 생성
    constructionTypeController = widget.constructionTypeController ?? TextEditingController();
    constructionNameController = widget.constructionNameController ?? TextEditingController();
    constructionAddressController = widget.constructionAddressController ?? TextEditingController();
    constructionCompanyController = widget.constructionCompanyController ?? TextEditingController();
    constructionOrdererController = widget.constructionOrdererController ?? TextEditingController();
    constructionLocationController = widget.constructionLocationController ?? TextEditingController();
    latitudeController = widget.latitudeController ?? TextEditingController();
    longtitudeController = widget.longtitudeController ?? TextEditingController();

    _fetchLatestFieldInfo();
  }
  void _onAnyFieldChanged() {
    if (!isEditing) {
      setState(() {
        isEditing = true;
      });
    }
  }
  Future<void> _fetchLatestFieldInfo() async {
    try {
      final fieldInfo = await FieldInfoController.fetchLatestFieldInfo();

      if (fieldInfo != null) {
        setState(() {
          constructionTypeController.text = fieldInfo.constructionType;
          constructionNameController.text = fieldInfo.constructionName;
          constructionAddressController.text = fieldInfo.address;
          constructionCompanyController.text = fieldInfo.company;
          constructionOrdererController.text = fieldInfo.orderer;
          constructionLocationController.text = fieldInfo.location;
          latitudeController.text = fieldInfo.latitude;
          longtitudeController.text = fieldInfo.longitude;

          constructStartDate = DateTime.tryParse(fieldInfo.startDate);
          constructEndDate = DateTime.tryParse(fieldInfo.endDate);
        });
      }
    } catch (e) {
      // 에러 로그 찍기 (필요하면 UI에 표시 가능)
      print('FieldInfo fetch error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveFieldInfo() async {
    final success = await FieldInfoController.insertFieldInfo(
      FieldInfo(
        id: 0,
        constructionType: constructionTypeController.text,
        constructionName: constructionNameController.text,
        address: constructionAddressController.text,
        company: constructionCompanyController.text,
        orderer: constructionOrdererController.text,
        location: constructionLocationController.text,
        startDate: constructStartDate != null ? DateFormat('yyyy-MM-dd').format(constructStartDate!) : '',
        endDate: constructEndDate != null ? DateFormat('yyyy-MM-dd').format(constructEndDate!) : '',
        latitude: latitudeController.text,
        longitude: longtitudeController.text,
      ),
    );

    if (success) {
      showDialog(
        context: context,
        builder: (_) => const DialogForm(
          mainText: '현장 정보가 저장되었습니다.',
          btnText: '확인',
          fontSize: 20,
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => const DialogForm(
          mainText: '저장에 실패했습니다.',
          btnText: '닫기',
          fontSize: 20,
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // 로딩 중일 때 로딩 인디케이터 보여주기
      return Center(child: CircularProgressIndicator());
    }

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
                    onChanged: (_) => _onAnyFieldChanged(),
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
                    onChanged: (_) => _onAnyFieldChanged(),
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
                    controller: constructionAddressController,
                    onChanged: (_) => _onAnyFieldChanged(),
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
                    controller: constructionCompanyController,
                    onChanged: (_) => _onAnyFieldChanged(),
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
                    controller: constructionOrdererController,
                    onChanged: (_) => _onAnyFieldChanged(),
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
                    controller: constructionLocationController,
                    onChanged: (_) => _onAnyFieldChanged(),
                  ),
                ),
           CustomDivider(),
                Row(
                  children: [
                    DatePickerField(
                      label: '착공일  :',
                      initialDate: constructStartDate,
                      onDateSelected: (date) {
                        setState(() {
                          constructStartDate = date;
                          isEditing = true; // 날짜 변경도 편집 상태로
                        });
                      },
                    ),

                    SizedBox(width: 89.29.w),
                    DatePickerField(
                      label: '준공일  :',
                      initialDate: constructEndDate,
                      onDateSelected: (date) {
                        setState(() {
                          constructEndDate = date;
                          isEditing = true; // 날짜 변경도 편집 상태로
                        });
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
                        controller: latitudeController,
                        onChanged: (_) => _onAnyFieldChanged(),
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
                        controller: longtitudeController,
                        onChanged: (_) => _onAnyFieldChanged(),
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
            ActionButton(
              isEditing ? '저장' : '수정',
              isEditing ? const Color(0xff3182ce) : const Color(0xff4ead8b),
              onTap: () async {
                if (isEditing) {
                  await _saveFieldInfo();
                }
                setState(() {
                  isEditing = !isEditing;
                });
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
