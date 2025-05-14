import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WeatherInfoBar extends StatelessWidget {
  const WeatherInfoBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 790.w,
      padding: EdgeInsets.fromLTRB(0,8.0.h,0,8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _weatherItem(Icons.thermostat, '24°C'),

          _weatherItem(Icons.water_drop_outlined, '20%'),

          _weatherItem(Icons.air, '1.3m/s'),

          _weatherItem(Icons.speed, '1024hPa'),

          _weatherItem(Icons.monitor_heart_outlined, '68bpm'),
        ],
      ),
    );
  }

  Widget _weatherItem(IconData icon, String value) {
    return Container(
      width: 140.w,
      height: 100.h,
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: const Color(0xFF091427),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 27.6.w,
              height: 33.18.h,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Icon(
                  icon,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 24.sp,
                color: Colors.white,
                fontFamily: 'PretendardGOV',
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
