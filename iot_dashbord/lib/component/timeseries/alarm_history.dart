import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AlarmHistory extends StatefulWidget {
  const AlarmHistory({Key? key}) : super(key: key);

  @override
  State<AlarmHistory> createState() => _AlarmHistoryState();
}

class _AlarmHistoryState extends State<AlarmHistory> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      // 헤더
                      _buildHeader(),
                      _buildSubHeader(),
                      _buildColumnTitles(),

                      // 예시 알람 데이터
                      for (int i = 0; i < 20; i++) _buildRow(i),
                    ],
                  ),
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
          '[                      ]',
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

  Widget _buildRow(int i) {
    return Container(
      width: double.infinity,
      height: 100.h,
      decoration: BoxDecoration(
        border: Border(
          bottom:
          BorderSide(color: Colors.white.withOpacity(0.2), width: 1.w),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Container(
            width: 260.w,
            child: Text(
              '2025-06-05 14:2${i % 10}',
              style: TextStyle(
                fontSize: 30.sp,
                color: Colors.white,
                fontFamily: 'PretendardGOV',
              ),
            ),
          ),
          Container(
            width: 200.w,
            child: Text(
              '이벤트 ${i + 1}',
              style: TextStyle(
                fontSize: 30.sp,
                color: Colors.white,
                fontFamily: 'PretendardGOV',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
