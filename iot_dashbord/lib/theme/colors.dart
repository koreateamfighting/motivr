import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppColors {

  // 메인 컬러
  static const Color main1 = Color(0xFF272E3F);
  static const Color main2 = Color(0xFF1D222E);
  static const Color main3 = Color(0xFF272E3F);

  // 선택 및 커서
  static const Color cursorSelect = Color(0xFF36ACA0);
  static const Color selectedBackground = Color(0xFF000000);

  // 버튼
  static const Color buttonMain = Color(0xFF5664D2);
  static const Color buttonHover = Color(0xFF11078D);
  static const Color buttonClick = Color(0xFFFFD900);

  // IOT 버튼
  static const Color iotButton = Color(0xFF36ACA0);
  static const Color iotButtonClick = Color(0xFF65E614);

  // 상태 색상
  static const Color statusNormal = Color(0xFF2FA365);
  static const Color statusWarning = Color(0xFFFBD50F);
  static const Color statusDanger = Color(0xFFFF6060);
  static const Color statusCheck = Color(0xFF83C2F2);

  static const cursorColor = Color(0xff3182ce);

  // colors.dart 내에 추가
  static OutlineInputBorder focusedBorder(double width) {
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: Color(0xff3182ce),
        width: width,
      ),
    );
  }

}
