import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/component/admin/datepicker_field.dart';
import 'package:iot_dashboard/component/admin/image_picker_text_field.dart';
import 'package:iot_dashboard/theme/colors.dart';
import 'package:iot_dashboard/component/admin/labeled_textfield_section.dart';
import 'package:iot_dashboard/component/admin/action_button.dart';
import 'package:iot_dashboard/component/admin/section_title.dart';
import 'package:iot_dashboard/component/admin/custom_divider.dart';
class IotInputSection extends StatefulWidget {
  final TextEditingController? iotProductIDController;
  final TextEditingController? iotLocationController;
  final TextEditingController? iotStatusController;
  final TextEditingController? batteryStatusController;
  final TextEditingController? lastReceiveController;
  final TextEditingController? x_MMController;
  final TextEditingController? y_MMController;
  final TextEditingController? z_MMController;
  final TextEditingController? x_DegController;
  final TextEditingController? y_DegController;
  final TextEditingController? z_DegController;
  final TextEditingController? batteryInfoController;

  const IotInputSection({
    Key? key,
    this.iotProductIDController,
    this.iotLocationController,
    this.iotStatusController,
    this.batteryStatusController,
    this.lastReceiveController,
    this.x_MMController,
    this.y_MMController,
    this.z_MMController,
    this.x_DegController,
    this.y_DegController,
    this.z_DegController,
    this.batteryInfoController,
  }) : super(key: key);

  @override
  State<IotInputSection> createState() => _IotInputSectionState();
}

class _IotInputSectionState extends State<IotInputSection> {
  bool isExpanded = false; // ✅ 펼침 여부 상태

  late TextEditingController iotProductIDController;
  late TextEditingController iotLocationController;
  late TextEditingController iotStatusController;
  late TextEditingController batteryStatusController;
  late TextEditingController lastReceiveController;
  late TextEditingController x_MMController;
  late TextEditingController y_MMController;
  late TextEditingController z_MMController;
  late TextEditingController x_DegController;
  late TextEditingController y_DegController;
  late TextEditingController z_DegController;
  late TextEditingController batteryInfoController;

  @override
  void initState() {
    super.initState();

    iotProductIDController = widget.iotProductIDController ?? TextEditingController();
    iotLocationController =
        widget.iotLocationController ?? TextEditingController();
    iotStatusController = widget.iotStatusController ?? TextEditingController();
    batteryStatusController =
        widget.batteryStatusController ?? TextEditingController();
    lastReceiveController =
        widget.lastReceiveController ?? TextEditingController();
    x_MMController = widget.x_MMController ?? TextEditingController();
    y_MMController = widget.y_MMController ?? TextEditingController();
    z_MMController = widget.z_MMController ?? TextEditingController();
    x_DegController = widget.x_DegController ?? TextEditingController();
    y_DegController = widget.y_DegController ?? TextEditingController();
    z_DegController = widget.z_DegController ?? TextEditingController();
    batteryInfoController =
        widget.batteryInfoController ?? TextEditingController();
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
                'IoT 정보 입력(준비중)',
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
            height: 718.h,
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
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: iotProductIDController,
                  ),
                ),
           CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '설치 위치(추진구/도달구) :',
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: iotLocationController,
                  ),
                ),
           CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '상태 :',
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: iotStatusController,
                  ),
                ),
           CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '배터리 :',
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: batteryStatusController,
                  ),
                ),
           CustomDivider(),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '마지막 수신 :',
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: lastReceiveController,
                  ),
                ),
           CustomDivider(),
                SizedBox(
                    width: 2880.w,
                    height: 85.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 40.w,),
                        Container(
                          width: 400.w,
                          height: 50.h,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'X,Y,Z (mm) :',
                            style: TextStyle(
                              fontFamily: 'PretendardGOV',
                              fontSize: 36.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.h),

                        Container(
                            width: 420.w,
                            height: 60.h,
                            child: TextField(
                              controller: x_MMController,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                hintText: '',
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
                                // ✅ 여기에 적용
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 12.h),
                              ),
                            )),
                        SizedBox(
                          width: 200.w,
                        ),
                        Container(
                            width: 420.w,
                            height: 60.h,
                            child: TextField(
                              controller: y_MMController,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                hintText: '',
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
                                // ✅ 여기에 적용
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 12.h),
                              ),
                            )),
                        SizedBox(
                          width: 200.w,
                        ),
                        Container(
                            width: 420.w,
                            height: 60.h,
                            child: TextField(
                              controller: z_MMController,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                hintText: '',
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
                                // ✅ 여기에 적용
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 12.h),
                              ),
                            ))
                      ],
                    )),
           CustomDivider(),
                SizedBox(
                    width: 2880.w,
                    height: 85.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 40.w,),
                        Container(
                          width: 400.w,
                          height: 50.h,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'X,Y,Z (0°) :',
                            style: TextStyle(
                              fontFamily: 'PretendardGOV',
                              fontSize: 36.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.h),

                        Container(
                            width: 420.w,
                            height: 60.h,
                            child: TextField(
                              controller: x_DegController,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                hintText: '',
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
                                // ✅ 여기에 적용
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 12.h),
                              ),
                            )),
                        SizedBox(
                          width: 200.w,
                        ),
                        Container(
                            width: 420.w,
                            height: 60.h,
                            child: TextField(
                              controller: y_DegController,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                hintText: '',
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
                                // ✅ 여기에 적용
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 12.h),
                              ),
                            )),
                        SizedBox(
                          width: 200.w,
                        ),
                        Container(
                            width: 420.w,
                            height: 60.h,
                            child: TextField(
                              controller: z_DegController,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                hintText: '',
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
                                // ✅ 여기에 적용
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 12.h),
                              ),
                            ))
                      ],
                    )),
           CustomDivider(),
                SizedBox(height: 8.h,),
                SizedBox(
                  width: 2880.w,
                  height: 85.h,
                  child: labeledTextField(
                    title: '배터리 정보 :',
                    hint: '',
                    width: 420,
                    height: 60,
                    textBoxwidth: 400,
                    textBoxHeight: 50,
                    controller: batteryStatusController,
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

            ActionButton('추가', Color(0xffe98800)),
            SizedBox(width: 400.w),
          ],
        ),
        SizedBox(height: 5.h),
      ],
    );
  }
}
