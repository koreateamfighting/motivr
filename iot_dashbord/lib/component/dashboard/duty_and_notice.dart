import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controller/alarm_controller.dart';
import '../../model/alarm_model.dart';
import 'package:intl/intl.dart';
import 'duty_section.dart';
import 'notice_section.dart';


class DutyAndNotice extends StatefulWidget {
  const DutyAndNotice({super.key});

  @override
  State<DutyAndNotice> createState() => _DutyAndNoticeState();
}

class _DutyAndNoticeState extends State<DutyAndNotice> {
  bool showDuty = true;
  bool showNotice = false;

  void toggleDuty() {
    setState(() {
      showDuty = true;
      showNotice = false;
    });
  }

  void toggleNotice() {
    setState(() {
      showDuty = false;
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
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Column(
        children: [
          DutySection(isExpanded: showDuty, onTap: toggleDuty),
          NoticeSection(isExpanded: showNotice, onTap: toggleNotice),
        ],
      ),
    );
  }
}
