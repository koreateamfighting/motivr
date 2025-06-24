import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LabeledDropdownField extends StatelessWidget {
  final String title;
  final List<String> items;
  final String? selectedValue;
  final void Function(String?) onChanged;
  final double width;
  final double height;
  final double dropdownWidth;
  final double dropdownHeight;

  const LabeledDropdownField({
    Key? key,
    required this.title,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.width = 1260,
    this.height = 60,
    this.dropdownWidth = 420,
    this.dropdownHeight = 60,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.w,
      height: height.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 40.w,),
          SizedBox(
            width: 400.w,
            height: 50.h,
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'PretendardGOV',
                fontSize: 36.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            width: dropdownWidth.w,
            height: dropdownHeight.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedValue,
                isExpanded: true,
                style: TextStyle(
                  fontSize: 32.sp,
                  color: Colors.black,
                  fontFamily: 'PretendardGOV',
                ),
                icon: const Icon(Icons.arrow_drop_down),
                onChanged: onChanged,
                items: items.map<DropdownMenuItem<String>>((String val) {
                  return DropdownMenuItem<String>(
                    value: val,
                    child: Text(val),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
