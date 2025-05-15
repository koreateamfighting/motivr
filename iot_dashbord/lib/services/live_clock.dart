import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LiveClock extends StatefulWidget {
  const LiveClock({super.key});

  @override
  State<LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<LiveClock> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final date = "${_now.year}.${_now.month.toString().padLeft(2, '0')}.${_now.day.toString().padLeft(2, '0')}";
    final time = "${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')}";

    return Row(
      children: [
        Transform.translate(offset: Offset(0,16.h),child: Icon(Icons.access_time, color: Colors.white, size: 48.sp)),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              date,
              style: TextStyle(
                fontSize: 24.sp,
                fontFamily: 'PretendardGOV',
                fontWeight: FontWeight.w300,
                color: Colors.white,
              ),
            ),
            Text(
              time,
              style: TextStyle(
                fontSize: 39.sp,
                fontFamily: 'PretendardGOV',
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ],
        )
      ],
    );
  }
}
