import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/controller/cctv_controller.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:iot_dashboard/controller/alarm_history_controller.dart';
import 'package:iot_dashboard/state/alarm_history_state.dart';
import 'dart:async';
class CctvLog extends StatefulWidget {
  const CctvLog({super.key});

  @override
  State<CctvLog> createState() => _CctvLogState();
}

class _CctvLogState extends State<CctvLog> {
  final Set<String> _alreadyLogged = {}; // 중복 전송 방지용

  Timer? _timer;
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<CctvController>().fetchCctvs();
    });

    // ✅ 10분마다 자동 갱신
    _timer = Timer.periodic(Duration(minutes: 10), (_) {
      context.read<CctvController>().fetchCctvs();
      context.read<AlarmHistoryState>().triggerRefresh(); // 재빌드 유도
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
    final cctvs = context.watch<CctvController>().items;
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    final logs = cctvs.map((e) {
      // 1. UTC로 파싱된 것을 KST로 변환해서 출력
      final timestamp = dateFormat.format(e.lastRecorded.toLocal());

      final cam = e.camId;

      final statusMsg = e.isConnected == false
          ? '[$cam]영상 이미지 수집 성공'
          : '[$cam]영상 이미지 수집 실패'; // ✅ 조건 반영
      if (!_alreadyLogged.contains(cam)) {
        _alreadyLogged.add(cam);
        Future.microtask(() async {
          await AlarmHistoryController.logCctvStatus(
            camId: cam,
            isConnected: e.isConnected,
          );
        });
      }

      return {'time': timestamp, 'message': statusMsg};
    }).toList();
// ✅ 디버깅 로그 추가

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
          // 🔷 로그 영역 (2줄 고정 + 스크롤)
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
                :Container(
              child: Scrollbar(
                thumbVisibility: true, // 👈 항상 스크롤바 보이도록
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: logs.length,
                  shrinkWrap: true, // 작은 공간에서도 잘 렌더링
                  primary: false,   // 다른 스크롤뷰와 충돌 방지
                  physics: const AlwaysScrollableScrollPhysics(),
                  separatorBuilder: (_, __) => Container(
                    height: 1.h,
                    color: Colors.white,
                  ),
                  itemBuilder: (context, index) {
                    final time = logs[index]['time']!;
                    final message = logs[index]['message']!;
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
            )
            ,
          ),
        ],
      ),
    );
  }
}
