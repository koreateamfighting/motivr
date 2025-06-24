// custom_divider.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomDivider extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const CustomDivider({
    Key? key,
    this.width = 2800,
    this.height = 1,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: width.w,
          height: height.h,
          color: color,
        ),
      ],
    );
  }
}
