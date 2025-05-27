import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NoticeSection extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onTap;

  const NoticeSection({
    super.key,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 항상 보이는 헤더
        InkWell(
          onTap: onTap,
          child: Container(
            height: 50.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            color: Colors.transparent,
            child: Row(
              children: [
                Icon(Icons.announcement, color: Colors.white),
                SizedBox(width: 8.w),
                Text('공지 및 주요 일정',
                    style: TextStyle(
                        fontSize: 24.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w500)),
                Spacer(),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                  color: Colors.white,
                )
              ],
            ),
          ),
        ),
        if (isExpanded)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            height: 220.h,
            child: ListView(
              children: const [
                NoticeRowWidget(
                    '작업 일정 조정 안내', '2025-04-22', '2025-04-23'),
                NoticeRowWidget('안전 교육 일정', '2025-04-24', '2025-04-25'),
                NoticeRowWidget('정기 점검 공지', '2025-04-26', '2025-04-27'),
                NoticeRowWidget(
                    '작업 일정 조정 안내', '2025-04-22', '2025-04-23'),
                NoticeRowWidget('안전 교육 일정', '2025-04-24', '2025-04-25'),
                NoticeRowWidget('정기 점검 공지', '2025-04-26', '2025-04-27'),
              ],
            ),
          ),
      ],
    );
  }
}

class NoticeRowWidget extends StatelessWidget {
  final String title;
  final String start;
  final String end;

  const NoticeRowWidget(this.title, this.start, this.end, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text(title, style: TextStyle(color: Colors.white))),
          Expanded(flex: 3, child: Text(start, style: TextStyle(color: Colors.white))),
          Expanded(flex: 3, child: Text(end, style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}
