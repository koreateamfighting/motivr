import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controller/alarm_controller.dart';
import '../../model/alarm_model.dart';
import 'package:intl/intl.dart';
import 'package:iot_dashboard/component/dashboard/expand_alarm_search.dart';
import 'package:iot_dashboard/utils/iframe_visibility.dart';
import 'package:iot_dashboard/utils/format_timestamp.dart';
import 'package:iot_dashboard/model/alarm_model.dart';


class AlarmListView extends StatefulWidget {
  const AlarmListView({super.key});

  @override
  State<AlarmListView> createState() => _AlarmListViewState();
}

class _AlarmListViewState extends State<AlarmListView> {
  late Future<List<Alarm>> _alarmFuture;

  @override
  void initState() {
    super.initState();
    _alarmFuture = AlarmController.fetchAlarms(); // ✅ 한 번만 호출
  }

  void _fetchAlarmsData() {
    setState(() {
      _alarmFuture = AlarmController.fetchAlarms(); // ✅ 갱신할 때만 새로고침
    });
  }



  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Alarm>>(future: _alarmFuture, builder: (context, snapshot){
    return Container(
      width: 1168.w,
      height: 610.h,
      decoration: BoxDecoration(
        //color: Color(0xff111c44),
        color: Color(0xff1b254b),
        border: Border.all(
          color: Colors.white,
          width: 1.w,
        ),
        borderRadius: BorderRadius.circular(5.r),
        // child: 이후 실제 위젯 들어갈 수 있도록 구성해둠
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 60.h,
            color: Color(0xff111c44),
            child: Row(
              children: [
                SizedBox(
                  width: 24.w,
                ),
                Container(
                  width: 40.2.w,
                  height: 40.h,
                  child: Image.asset('assets/icons/alarm.png'),
                ),
                SizedBox(
                  width: 5.w,
                ),
                Text(
                  '최근 알람',
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
            height: 1.h,
            color: Colors.white,
          ),

          Container(
            height: 59.h,
            color: Color(0xff0b1437),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 120.48.w,
                  height: 40.h,
                  padding: EdgeInsets.only(top:5.71.h),
                  decoration: BoxDecoration(
                    //color: Color(0xff111c44),
                    color: Color(0xff3182ce),

                    borderRadius: BorderRadius.circular(5.r),
                    // child: 이후 실제 위젯 들어갈 수 있도록 구성해둠
                  ),
                  child: InkWell(
                    onTap: () {
                      hideIframes();
                      showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: '',
                        barrierColor: Colors.black.withOpacity(0.5),
                        transitionDuration: Duration(milliseconds: 200),
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 933.w),
                              child: Material( // ✅ 이게 없으면 버튼 인식이 안 될 수도 있음
                                color: Colors.transparent,
                                child: SizedBox(
                                  width: 2750.w,
                                  height: 1803.h,
                                  child: ExpandAlarmSearch(
                                    onDataUploaded: _fetchAlarmsData,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );





                    },
                    child: Text(
                      '전체 보기',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'PretendardGOV',
                          fontWeight: FontWeight.w400,
                          fontSize: 20.sp,
                          color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(
                  width: 25.52.w,
                )
              ],
            ),
          ),

          Container(
            height: 1.h,
            color: Colors.white,
          ),
          Container(
            height: 59.h,
            decoration: BoxDecoration(
              //color: Color(0xff111c44),
              color: Color(0xff0b1437),
              border: Border(
                bottom: BorderSide(
                  color: Color(0xffd9d9d9), // 선 색상
                  width: 1.w, // 선 두께
                ),
              ),
              borderRadius: BorderRadius.circular(5.r),
              // child: 이후 실제 위젯 들어갈 수 있도록 구성해둠
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [

                SizedBox(width: 25.w,),
                SizedBox(
                    width: 80.32.w,
                    child: Text('시간',
                        overflow: TextOverflow.ellipsis, // 넘치면 "..." 처리
                        maxLines: 1,                      // 최대 한 줄로 제한
                        softWrap: false,                 // 줄바꿈 비활성화
                        style: TextStyle(
                            fontFamily: 'PretendardGOV',
                            fontWeight: FontWeight.w800,
                            fontSize: 24.sp,
                            letterSpacing: -0.2.w,
                            color: Colors.white))),
                SizedBox(width: 320.68.w,),
                SizedBox(
                    width: 60.w,
                    child: Text('유형',
                        style: TextStyle(
                            fontFamily: 'PretendardGOV',
                            fontWeight: FontWeight.w800,
                            fontSize: 24.sp,
                            color: Colors.white))),
                SizedBox(width: 180.w,),
                Expanded(
                    child: Text('메세지',
                        style: TextStyle(
                            fontFamily: 'PretendardGOV',
                            fontWeight: FontWeight.w800,
                            fontSize: 24.sp,
                            color: Colors.white))),
              ],
            ),
          ),
          FutureBuilder<List<Alarm>>(
            future: AlarmController.fetchAlarms(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Expanded(
                    child: Center(child: CircularProgressIndicator(color: Color(0xff3182ce))));
              } else if (snapshot.hasError) {
                return Expanded(
                    child: Center(child: Text('❌ 오류: ${snapshot.error}')));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Expanded(
                    child: Center(
                        child: Text('📭 알람 없음',
                            style: TextStyle(color: Colors.white))));
              }

              final alarms = snapshot.data!.take(7).toList(); // 최신 7건만 표시

              return Expanded(
                child: ListView.separated(
                  itemCount: alarms.length,
                  separatorBuilder: (context, index) => Container(
                    height: 1.h,
                    color: Colors.white,
                  ),
                  itemBuilder: (context, index) {
                    final alarm = alarms[index];
                    return Container(
                      height: 54.h,
                      padding:
                      EdgeInsets.symmetric(horizontal: 8.w),
                      margin: EdgeInsets.symmetric(vertical: 3.h),
                      color: Color(0xff0b1437),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(width: 10.w,),
                          SizedBox(
                              width: 215.w,
                              child: Text(formatTimestamp(alarm.timestamp),
                                  overflow: TextOverflow.ellipsis, // 넘치면 "..." 처리
                                  maxLines: 1,                      // 최대 한 줄로 제한
                                  softWrap: false,                 // 줄바꿈 비활성화
                                  style: TextStyle(
                                      fontFamily: 'PretendardGOV',
                                      fontWeight: FontWeight.w300,
                                      fontSize: 24.sp,
                                      letterSpacing: -0.2.w,
                                      color: Colors.white))),
                          SizedBox(width: 191.w,),
                          SizedBox(
                              width: 48.w,
                              child: Text(alarm.level,
                                  style: TextStyle(
                                      fontFamily: 'PretendardGOV',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 24.sp,
                                      color: Colors.white))),
                          SizedBox(width: 195.w,),
                          SizedBox(
                              child: Text(alarm.message,
                                  style: TextStyle(
                                      fontFamily: 'PretendardGOV',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 24.sp,
                                      color: Colors.white))),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          )
        ],
      ),
    );
    });

  }
}
