import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/controller/alarm_history_controller.dart';
import 'package:iot_dashboard/model/alarm_history_model.dart';
import 'package:iot_dashboard/state/alarm_history_state.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class CctvLog extends StatefulWidget {
  const CctvLog({super.key});

  @override
  State<CctvLog> createState() => _CctvLogState();
}

class _CctvLogState extends State<CctvLog> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // ✅ 10분마다 새로고침 트리거
    _timer = Timer.periodic(Duration(minutes: 10), (_) {
      context.read<AlarmHistoryState>().triggerRefresh();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final refreshTrigger = context.watch<AlarmHistoryState>().refreshCount;

    return FutureBuilder<List<AlarmHistory>>(
      future: AlarmHistoryController.fetchLatestCctvLogs(),
      builder: (context, snapshot) {
        final logs = snapshot.data ?? [];

        return Container(
          width: 881.w,
          decoration: BoxDecoration(
            color: const Color(0xff1b254b),
            border: Border.all(color: Colors.white, width: 1.w),
            borderRadius: BorderRadius.circular(5.r),
          ),
          child: Column(
            children: [
              // 🔷 헤더
              Container(
                height: 50.h,
                child: Row(
                  children: [
                    SizedBox(width: 24.w),
                    SizedBox(
                      width: 30.w,
                      height: 30.h,
                      child: Image.asset('assets/icons/cctv_log.png'),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'CCTV 로그 내역',
                      style: TextStyle(
                        fontFamily: 'PretendardGOV',
                        fontWeight: FontWeight.w500,
                        fontSize: 32.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // 🔷 구분선
              Container(
                width: 881.w,
                height: 1.h,
                color: Colors.white,
              ),
              // 🔷 로그 영역
              Container(
                width: 881.w,
                height: 134.h,
                child: logs.isEmpty
                    ? Center(
                  child: Text(
                    '로그 데이터가 없습니다.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32.sp,
                      fontFamily: 'PretendardGOV',
                    ),
                  ),
                )
                    : Scrollbar(
                  thumbVisibility: true,
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: logs.length,
                    shrinkWrap: true,
                    primary: false,
                    physics: const AlwaysScrollableScrollPhysics(),
                    separatorBuilder: (_, __) => Container(
                      height: 1.h,
                      color: Colors.white,
                    ),
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      final time = DateFormat('yyyy-MM-dd HH:mm').format(log.timestamp);
                      final message = log.log ?? '';

                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        height: 60.h,
                        child: Row(
                          children: [
                            // 시간
                            Container(
                              width: 333.w,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                time,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontFamily: 'PretendardGOV',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 24.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 51.w),
                            // 메시지
                            Expanded(
                              child: Text(
                                message,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontFamily: 'PretendardGOV',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 24.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
