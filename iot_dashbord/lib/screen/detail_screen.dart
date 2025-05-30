import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/component/base_layout.dart';
import 'package:iot_dashboard/component/details/detail_iot_view.dart';
import 'package:iot_dashboard/component/details/detail_cctv_view.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int selectedTab = 0; // 0 = IoT, 1 = CCTV

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(3812, 2144),
      minTextAdapt: true,
      builder: (context, child) {
        return BaseLayout(
          child: Container(
            padding: EdgeInsets.only(left: 64.w, right: 68.w),
            color: Color(0xff1b254b),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ 헤더
                Container(
                  height: 69.h,
                  color: Color(0xff1b254b),
                  padding: EdgeInsets.symmetric(horizontal: 66.w),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/icons/clipboard.png',
                        width: 40.w,
                        height: 40.h,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '세부현황',
                        style: TextStyle(
                          fontFamily: 'PretendardGOV',
                          fontWeight: FontWeight.w700,
                          fontSize: 36.sp,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // ✅ 하단 선
                Container(
                  width: double.infinity,
                  height: 4.h,
                  color: Colors.white,
                ),

                SizedBox(height: 11.h),

                // ✅ 커스텀 탭
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => selectedTab = 0);
                        },
                        child: buildTab(
                            label: 'IoT',
                            imageName: 'iot',
                            isSelected: selectedTab == 0),
                      ),
                    ),
                    SizedBox(
                      width: 20.w,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => selectedTab = 1);
                        },
                        child: buildTab(
                            label: 'CCTV',
                            imageName: 'cctv',
                            isSelected: selectedTab == 1),
                      ),
                    ),
                  ],
                ),

                // ✅ 아래 파란 줄
                Container(
                  width: 3680.w,
                  height: 30.h,
                  color: Color(0xff3182ce),
                ),

                // ✅ 콘텐츠 박스
                Container(
                  width: 3680.w,
                  height: 1779.h,
                  decoration: BoxDecoration(
                    color: Color(0xff1b254b),
                    border: Border.all(
                      color: Color(0xff3182ce),
                      width: 4.w,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10.r),
                      bottomRight: Radius.circular(10.r),
                    ),
                  ),
                  child: selectedTab == 0 ? DetailIotView() : DetailCctvView(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ✅ 커스텀 탭 위젯 생성 함수
  Widget buildTab(
      {required String label,
      required String imageName,
      required bool isSelected}) {
    return Container(
        height: 95.h,
        decoration: BoxDecoration(
          color: isSelected ? Color(0xff3182ce) : Color(0xff1b254b),
          border: isSelected
              ? null
              : Border.all(
                  color: Color(0xff3182ce),
                  width: 4.w,
                ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.r),
            topRight: Radius.circular(10.r),
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50.w,
              height: 50.h,
              child: Image.asset('assets/icons/${imageName}.png'),
            ),
            SizedBox(
              width: 8.w,
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'PretendardGOV',
                fontSize: 48.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ));
  }
}
