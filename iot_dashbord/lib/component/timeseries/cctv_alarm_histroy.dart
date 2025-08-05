// cctv_alarm_history.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/controller/alarm_history_controller.dart';
import 'package:iot_dashboard/model/alarm_history_model.dart';
import 'package:intl/intl.dart';

class CCTVAlarmHistory extends StatefulWidget {
  final void Function(String) onDeviceSelected;

  const CCTVAlarmHistory({super.key, required this.onDeviceSelected});

  @override
  State<CCTVAlarmHistory> createState() => _CCTVAlarmHistoryState();
}

class _CCTVAlarmHistoryState extends State<CCTVAlarmHistory> {
  final ScrollController _scrollController = ScrollController();
  List<AlarmHistory> alarms = [];
  String selectedDeviceId = '';

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    final result = await AlarmHistoryController.fetchCctvAlarmHistory();
    setState(() {
      alarms = result;
      if (alarms.isNotEmpty) {
        selectedDeviceId = alarms.first.deviceId;
        widget.onDeviceSelected(selectedDeviceId);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.ensureScreenSize();

    return Container(
      width: 735.w,
      height: 1645.h,
      decoration: BoxDecoration(
        color: Color(0xff0b1437),
        borderRadius: BorderRadius.circular(5.r),
        border: Border.all(color: Color(0xff414c67), width: 4.w),
      ),
      padding: EdgeInsets.only(top: 10.h, left: 4.w),
      child: Row(
        children: [
          Expanded(
            child: ScrollbarTheme(
              data: ScrollbarThemeData(
                thumbColor: MaterialStateProperty.all(Color(0xff004aff)),
                trackColor: MaterialStateProperty.all(Colors.white),
                radius: Radius.circular(10.r),
                thickness: MaterialStateProperty.all(10.w),
              ),
              child: Scrollbar(
                controller: _scrollController,
                thickness: 10.w,
                thumbVisibility: true,
                radius: Radius.circular(5.r),
                trackVisibility: false,
                child: ListView(
                  controller: _scrollController,
                  children: [
                    _buildHeader(),
                    _buildSubHeader(),
                    _buildColumnTitles(),
                    if (alarms.isEmpty)
                      Padding(
                        padding: EdgeInsets.all(30.h),
                        child: Text('CCTV 알람 데이터가 없습니다.',
                            style: TextStyle(fontSize: 28.sp, color: Colors.white70)),
                      )
                    else
                      ...alarms.map(_buildRow).toList(),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 100.h,
      decoration: BoxDecoration(
        color: Color(0xff414c67),
        border: Border(
          top: BorderSide(color: Colors.white, width: 2.w),
          left: BorderSide(color: Colors.white, width: 2.w),
          right: BorderSide(color: Colors.white, width: 2.w),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 12.w),
          Container(
            width: 50.w,
            height: 50.h,
            child: Image.asset('assets/icons/clock2.png'),
          ),
          SizedBox(width: 11.w),
          Container(

            height: 50.h,
            child: Text(
              'CCTV 알람 히스토리',
              style: TextStyle(
                fontSize: 36.sp,
                fontFamily: 'PretendardGOV',
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubHeader() {
    return Container(
      width: double.infinity,
      height: 100.h,
      decoration: BoxDecoration(
        color: Color(0xff3182ce),
        border: Border(
          bottom: BorderSide(color: Colors.white, width: 2.w),
          left: BorderSide(color: Colors.white, width: 2.w),
          right: BorderSide(color: Colors.white, width: 2.w),
        ),
      ),
      child: Center(
         child:    Text('[${selectedDeviceId}]',
         style: TextStyle(fontSize: 36.sp, color: Colors.white, fontWeight: FontWeight.w500)),
      ),
    );
  }
  Widget _buildColumnTitles() {
    return Container(
      width: double.infinity,
      height: 100.h,
      decoration: BoxDecoration(
        color: Color(0xff414c67),
        border: Border(
          top: BorderSide(color: Colors.white, width: 2.w),
          bottom: BorderSide(color: Colors.white, width: 2.w),
          left: BorderSide(color: Colors.white, width: 2.w),
          right: BorderSide(color: Colors.white, width: 2.w),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 12.w),
          Container(
            width: 260.w,
            height: 80.h,
            alignment: Alignment.centerLeft,
            child: Text(
              '날짜/시간',
              style: TextStyle(
                fontSize: 36.sp,
                fontFamily: 'PretendardGOV',
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 181.w),
          Container(
            width: 200.w,
            height: 80.h,
            alignment: Alignment.centerLeft,
            child: Text(
              '이벤트',
              style: TextStyle(
                fontSize: 36.sp,
                fontFamily: 'PretendardGOV',
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildRow(AlarmHistory alarm) {
    final iconWidget = alarm.event == '경고'
        ? Image.asset('assets/icons/alert_warning.png', width: 60.w, height: 60.h)
        : Image.asset('assets/icons/alert_caution.png', width: 60.w, height: 60.h);
    final textColor = alarm.event == '경고' ? Colors.red : Colors.yellow;

    return Container( // ✅ return 추가
      width: double.infinity,
      height: 100.h,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.2), width: 1.w),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Text(
            DateFormat('yyyy-MM-dd HH:mm:ss').format(alarm.timestamp),
            style: TextStyle(
              fontSize: 30.sp,
              color: Colors.white,
              fontFamily: 'PretendardGOV',
            ),
          ),
          SizedBox(width: 100.w),
          iconWidget,
          SizedBox(width: 20.w),
          Container(
            width: 200.w,
            child: Text(
              alarm.event,
              style: TextStyle(
                fontSize: 30.sp,
                color: textColor,
                fontFamily: 'PretendardGOV',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

}