import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controller/alarm_controller.dart';
import '../../model/alarm_model.dart';
import 'package:intl/intl.dart';
import 'work_task_section.dart';
import 'notice_section.dart';


class WorkTaskAndNotice extends StatefulWidget {
  const WorkTaskAndNotice({super.key});

  @override
  State<WorkTaskAndNotice> createState() => _WorkTaskAndNoticeState();
}

class _WorkTaskAndNoticeState extends State<WorkTaskAndNotice> {
  bool showWorkTask = true;
  bool showNotice = false;

  void toggleWorkTask() {
    setState(() {
      showWorkTask = true;
      showNotice = false;
    });
  }

  void toggleNotice() {
    setState(() {
      showWorkTask = false;
      showNotice = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 987.w,
      height: 602.h,
      decoration: BoxDecoration(
        color: Color(0xff1b254b),
        border: Border.all(color: Colors.white,width: 1.w),
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Column(
        children: [
          WorkTaskSection(isExpanded: showWorkTask, onTap: toggleWorkTask),
          NoticeSection(isExpanded: showNotice, onTap: toggleNotice),
        ],
      ),
    );
  }
}
