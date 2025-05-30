// detail_cctv_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DetailCctvView extends StatelessWidget {
  const DetailCctvView({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 3672.w,
          height: 1775.h,
          color: Color(0xff1b254b),
          padding: EdgeInsets.only(top: 15.h, left: 14.w,right: 13.w,bottom: 27.h),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 3642.w,
                    height: 82.h,
                    decoration: BoxDecoration(
                      color: Color(0xff414c67),
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 18.8.w,
                        ),
                        Container(
                          width: 45.44.w,
                          height: 41.h,
                          child: Image.asset('assets/icons/cctv.png'),
                        ),
                        SizedBox(
                          width: 60.7.w,
                        ),
                        Text(
                          'CCTV 테이블',
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
                ],
              ),
              SizedBox(
                height: 16.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 813.w,

                    color: Colors.red,
                  ),
                  SizedBox(
                    width: 30.w,
                  ),
                  Expanded(
                    child: Container(

                      color: Colors.black,
                    ),
                  )
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
