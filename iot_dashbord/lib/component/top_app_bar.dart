import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashbord/services/live_clock.dart';
import 'package:iot_dashbord/services/weather_info.dart';
import 'package:iot_dashbord/theme/colors.dart';

class TopAppBar extends StatelessWidget {
  final VoidCallback? onMenuPressed;
  final bool isMenuVisible; // ✅ 추가

  const TopAppBar({
    Key? key,
    this.onMenuPressed,
    required this.isMenuVisible, // ✅ 필수값으로 지정
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3812.w,
      height: 100.h,
      color: const Color(0xff272E3F),
      child: Row(
        children: [
          SizedBox(width: 50.w),
          Transform.translate(
            offset: Offset(0, 0.h),
            child: Transform.scale(
              scale: 4.w,
              child: SizedBox(
                width: 100.w,
                height: 100.h,
                child: IconButton(
                  onPressed: onMenuPressed,
                  icon: const Icon(Icons.menu_rounded),
                  color: isMenuVisible
                      ? const Color(0xFF3CBFAD) // 열렸을 때
                      : Colors.white,           // 닫혔을 때
                ),
              ),
            ),
          ),
          SizedBox(width: 50.w),
          Text(
            'Digital Twin CMS',
            style: TextStyle(
              fontFamily: 'PretendardGOV',
              fontWeight: FontWeight.w800,
              fontSize: 50.sp,
              color: Color(0xffffffff),
            ),
          ),
          SizedBox(width: 1146.w),
          LiveClock(),
          SizedBox(width: 540.w),
          WeatherInfoBar(),
          SizedBox(width: 83.w),
          InkWell(
              onTap: () {},
              child: Container(
                width: 80.w,
                height: 80.h,
                padding: EdgeInsets.fromLTRB(4.0.w,4.0.h,4.0.w,4.0.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF091427),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Image.asset('assets/icons/lock.png',),
              )),
          SizedBox(width: 34.w),
          Expanded( // ✅ 가장 끝까지 밀기 위해 Expanded 사용
            child: Container(
              alignment: Alignment.centerRight, // 내부에서 우측 정렬
              child: Container(
                width: 300.w,
                height: 100.h,
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w,vertical: 8.h), // ✅ 내부 여백 추가
                child: Image.asset(
                  'assets/images/company_logo_small.png',
                  fit: BoxFit.contain, // ✅ 비율 유지하면서 컨테이너 안에 맞춤
                ),
              ),
            ),
          ),


        ],
      ),
    );
  }
}
