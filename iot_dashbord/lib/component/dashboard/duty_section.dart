import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/component/dashboard/expand_duty_search.dart';
import 'package:iot_dashboard/utils/iframe_visibility.dart';
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
            height: 60.h,
            decoration: BoxDecoration(
              //color: Color(0xff111c44),
              color: Color(0xff111c44),
              border: Border.all(
                color: Colors.white,
                width: 1.w,
              ),
            ),
            child: Row(
              children: [
                SizedBox(width: 26.w,),
                Container(width: 40.16.w,
                  height: 40.h,
                  child: Image.asset('assets/icons/duty.png'),),
                SizedBox(width: 5.w),
                Text(
                  '작업명',
                  style: TextStyle(
                      fontFamily: 'PretendardGOV',
                      fontWeight: FontWeight.w500,
                      fontSize: 36.sp,
                      color: Colors.white
                  ),
                ),
                Spacer(),
                Container(width: 60.w, height: 60.h, child: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                  color: Color(0xff3d91ff),
                  size: 70.sp,
                ),)

              ],
            ),
          ),
        ),
        if (isExpanded)
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
                                child: ExpandDutySearch(),
                              ),
                            ),
                          ),
                        );
                      },
                    );


                    showIframes(); // ✅ 다이얼로그 닫히고 나서 실행됨


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
        if (isExpanded)
        Container(
          height: 59.h,
          decoration: BoxDecoration(
            //color: Color(0xff111c44),
            color: Color(0xff0b1437),
            border: Border.all(
              color: Colors.white,
              width: 1.w,
            ),

            // child: 이후 실제 위젯 들어갈 수 있도록 구성해둠
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              SizedBox(width: 25.w,),
              SizedBox(
                  width: 80.32.w,
                  child: Text('작업명',
                      overflow: TextOverflow.ellipsis, // 넘치면 "..." 처리
                      maxLines: 1,                      // 최대 한 줄로 제한
                      softWrap: false,                 // 줄바꿈 비활성화
                      style: TextStyle(
                          fontFamily: 'PretendardGOV',
                          fontWeight: FontWeight.w800,
                          fontSize: 24.sp,
                          color: Colors.white))),
              SizedBox(width: 318.68.w,),
              SizedBox(
                  width: 81.32.w,
                  child: Text('진행률',
                      style: TextStyle(
                          fontFamily: 'PretendardGOV',
                          fontWeight: FontWeight.w800,
                          fontSize: 24.sp,
                          color: Colors.white))),
              SizedBox(width: 81.68.w,),
              SizedBox(
                  width: 46.18.w,
                  child: Text('시작',
                      style: TextStyle(
                          fontFamily: 'PretendardGOV',
                          fontWeight: FontWeight.w800,
                          fontSize: 24.sp,
                          color: Colors.white))),
              SizedBox(width:194.82.w,),
              Expanded(
                  child: Text('완료',
                      style: TextStyle(
                          fontFamily: 'PretendardGOV',
                          fontWeight: FontWeight.w800,
                          fontSize: 24.sp,
                          color: Colors.white))),
            ],
          ),
        ),
        if (isExpanded)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            height: 354.h,
            color: Color(0xff0b1437),
            child: ListView.separated(
              itemCount: 6,
              separatorBuilder: (context, index) => Container(
                height: 1.h,
                color: Colors.white,
              ),
              itemBuilder: (context, index) {
                final data = [
                  ['옹벽 철근 설치', '90%', '2025-04-22', '2025-04-23'],
                  ['콘크리트 타일', '75%', '2025-04-23', '2025-04-24'],
                  ['배수관 매설', '50%', '2025-04-23', '2025-04-25'],
                  ['옹벽 철근 설치', '90%', '2025-04-22', '2025-04-23'],
                  ['콘크리트 타일', '75%', '2025-04-23', '2025-04-24'],
                  ['배수관 매설', '50%', '2025-04-23', '2025-04-25'],
                ];
                final item = data[index];
                return DataRowWidget(item[0], item[1], item[2], item[3]);
              },
            )

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
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      height: 59.h,
      color: Color(0xff0b1437),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

         Container(
           width: 400.w,height: 29.h,
              child: Text(task,
                  style: TextStyle(
                      fontFamily: 'PretendardGOV',
                      fontWeight: FontWeight.w500,
                      fontSize: 24.sp,
                      color: Colors.white))),
          Container(
              width: 70.w,height: 29.h,
              child: Text(progress,
                  style: TextStyle(
                      fontFamily: 'PretendardGOV',
                      fontWeight: FontWeight.w500,
                      fontSize: 24.sp,
                      color: Colors.white))),
          SizedBox(width: 90.w,),
          Container(
              width: 140.56.w,height: 29.h,
              child: Text(start,
                  style: TextStyle(
                      fontFamily: 'PretendardGOV',
                      fontWeight: FontWeight.w500,
                      fontSize: 24.sp,
                      color: Colors.white))),
          SizedBox(width: 100.44.w,),
          Container(
              width: 140.56.w,height: 29.h,
              child: Text(end,
              style: TextStyle(
                  fontFamily: 'PretendardGOV',
                  fontWeight: FontWeight.w500,
                  fontSize: 24.sp,
                  color: Colors.white))),
        ],
      ),
    );
  }
}
