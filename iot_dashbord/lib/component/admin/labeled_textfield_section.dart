import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/theme/colors.dart';
import 'package:flutter/services.dart';

Widget labeledTextField(
    {final String? title,
      String? hint,
      required double width,
      required double height,
      required double textBoxwidth,
      required double textBoxHeight,
      TextEditingController? controller,
    bool enabled = true,  bool isNumeric = false, Function(String)? onChanged,  int? minLines,        // ✅ 추가
int? maxLines,        }) {
  ScreenUtil.ensureScreenSize();
  final isDisabled = !enabled;
  return Container(
    child: Row(
      children: [
        if( title != null) ...[
          SizedBox(
            width: 41.w,
          ),
          Container(
            width: textBoxwidth.w,
            height: textBoxHeight.h,
            alignment: Alignment.centerLeft,
            child: Text(
              title!,
              style: TextStyle(
                fontFamily: 'PretendardGOV',
                fontSize: 36.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 12.h),
        ],
        Container(
            width: width.w,
            height: height.h,
            child: TextField(
              enabled: enabled,
              controller: controller,
              onChanged: onChanged,
              maxLines: maxLines,
              minLines: minLines,
              keyboardType: isNumeric
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.multiline, // ✅ multiline 설정
              inputFormatters: isNumeric
                  ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
                  : null,
              style: TextStyle(
                fontSize: 36.sp,
                color: isDisabled ? Colors.grey.shade600 : Colors.black,
                fontFamily: 'PretendardGOV',
              ),
              decoration: InputDecoration(
                hintText: hint ?? '',
                hintStyle: TextStyle(
                    color: Color(0xff9eaea2),
                    fontSize: 36.sp,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'PretendardGOV'),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                    color: isDisabled ? Colors.grey.shade400 : Colors.white,
                  ),
                ),
                focusedBorder: enabled ? AppColors.focusedBorder(2.w) : null,
                // ✅ 여기에 적용
                contentPadding:
                EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
              ),
            )),
      ],
    ),
  );
}