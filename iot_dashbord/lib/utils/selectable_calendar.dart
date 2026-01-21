import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectableCalendar extends StatefulWidget {

  final void Function(DateTime? start, DateTime? end)? onDateSelected;
  final bool autoClose; // 🔹 추가
  const SelectableCalendar({
    super.key,
    this.onDateSelected,
    this.autoClose = false, // 기본값: false
  });

  @override
  State<SelectableCalendar> createState() => _SelectableCalendarState();
}

class _SelectableCalendarState extends State<SelectableCalendar> {
  DateTime currentMonth = DateTime.now();
  DateTime? firstSelected;
  DateTime? secondSelected;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final year = currentMonth.year;
    final month = currentMonth.month;
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final firstWeekday = DateTime(year, month, 1).weekday;


    return Container(
      width: 650.w,
      height: 742.h,
      decoration: BoxDecoration(
        color: Color(0xff414c67),
        border: Border.all(
          color: Colors.white,
          width: 2.w,
        ),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Container(
            height: 72.h,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white)),
              color: Color(0xff1b254b),
            ),
            child: Row(
              children: [
                SizedBox(width: 57.w),
                Container(
                  width: 210.w,
                  child: Text(
                    '${year}년 ${month}월',
                    style: TextStyle(
                        fontFamily: 'PretendardGOV',
                        fontWeight: FontWeight.w700,
                        fontSize: 36.sp,
                        color: Colors.white),
                  ),
                ),
                // SizedBox(
                //   width: 37.w,
                // ),
                InkWell(
                  onTap: () {
                    setState(() => currentMonth = DateTime(year, month - 1));
                  },
                  child: Icon(
                    Icons.chevron_left,
                    color: Color(0xff3182ce),
                    size: 70.sp, // 원하는 크기
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() => currentMonth = DateTime(year, month + 1));
                  },
                  child: Icon(
                    Icons.chevron_right,
                    color: Color(0xff3182ce),
                    size: 70.sp, // 원하는 크기
                  ),
                ),
                Spacer(),
                Container(
                  width: 45.w,
                  height: 45.h,
                  child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Image.asset(
                        'assets/icons/color_close.png',
                        fit: BoxFit.fill,
                      )),
                ),
                SizedBox(
                  width: 16.w,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: 68.h, bottom: 43.21.h, right: 49.63.w, left: 47.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['월', '화', '수', '목', '금', '토', '일']
                  .map((d) => Expanded(
                        child: Column(
                          children: [
                            Text(
                              d,
                              style: GoogleFonts.inter(
                                color: Color(0xffcccccc),
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.only(right: 49.63.w, left: 47.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                // mainAxisSpacing: 4.h,
                // crossAxisSpacing: 4.w,
              ),
              itemCount: daysInMonth + firstWeekday - 1,
              itemBuilder: (context, index) {
                if (index < firstWeekday - 1) return Container();
                final day = index - firstWeekday + 2;
                final date = DateTime(year, month, day);

                Color? bgColor;
                if (firstSelected != null && secondSelected != null) {
                  if (date == firstSelected)
                    bgColor = Colors.lightGreen;
                  else if (date == secondSelected) bgColor = Colors.blueAccent;
                } else if (firstSelected != null && date == firstSelected) {
                  bgColor = Colors.lightGreen;
                }
                if (DateUtils.isSameDay(today, date)) {
                  bgColor = Colors.grey;
                }

                return InkWell(
                  onTap: () {
                    setState(() {
                      if (firstSelected == null || (firstSelected != null && secondSelected != null)) {
                        firstSelected = date;
                        secondSelected = null;
                      } else {
                        secondSelected = date;
                      }

                      // ✅ 날짜 선택이 바뀌었을 때 부모에게 알림
                      widget.onDateSelected?.call(firstSelected, secondSelected);

                      // ✅ 여기! 자동 닫기 처리도 이곳에서 추가하면 돼
                      if (widget.autoClose && firstSelected != null && secondSelected != null) {
                        Navigator.of(context).pop();
                      }
                    });
                  },

                  child: Container(
                    width: 75.61.w,
                    height: 75.61.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$day',
                      style: GoogleFonts.inter(
                        color: Color(0xffcccccc),
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ElevatedButton(
              //   onPressed: () {},
              //   style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.blueAccent),
              //   child: Text('취소'),
              // ),
              InkWell(
                onTap: () {
                  if (firstSelected != null || secondSelected != null) {
                    setState(() {
                      firstSelected = null;
                      secondSelected = null;
                    });

                    widget.onDateSelected?.call(null,null);
                  }
                },
                child:  Container(
                  width: 85.w,
                  height: 39.h,
                  decoration: BoxDecoration(
                    color: Color(0xff3182ce),
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: Text(
                    '취소',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Color(0xffcccccc),
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
             
              SizedBox(
                width: 389.w,
              ),
              InkWell(
                onTap: (){
                  final today = DateTime.now();
                  if (currentMonth.year != today.year || currentMonth.month != today.month) {
                    setState(() {
                      currentMonth = DateTime(today.year, today.month);
                    });
                  }
                },
                child:  Container(
                  width: 85.w,
                  height: 39.h,
                  decoration: BoxDecoration(
                    color: Color(0xff3182ce),
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: Text(
                    '오늘',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Color(0xffcccccc),
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 40.h,
          )
        ],
      ),
    );
  }
}
