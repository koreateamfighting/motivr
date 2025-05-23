import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegisterSuccessDialog extends StatelessWidget {
  const RegisterSuccessDialog({super.key});

  static const designWidth = 3812;
  static const designHeight = 2144;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(designWidth.toDouble(), designHeight.toDouble()),
      builder: (context, child) {
        return WillPopScope(child:  MaterialApp(
            home: Dialog(
              backgroundColor: Colors.transparent,
              child: Center(
                child:          Container(
                  width: 1420.w,
                  height: 420.h,

                  decoration: BoxDecoration(
                    color: Color(0xff414c67),
                    border: Border.all(color: Color(0xff9b9c9d), width: 10.w),
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: 80.h,
                        color: Color(0xff272e3f),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: 18.w,),
                            Container(
                              width: 60.w,
                              height: 60.h,
                              child: Image.asset('assets/icons/download.png'),
                            ),
                            Spacer(),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                width: 70.w,
                                height: 70.h,
                                child: Image.asset('assets/icons/close.png'),
                              ),
                            ),
                            SizedBox(width: 18.w,),
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        height: 1.h,
                      ),
                      SizedBox(
                        height: 62.h,
                      ),
                      Text(
                        '회원 가입이 완료 되었습니다.',
                        style: TextStyle(
                            fontFamily: 'PretendardGOV',
                            fontWeight: FontWeight.w500,
                            fontSize: 48.sp,
                            color: Colors.white),
                      ),
                      SizedBox(
                        height: 62.h,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                            width: 200.w,
                            height: 80.h,
                            padding: EdgeInsets.only(top: 12.h),
                            decoration: BoxDecoration(
                              color: Color(0xff3182ce),

                              borderRadius: BorderRadius.circular(5.r),
                            ),
                            child: Text(
                              '완료',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'PretendardGOV',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 40.sp,
                                  color: Colors.white),
                            )),
                      )
                    ],
                  ),
                ),
              )
              ,
            )), onWillPop: () async {
          Navigator.of(context).pop(); // ESC 또는 Android back 버튼 시 닫힘
          return false; // 기본 동작 막기
        })
         ;
      },
    );
  }
}
