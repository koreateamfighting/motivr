import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MotionLabelPanel extends StatefulWidget {
  final String camId;
  const MotionLabelPanel({super.key, required this.camId});

  @override
  State<MotionLabelPanel> createState() => _MotionLabelPanelState();
}

class _MotionLabelPanelState extends State<MotionLabelPanel> {
  Map<String, String> labels = {}; // ✅ 수정
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    _timer = Timer.periodic(Duration(milliseconds: 500), (_) async {
      final url = Uri.parse('https://hanlimtwin.kr:5002/motion_status/${widget.camId}');
      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            labels = Map<String, String>.from(data['lines'] ?? {}); // ✅ 수정
          });
        }
      } catch (e) {
        print('모션 상태 요청 실패: $e');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: labels.isEmpty
          ? const Center(
        child: Text('감지된 모션 없음', style: TextStyle(color: Colors.white)),
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: labels.entries.map((entry) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120.w,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: () {
                      final status = entry.value;
                      if (status == 'red') return Colors.red;
                      if (status == 'green') return Colors.green;
                      return Colors.grey;
                    }(),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),


                SizedBox(width: 16.w),
                Text(entry.key,
                    style: TextStyle(
                      fontSize: 28.sp,
                      color: Colors.white,
                      fontFamily: 'PretendardGOV',
                    )),
              ],
            );
          }).toList(),
        )
      ),
    );
  }
}
