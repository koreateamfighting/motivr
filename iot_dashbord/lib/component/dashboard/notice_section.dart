import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/component/dashboard/expand_notice_search.dart';
import 'package:iot_dashboard/controller/notice_controller.dart';
import 'package:iot_dashboard/model/notice_model.dart';
import 'package:iot_dashboard/utils/iframe_visibility.dart';
import 'dart:async';

class NoticeSection extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onTap;

  const NoticeSection({
    super.key,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  State<NoticeSection> createState() => _NoticeSectionState();
}

class _NoticeSectionState extends State<NoticeSection> {
  List<Notice> notices = [];
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _fetchNoticeData();
    // ✅ 1분마다 작업 내역 자동 갱신
    _timer = Timer.periodic(Duration(minutes: 1), (_) {
      _fetchNoticeData();
    });
  }

  void _fetchNoticeData() async {
    final data = await NoticeController.fetchNotices();
    setState(() {
      notices = data;
    });
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 항상 보이는 헤더
        InkWell(
          onTap: widget.onTap,
          child: Container(
            height: 60.h,
            decoration: BoxDecoration(
              //color: Color(0xff111c44),
              color: Color(0xff1b254b),
              border: Border(
                bottom: BorderSide(
                  color: Color(0xffd9d9d9), // 선 색상
                  width: 1.w, // 선 두께
                ),
              ),
            ),
            child: Row(
              children: [
                SizedBox(width: 26.w,),
                Container(width: 40.16.w,
                  height: 40.h,
                  child: Image.asset('assets/icons/notice.png'),),
                SizedBox(width: 5.w),
                Text(
                  '공지 및 주요 일정',
                  style: TextStyle(
                      fontFamily: 'PretendardGOV',
                      fontWeight: FontWeight.w500,
                      fontSize: 36.sp,
                      color: Colors.white
                  ),
                ),
                Spacer(),
            Container(
              width: 60.w,
              height: 60.h,

              child: Image.asset(
                widget.isExpanded
                    ? 'assets/icons/color_arrow_down.png'
                    : 'assets/icons/color_arrow_right.png',

              ),
            ),

              ],
            ),
          ),
        ),
        if (widget.isExpanded)
          Container(
            height: 59.h,
            color: Color(0xff0b1437),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 120.48.w,
                  height: 40.h,
                  padding: EdgeInsets.only(top:5.71.h),
                  decoration: BoxDecoration(
                    //color: Color(0xff111c44),
                    color: Color(0xff3182ce),

                    borderRadius: BorderRadius.circular(5.r),
                    // child: 이후 실제 위젯 들어갈 수 있도록 구성해둠
                  ),
                  child: InkWell(
                    onTap: () {
                      hideIframes();
                      showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: '',
                        barrierColor: Colors.black.withOpacity(0.5),
                        transitionDuration: Duration(milliseconds: 200),
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 841.w),
                              child: Material( // ✅ 이게 없으면 버튼 인식이 안 될 수도 있음
                                color: Colors.transparent,
                                child: SizedBox(
                                  width: 2750.w,
                                  height: 1803.h,
                                  child: ExpandNoticeSearch(
                                    onDataUploaded: _fetchNoticeData,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );





                    },
                    child: Text(
                      '전체 보기',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'PretendardGOV',
                          fontWeight: FontWeight.w400,
                          fontSize: 20.sp,
                          color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(
                  width: 21.52.w,
                )
              ],
            ),
          ),

        // TextButton(
        //   onPressed: () {
        //     // 전체 알람 페이지로 이동
        //     Navigator.pushNamed(context, '/alarms'); // or context.go('/alarms') if using go_router
        //   },
        //   child: Text('전체 보기', style: TextStyle(color: Colors.white)),
        // ),

        Container(
          height: 1.h,
          color: Colors.white,
        ),
        if (widget.isExpanded)
          Container(
            height: 59.h,
            decoration: BoxDecoration(
              //color: Color(0xff111c44),
              color: Color(0xff0b1437),
              border: Border(
                bottom: BorderSide(
                  color: Color(0xffd9d9d9), // 선 색상
                  width: 1.w, // 선 두께
                ),
              ),
              // child: 이후 실제 위젯 들어갈 수 있도록 구성해둠
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [

                SizedBox(width: 25.w,),
                SizedBox(
                    width: 80.32.w,
                    child: Text('시간',
                        overflow: TextOverflow.ellipsis, // 넘치면 "..." 처리
                        maxLines: 1,                      // 최대 한 줄로 제한
                        softWrap: false,                 // 줄바꿈 비활성화
                        style: TextStyle(
                            fontFamily: 'PretendardGOV',
                            fontWeight: FontWeight.w800,
                            fontSize: 24.sp,
                            color: Colors.white))),
                SizedBox(width: 318.68.w,),
                Expanded(
                    child: Text('내용',
                        style: TextStyle(
                            fontFamily: 'PretendardGOV',
                            fontWeight: FontWeight.w800,
                            fontSize: 24.sp,
                            color: Colors.white))),
              ],
            ),
          ),
        if (widget.isExpanded)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            height: 354.h,
            color: Color(0xff0b1437),
            child: ListView.separated(
              itemCount: notices.length.clamp(0, 6), // 최대 6개만
              separatorBuilder: (context, index) =>
                  Container(height: 1.h, color: Colors.white),
              itemBuilder: (context, index) {
                final item = notices[index];
                return NoticeRowWidget(item.createdAt, item.content);
              },
            ),
          ),
      ],
    );
  }
}

class NoticeRowWidget extends StatelessWidget {
  final String createdAt;
  final String content;

  const NoticeRowWidget(this.createdAt, this.content, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      height: 59.h,
      color: Color(0xff0b1437),
      child: Row(
        children: [
          Container(
            width: 400.w,

            child: Text(createdAt,
                style: TextStyle(
                  fontFamily: 'PretendardGOV',
                  fontWeight: FontWeight.w500,
                  fontSize: 24.sp,
                  color: Colors.white,
                )),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Container(

              child: Text(content,
                  style: TextStyle(
                    fontFamily: 'PretendardGOV',
                    fontWeight: FontWeight.w500,
                    fontSize: 24.sp,
                    color: Colors.white,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

