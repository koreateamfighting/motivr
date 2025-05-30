// detail_iot_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DetailIotView extends StatelessWidget {
  const DetailIotView({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 3672.w,
          height: 1775.h,
          color: Color(0xff1b254b),
          padding: EdgeInsets.only(top: 15.h, left: 14.w),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 1277.w,
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
                          child: Image.asset('assets/icons/location.png'),
                        ),
                        Text(
                          'IoT 위치',
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
                  SizedBox(
                    width: 56.w,
                  ),
                  Container(
                    width: 2314.w,
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
                          child: Image.asset('assets/icons/iot.png'),
                        ),
                        Text(
                          'IoT 목록 테이블',
                          style: TextStyle(
                            fontFamily: 'PretendardGOV',
                            fontWeight: FontWeight.w700,
                            fontSize: 36.sp,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          width: 12.w,
                        ),
                        Container(
                            width: 512.w,
                            height: 61.h,
                            child: TextField(
                              //controller: _searchController,
                              style: TextStyle(
                                fontFamily: 'PretendardGOV',
                                fontWeight: FontWeight.w400,
                                fontSize: 32.sp,
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: '검색',
                                  hintStyle: TextStyle(
                                    fontFamily: 'PretendardGOV',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 32.sp,
                                    color: Color(0xffa0aec0),
                                  ),
                                  prefixIcon: Container(
                                    width: 35.w,
                                    height: 40.h,
                                    child: Icon(
                                      Icons.search,
                                      color: Color(0xffa0aec0),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.r),
                                    borderSide: BorderSide(
                                        color: Color(0xffcbd5e0)), // 연한 회색 테두리
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.r),
                                    borderSide: BorderSide(
                                        color: Color(0xff3182ce),
                                        width: 2.w), // 포커스 시 테두리
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.r),
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  contentPadding: EdgeInsets.only(
                                    bottom: 25.h,
                                  )),
                            )),
                        SizedBox(
                          width: 29.w,
                        ),
                        InkWell(
                            onTap: () {},
                            child: Container(
                              width: 141.w,
                              height: 60.h,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Color(0xff3182ce),
                                borderRadius: BorderRadius.circular(5.r),
                              ),
                              child: Text(
                                '검색',
                                style: TextStyle(
                                  fontFamily: 'PretendardGOV',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 36.sp,
                                  color: Colors.white,
                                ),
                              ),
                            )),
                        SizedBox(
                          width: 102.w,
                        ),
                        InkWell(
                            onTap: () {},
                            child: Container(
                              width: 540.w,
                              height: 60.h,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Color(0xff3182ce),
                                borderRadius: BorderRadius.circular(5.r),
                              ),
                              child: Text(
                                '단위 전환(mm/°)',
                                style: TextStyle(
                                  fontFamily: 'PretendardGOV',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 36.sp,
                                  color: Colors.white,
                                ),
                              ),
                            )),
                        SizedBox(
                          width: 452.w,
                        ),
                        InkWell(
                            onTap: () {},
                            child: Container(
                              width: 141.w,
                              height: 60.h,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Color(0xff3182ce),
                                borderRadius: BorderRadius.circular(5.r),
                              ),
                              child: Text(
                                '편집',
                                style: TextStyle(
                                  fontFamily: 'PretendardGOV',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 36.sp,
                                  color: Colors.white,
                                ),
                              ),
                            )),
                        SizedBox(
                          width: 7.w,
                        ),
                        InkWell(
                          onTap: () {},
                          child: Container(
                            width: 50.w,
                            height: 50.h,
                            child: Image.asset('assets/icons/color_close.png',fit: BoxFit.fill,),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(width:1273.w,height: 1639.h,color: Colors.red,),
                  SizedBox(
                    width: 56.w,
                  ),
                  Container(width:2325.w,height: 1639.h,color: Colors.black,),
                ],
              )
            ],
          ),
        )

      ],
    );
  }
}
