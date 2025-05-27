import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DutySection extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onTap;

  const DutySection({
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
                Icon(Icons.work, color: Colors.white),
                SizedBox(width: 8.w),
                Text('작업명',
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
                DataRowWidget('옹벽 철근 설치', '90%', '2025-04-22', '2025-04-23'),
                DataRowWidget('콘크리트 타일', '75%', '2025-04-23', '2025-04-24'),
                DataRowWidget('배수관 매설', '50%', '2025-04-23', '2025-04-25'),
                DataRowWidget('옹벽 철근 설치', '90%', '2025-04-22', '2025-04-23'),
                DataRowWidget('콘크리트 타일', '75%', '2025-04-23', '2025-04-24'),
                DataRowWidget('배수관 매설', '50%', '2025-04-23', '2025-04-25'),
              ],
            ),
          ),
      ],
    );
  }
}

class DataRowWidget extends StatelessWidget {
  final String task;
  final String progress;
  final String start;
  final String end;

  const DataRowWidget(this.task, this.progress, this.start, this.end,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(task, style: TextStyle(color: Colors.white))),
          Expanded(flex: 2, child: Text(progress, style: TextStyle(color: Colors.white))),
          Expanded(flex: 2, child: Text(start, style: TextStyle(color: Colors.white))),
          Expanded(flex: 2, child: Text(end, style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}
