import 'package:flutter/material.dart';
import 'package:iot_dashboard/model/iot_model.dart';
import 'package:iot_dashboard/controller/iot_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class AlarmHistory extends StatefulWidget {
  final String selectedRid;
  final List<IotItem> allItems;
  final DateTime startDate;
  final DateTime endDate;

  const AlarmHistory(
      {super.key, required this.selectedRid, required this.allItems,  required this.startDate,
        required this.endDate});

  State<AlarmHistory> createState() => _AlarmHistoryState();
}

class _AlarmHistoryState extends State<AlarmHistory> {
  final ScrollController _scrollController = ScrollController();
  List<IotItem> filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filterItems();
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AlarmHistory oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedRid != oldWidget.selectedRid ||
        widget.allItems != oldWidget.allItems ||
        widget.startDate != oldWidget.startDate ||
        widget.endDate != oldWidget.endDate) {
      _filterItems();
    }
  }

  void _filterItems() {
    setState(() {
      filteredItems = widget.allItems.where((item) {
        final bool ridMatch = item.id == widget.selectedRid;
        final bool eventMatch = item.eventtype == '2' || item.eventtype == '4';
        final bool timeMatch =
            item.createAt.isAfter(widget.startDate) &&
                item.createAt.isBefore(widget.endDate);

        return ridMatch && eventMatch && timeMatch;
      }).toList();
      filteredItems.sort((a, b) => b.createAt.compareTo(a.createAt));
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.ensureScreenSize();

    return Container(
      width: 729.w,
      height: 1645.h,
      decoration: BoxDecoration(
        color: Color(0xff0b1437),
        borderRadius: BorderRadius.circular(5.r),
        border: Border.all(color: Color(0xff414c67), width: 4.w),
      ),
      padding: EdgeInsets.only(top: 10.h, left: 4.w),
      child: Row(
        children: [
          Expanded(
            child: ScrollbarTheme(
              data: ScrollbarThemeData(
                thumbColor: MaterialStateProperty.all(Color(0xff004aff)),
                trackColor: MaterialStateProperty.all(Colors.white),
                radius: Radius.circular(10.r),
                thickness: MaterialStateProperty.all(10.w),
              ),
              child: Scrollbar(
                controller: _scrollController,
                thickness: 10.w,
                thumbVisibility: true,
                radius: Radius.circular(5.r),
                trackVisibility: false,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      controller: _scrollController,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            _buildSubHeader(),
                            _buildColumnTitles(),
                            if (filteredItems.isEmpty)
                              Padding(
                                padding: EdgeInsets.all(30.h),
                                child: Text(
                                  '센서 데이터 ID를 선택해주세요.',
                                  style: TextStyle(
                                    fontSize: 28.sp,
                                    color: Colors.white70,
                                    fontFamily: 'PretendardGOV',
                                  ),
                                ),
                              )
                            else
                              ...filteredItems.map(_buildRow).toList(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 100.h,
      decoration: BoxDecoration(
        color: Color(0xff414c67),
        border: Border(
          top: BorderSide(color: Colors.white, width: 2.w),
          left: BorderSide(color: Colors.white, width: 2.w),
          right: BorderSide(color: Colors.white, width: 2.w),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 12.w),
          Container(
            width: 50.w,
            height: 50.h,
            child: Image.asset('assets/icons/clock2.png'),
          ),
          SizedBox(width: 11.w),
          Container(
            width: 241.w,
            height: 50.h,
            child: Text(
              '알람 히스토리',
              style: TextStyle(
                fontSize: 36.sp,
                fontFamily: 'PretendardGOV',
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubHeader() {
    return Container(
      width: double.infinity,
      height: 100.h,
      decoration: BoxDecoration(
        color: Color(0xff3182ce),
        border: Border(
          bottom: BorderSide(color: Colors.white, width: 2.w),
          left: BorderSide(color: Colors.white, width: 2.w),
          right: BorderSide(color: Colors.white, width: 2.w),
        ),
      ),
      child: Center(
        child: Text(
          '[${widget.selectedRid ?? ''}]', // null일 경우 빈 문자열 처리
          style: TextStyle(
            fontSize: 36.sp,
            fontFamily: 'PretendardGOV',
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildColumnTitles() {
    return Container(
      width: double.infinity,
      height: 100.h,
      decoration: BoxDecoration(
        color: Color(0xff414c67),
        border: Border(
          top: BorderSide(color: Colors.white, width: 2.w),
          bottom: BorderSide(color: Colors.white, width: 2.w),
          left: BorderSide(color: Colors.white, width: 2.w),
          right: BorderSide(color: Colors.white, width: 2.w),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 12.w),
          Container(
            width: 260.w,
            height: 80.h,
            alignment: Alignment.centerLeft,
            child: Text(
              '날짜/시간',
              style: TextStyle(
                fontSize: 36.sp,
                fontFamily: 'PretendardGOV',
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 181.w),
          Container(
            width: 200.w,
            height: 80.h,
            alignment: Alignment.centerLeft,
            child: Text(
              '이벤트',
              style: TextStyle(
                fontSize: 36.sp,
                fontFamily: 'PretendardGOV',
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(IotItem item) {
    final x = double.tryParse(item.X_Deg) ?? 0;
    final y = double.tryParse(item.Y_Deg) ?? 0;
    final z = double.tryParse(item.Z_Deg) ?? 0;

    String eventType;
    Color textColor;
    Widget iconWidget;

    if ([x, y, z].any((v) => v.abs() >= 5)) {
      eventType = 'CRIT';
      textColor = Colors.red;
      iconWidget = Image.asset('assets/icons/alert_warning.png',
          width: 60.w, height: 60.h);
    } else if ([x, y, z].any((v) => v.abs() >= 3)) {
      eventType = 'WARN';
      textColor = Colors.yellow;
      iconWidget = Image.asset('assets/icons/alert_caution.png',
          width: 60.w, height: 60.h);
    } else {
      eventType = 'INFO';
      textColor = Colors.green;

      iconWidget = Container(
        width: 60.w,
        height: 60.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(16.r), // 둥근 모서리

        ),
        child: Icon(
          Icons.check,
          color: Colors.white,
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 100.h,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.2), width: 1.w),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Container(
            width: 260.w,
            child: Text(
              DateFormat('yyyy-MM-dd HH:mm:ss').format(item.createAt),
              style: TextStyle(
                fontSize: 30.sp,
                color: Colors.white,
                fontFamily: 'PretendardGOV',
              ),
            ),
          ),
          SizedBox(width: 145.w),
          iconWidget,
          SizedBox(width: 20.w),
          Container(
            width: 200.w,
            child: Text(
              eventType,
              style: TextStyle(
                fontSize: 30.sp,
                color: textColor,
                fontFamily: 'PretendardGOV',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
