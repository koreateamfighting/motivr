import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MotionLabelPanel extends StatefulWidget {
  final String camId;
  const MotionLabelPanel({super.key, required this.camId});

  @override
  State<MotionLabelPanel> createState() => _MotionLabelPanelState();
}

class _MotionLabelPanelState extends State<MotionLabelPanel> {
  Map<String, bool> labels = {};
  WebSocket? _socket;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  void _connectWebSocket() async {
    final url = 'wss://hanlimtwin.kr:8443/ws/${widget.camId}';
    try {
      _socket = await WebSocket.connect(url);
      _subscription = _socket!.listen((event) {
        final data = jsonDecode(event);
        setState(() {
          labels = Map<String, bool>.from(data['lines'] ?? {});
        });
      });
    } catch (e) {
      print("WebSocket 연결 오류: $e");
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _socket?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: labels.isEmpty
          ? const Center(
        child: Text(
          '감지된 모션 없음',
          style: TextStyle(color: Colors.white),
        ),
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: labels.entries.map((entry) {
          return Row(
            children: [
              Icon(
                Icons.circle,
                size: 14.w,
                color: entry.value ? Colors.green : Colors.grey,
              ),
              SizedBox(width: 8.w),
              Text(
                entry.key,
                style: TextStyle(
                  fontSize: 28.sp,
                  color: Colors.white,
                  fontFamily: 'PretendardGOV',
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
