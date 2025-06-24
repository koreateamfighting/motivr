import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/component/admin/datepicker_field.dart';
import 'package:iot_dashboard/component/admin/image_picker_text_field.dart';
import 'package:iot_dashboard/component/admin/textfield_section.dart';
import 'package:iot_dashboard/component/admin/action_button.dart';
import 'package:iot_dashboard/component/admin/section_title.dart';
import 'package:iot_dashboard/component/admin/custom_divider.dart';


class CCTVInputSection extends StatefulWidget {
  final TextEditingController? cctvProductIDController;
  final TextEditingController? cctvLocationController;
  final TextEditingController? isConnectedController;
  final TextEditingController? cctvEventController;
  final TextEditingController? imageAnalysisController;
  final TextEditingController? cctvAddressController;
  final String? lastReceive;


  const CCTVInputSection({
    Key? key,
    this.cctvProductIDController,
    this.cctvLocationController,
    this.isConnectedController,
    this.cctvEventController,
    this.imageAnalysisController,
    this.cctvAddressController,
    this.lastReceive,
  }) : super(key: key);

  @override
  State<CCTVInputSection> createState() => _CCTVInputSectionState();
}

class _CCTVInputSectionState extends State<CCTVInputSection> {
  bool isExpanded = false; // ✅ 펼침 여부 상태

  late TextEditingController cctvProductIDController;
  late TextEditingController cctvLocationController;
  late TextEditingController isConnectedController;
  late TextEditingController cctvEventController;
  late TextEditingController imageAnalysisController;
  late TextEditingController cctvAddressController;
  late String? lastReceive;

  @override
  void initState() {
    super.initState();

    cctvProductIDController =
        widget.cctvProductIDController ?? TextEditingController();
    cctvLocationController =
        widget.cctvLocationController ?? TextEditingController();
    isConnectedController =
        widget.isConnectedController ?? TextEditingController();
    cctvEventController =
        widget.cctvEventController ?? TextEditingController();
    imageAnalysisController =
        widget.imageAnalysisController ?? TextEditingController();
    cctvAddressController =
        widget.cctvAddressController ?? TextEditingController();
    lastReceive =
        widget.lastReceive ;
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
                'CCTV 정보 입력',
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
            height: 616.h,
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
                    title: '제품 식별자(ID) :',
                    hint: 'S1_001',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: cctvProductIDController,
                  ),
                ),
           CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '설치 위치(추진구/도달구) :',
                    hint: '추진구',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: cctvProductIDController,
                  ),
                ),
           CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '연결 :',
                    hint: '정상',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: isConnectedController,
                  ),
                ),
           CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '이벤트 :',
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: cctvEventController,
                  ),
                ),
           CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '이미지 분석 :',
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: imageAnalysisController,
                  ),
                ),
           CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '주소 :',
                    hint: '',
                    width: 1260,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: cctvAddressController,
                  ),
                ),
           CustomDivider(),
                SizedBox(height: 16.h,),
                DatePickerField(
                  label: '마지막계측 :',
                  initialDate: DateTime.tryParse( lastReceive?? ''),
                  onDateSelected: (date) {

                  },
                ),

              ],
            ),
          ),

        ],
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
    );
  }
}
