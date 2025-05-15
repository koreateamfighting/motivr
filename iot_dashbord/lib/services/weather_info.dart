import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashbord/services/weather_api1.dart';
import 'package:iot_dashbord/services/weather_api3.dart';

class WeatherInfoBar extends StatefulWidget {
  const WeatherInfoBar({super.key});

  @override
  State<WeatherInfoBar> createState() => _WeatherInfoBarState();
}

class _WeatherInfoBarState extends State<WeatherInfoBar> {
  String temperature = '--';
  String humidity = '--';
  String windSpeed = '--';
  String pressure = '--';
  String fineDust = '--';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }
  Future<void> _loadWeatherData() async {
    final weather = await WeatherApiService.fetchWeatherData(); // 온도, 습도 , 풍속 호출
    final dust = await FineDustApiService.fetchFineDust(); //  미세먼지 호출
    setState(() {
      temperature = weather['TMP'] ?? '--';
      humidity = weather['REH'] ?? '--';
      windSpeed = weather['WSD'] ?? '--';
      fineDust = dust ?? '--';
      isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      width: 790.w,
      padding: EdgeInsets.fromLTRB(0, 8.0.h, 0, 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _weatherItem('assets/icons/temprature_icon.png', temperature),
          _weatherItem('assets/icons/humidity_icon.png', humidity),
          _weatherItem('assets/icons/wind_speed_icon.png', windSpeed),
          _weatherItem('assets/icons/pressure_icon.png', '1024hPa'), //기압 추후 적용
          _weatherItem('assets/icons/dust_icon.png', fineDust),
        ],
      ),
    );
  }

  Widget _weatherItem(String iconName, String value) {
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
            Container(
              height: 28.h,
              child: Image.asset(iconName),
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
