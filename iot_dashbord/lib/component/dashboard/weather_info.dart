import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/services/weather_api.dart';
import 'package:iot_dashboard/services/weather_api2.dart';

class WeatherInfo extends StatefulWidget {
  const WeatherInfo({super.key});

  @override
  State<WeatherInfo> createState() => _WeatherInfoState();
}

class _WeatherInfoState extends State<WeatherInfo> {
  String temperature = '--';
  String tempMin = '--';
  String tempMax = '--';
  String humidity = '--';
  String windSpeed = '--';
  String pressure = '--';
  String fineDustPm10 = '--';
  String fineDustPm25 = '--';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    final weather = await WeatherApiService.fetchWeatherData(city: 'Daegu');
    final dust = await FineDustApiService.fetchFineDust(); //  미세먼지 호출
    setState(() {
      temperature = weather['temperature'] ?? '--';
      tempMin = weather['tempMin'] ?? '--';
      tempMax = weather['tempMax'] ?? '--';
      humidity = weather['humidity'] ?? '--';
      windSpeed = weather['windSpeed'] ?? '--';
      pressure = weather['pressure'] ?? '--';
      fineDustPm10 = dust?['pm10'] ?? '--';
      fineDustPm25 = dust?['pm25'] ?? '--';
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 613.w,
      height: 611.h,
      decoration: BoxDecoration(
        color: Color(0xff111c44),
        border: Border.all(
          color: Colors.white,
          width: 1.w,
        ),
        borderRadius: BorderRadius.circular(5.r),
        // child: 이후 실제 위젯 들어갈 수 있도록 구성해둠
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              height: 59.h,
              child: Row(
                children: [
                  SizedBox(
                    width: 24.w,
                  ),
                  Container(
                    width: 30.w,
                    height: 30.h,
                    child: Image.asset('assets/icons/sun.png'),
                  ),
                  SizedBox(
                    width: 12.w,
                  ),
                  Text(
                    '날씨 정보',
                    style: TextStyle(
                        fontFamily: 'PretendardGOV',
                        fontWeight: FontWeight.w500,
                        fontSize: 36.sp,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
            Container(
              width: 1542.w,
              height: 1.h,
              color: Colors.white,
            ),
            SizedBox(
              height: 20.h,
            ),
            Padding(
              padding: EdgeInsets.only(left: 13.w, right: 14.w),
              child: Column(
                children: [
                  Container(
                    width: 586.w,
                    height: 160.h,
                    color: Color(0xff1b254b),
                    child: _weatherItem(
                      '기온',
                      'assets/icons/temprature_icon.png',
                      temperature,
                      tempMin: tempMin,
                      tempMax: tempMax,
                      iconWidth: 19.24.w,
                      iconHeight: 40.h
                    ),
                  ),
                  SizedBox(
                    height: 14.h,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 182.w,
                        height: 160.h,
                        color: Color(0xff1b254b),
                        child: _weatherItem(
                            '습도', 'assets/icons/humidity_icon.png', humidity,       iconWidth: 20.w,                            iconHeight: 30.h),
                      ),
                      Spacer(),
                      Container(
                        width: 182.w,
                        height: 160.h,
                        color: Color(0xff1b254b),
                        child: _weatherItem('풍향/풍속',
                            'assets/icons/wind_speed_icon.png', windSpeed,       iconWidth: 43.23.w,
                            iconHeight: 30.h),
                      ),
                      Spacer(),
                      Container(
                        width: 182.w,
                        height: 160.h,
                        color: Color(0xff1b254b),
                        child: _weatherItem(
                            '기압', 'assets/icons/pressure_icon.png', pressure,       iconWidth: 43.17.w,
                            iconHeight: 30.h),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 18.h,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 279.99.w,
                        height: 166.h,
                        color: Color(0xff1b254b),
                        child: _weatherItem(
                            '미세먼지', 'assets/icons/dust_icon.png', fineDustPm10,       iconWidth: 37.21.w,
                            iconHeight: 40.h),
                      ),
                      Spacer(),
                      Container(
                        width: 279.99.w,
                        height: 166.h,
                        color: Color(0xff1b254b),
                        child: _weatherItem(
                            '초미세먼지', 'assets/icons/dust_icon.png', fineDustPm25,       iconWidth: 37.21.w,
                            iconHeight: 40.h),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

Widget _weatherItem(String typeName, String iconName, String value,{String? tempMin, String? tempMax,  double? iconWidth,    // <- 추가
double? iconHeight}) {
  return Container(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(width: 16.w,),
            Container(
              height: 40.h,
              child: Text(
                typeName,
                style: TextStyle(
                    fontFamily: 'PretendardGOV',
                    fontWeight: FontWeight.w500,
                    fontSize: 24.sp,
                    color: Colors.white),
              ),
            ),
          ],
        ),

        SizedBox(
          height: typeName=='기온' ? 0.h  : 24.2.h,
        ),
        typeName == '기온'
            ? Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 19.24.w,
                        height: 40.h,
                        child: Image.asset(iconName),
                      ),
                      SizedBox(
                        width: 12.w,
                      ),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 36.sp,
                          color: Colors.white,
                          fontFamily: 'PretendardGOV',
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  SizedBox(height: 12.48.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '최저 $tempMin',
                        style: TextStyle(
                          fontSize: 24.sp,
                          color: Color(0xff018dff),
                          fontFamily: 'PretendardGOV',
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      SizedBox(width: 40.w,),
                      Text(
                        '/',
                        style: TextStyle(
                          fontSize: 24.sp,
                          color: Colors.white,
                          fontFamily: 'PretendardGOV',
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      SizedBox(width: 40.w,),
                      Text(
                        '최고 $tempMax',
                        style: TextStyle(
                          fontSize: 24.sp,
                          color: Color(0xffff0000),
                          fontFamily: 'PretendardGOV',
                          fontWeight: FontWeight.w300,
                        ),
                      )
                    ],
                  )
                ],
              ))
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                    SizedBox(height: 12.48.h),
                    Container(
                      width:iconWidth,
                      height: iconHeight,
                      child: Image.asset(iconName),
                    ),
                  ],
                ),
              )
      ],
    ),
  );
}
