import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/theme/colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart'; // ✅ inputFormatter용
import 'package:iot_dashboard/utils/auth_service.dart';
import 'package:iot_dashboard/component/common/dialog_form.dart';
import 'package:iot_dashboard/utils/iframe_visibility.dart';
import 'package:iot_dashboard/controller/duty_controller.dart';
import 'package:iot_dashboard/model/duty_model.dart';

class WorkProcessStatus extends StatefulWidget {
  const WorkProcessStatus({super.key});

  @override
  State<WorkProcessStatus> createState() => _WorkProcessStatusState();
}

class _WorkProcessStatusState extends State<WorkProcessStatus> {
  bool isEditing = false;
  double? progress;
  final TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadInitialProgress();
  }
  Future<void> _loadInitialProgress() async {
    try {
      final duty = await DutyController.fetchLatestDuty();
      if (duty != null) {
        setState(() {
          progress = duty.progress / 100.0;
        });
      }
    } catch (e) {
      print('❌ Failed to load duty progress: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 613.w,
      height: 602.h,
      decoration: BoxDecoration(
        color: const Color(0xff111c44),
        border: Border.all(
          color: Colors.white,
          width: 1.w,
        ),
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              height: 59.h,
              child: Row(
                children: [
                  SizedBox(width: 24.w),
                  Container(
                    width: 30.w,
                    height: 30.h,
                    child: Image.asset('assets/icons/work_process.png'),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    '오늘 작업 공정',
                    style: TextStyle(
                      fontFamily: 'PretendardGOV',
                      fontWeight: FontWeight.w500,
                      fontSize: 36.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 70.w),
                  Text(
                    _getFormattedDate(),
                    style: TextStyle(
                      fontFamily: 'PretendardGOV',
                      fontWeight: FontWeight.w400,
                      fontSize: 24.sp,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            isEditing ? _buildInputUI() : _buildChartUI()
          ],
        ),
      ),
    );
  }

  Widget _buildChartUI() {
    if (progress == null) {
      return SizedBox(
        height: 481.h,
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final progressVal = progress!;
    return Column(

      children: [
        Container(width: 1542.w, height: 1.h, color: Colors.white),
        SizedBox(height: 54.h),
        Container(
          height: 481.h,
          child: Column(
            children: [
              SizedBox(
                width: 334.45.w,
                height: 340.h,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        centerSpaceRadius: 120.w,
                        startDegreeOffset: -90,
                        sectionsSpace: 0,
                        sections: [
                          PieChartSectionData(
                            color: const Color(0xff2980ff),
                            value: progress! * 100,
                            showTitle: false,
                            radius: 50.w,
                          ),
                          PieChartSectionData(
                            color: const Color(0xffa0aec0),
                            value: 100 - progress! * 100,
                            showTitle: false,
                            radius: 50.w,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 20.h),
                        Text(
                          '${(progress! * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 80.sp,
                            fontFamily: 'PretendardGOV',
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '공정률',
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontFamily: 'PretendardGOV',
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 33.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _legendItem(Color(0xff414c67), '미완료'),
                  SizedBox(width: 32.w),
                  _legendItem(Color(0xff030A64), '완료'),
                ],
              ),
              SizedBox(height: 24.h),
              Container(width: 1542.w, height: 1.h, color: Colors.white),
              SizedBox(height: 8.h),

              // // ✅ 관리자 권한 없으면 접근 차단
              // if (!AuthService.isAdmin()) {
              // // 마이크로태스크로 실행 → UI가 빌드된 후에 다이얼로그 띄우기
              // Future.microtask(() {
              // showDialog(
              // context: context,
              // builder: (context) => AlertDialog(
              // title: Text('접근 거부'),
              // content: Text('관리자 계정만 들어갈 수 있습니다.'),
              // actions: [
              // TextButton(
              // onPressed: () {
              // Navigator.of(context).pop();
              // // 🚪 관리자 아니면 대시보드로 강제 이동
              // Navigator.of(context).pushReplacementNamed('/DashBoard');
              // },
              // child: Text('확인'),
              // ),
              // ],
              // ),
              // );
              // });
              //
              // // 일단 빈 컨테이너 반환 → 다이얼로그 후 이동
              // return const Scaffold(body: SizedBox());
              // }
              GestureDetector(
                onTap: () async {

                  if (!AuthService.isAdmin()) {

                      hideIframes();
                      await showDialog(
                        context: context,
                        barrierDismissible: false, // 바깥 클릭 시 닫히지 않도록
                        builder: (_) => DialogForm(mainText:"관리자만 공정률 수정이 가능합니다.",btnText: "닫기",),
                      );
                      showIframes();


                  } else {
                    setState(() {
                      isEditing = true;
                      _controller.text = (progress! * 100).toStringAsFixed(0);
                    });
                  }
                },
                child: Container(
                  width: 140.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: const Color(0xff3182ce),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Center(
                    child: Text(
                      '공정률 입력',
                      style: TextStyle(
                        fontFamily: 'PretendardGOV',
                        fontSize: 20.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputUI() {
    return Container(
      width: 613.w,
      height: 540.h,
      padding:
          EdgeInsets.only(left: 6.w, top: 19.h, right: 6.55.w, bottom: 19.5.h),
      decoration: BoxDecoration(
        //color: Color(0xff111c44),
        color: Color.fromRGBO(255, 255, 255, 0.5),

        borderRadius: BorderRadius.circular(5.r),
        // child: 이후 실제 위젯 들어갈 수 있도록 구성해둠
      ),
      child: Container(
        color: Color.fromRGBO(65, 76, 103, 0.9),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 49.51.h,
              color: Color.fromRGBO(29, 34, 46, 0.8),
              child: Row(
                children: [
                  SizedBox(width: 24.w),
                  Container(
                    width: 24.75.w,
                    height: 24.75.h,
                    child: Image.asset('assets/icons/work_process.png'),
                  ),
                  Container(
                    width: 298.51.w,
                    height: 30.95.h,
                    child: Text(
                      '오늘 작업 공정률을 입력하세요',
                      style: TextStyle(
                        fontFamily: 'PretendardGOV',
                        fontWeight: FontWeight.w400,
                        fontSize: 24.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Spacer(),
                  Container(
                    width: 43.32.w,
                    height: 43.32.h,
                    child: InkWell(
                        onTap: () {
                          setState(() {
                            isEditing = false;
                          });
                        },
                        child: Image.asset('assets/icons/color_close.png')),
                  ),
                  SizedBox(width: 10.w),
                  // Text(
                  //   _getFormattedDate(),
                  //   style: TextStyle(
                  //     fontFamily: 'PretendardGOV',
                  //     fontWeight: FontWeight.w400,
                  //     fontSize: 24.sp,
                  //     color: Colors.white,
                  //   ),
                  // ),
                ],
              ),
            ),
            SizedBox(
              height: 82.87.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 66.w),
                Container(
                    width: 68.w,
                    height: 29.h,
                    child: Text('0%',
                        style: TextStyle(
                          fontFamily: 'PretendardGOV',
                          fontWeight: FontWeight.w500,
                          fontSize: 24.sp,
                          color: Colors.white,
                        ))),
                SizedBox(width: 343.w),
                Container(
                    width: 68.w,
                    height: 29.h,
                    child: Text('100%',
                        style: TextStyle(
                          fontFamily: 'PretendardGOV',
                          fontWeight: FontWeight.w500,
                          fontSize: 24.sp,
                          color: Colors.white,
                        ))),
              ],
            ),
            buildGradientBar(progress!),
            SizedBox(
              height: 34.79.h,
            ),
            Container(
              width: 247.55.w,
              height: 49.51.h,
              child: TextField(
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // ✅ 숫자만 허용
                ],
                controller: _controller,
                onChanged: (value) {
                  // 공백 입력되면 0 처리
                  if (value.trim().isEmpty) {
                    setState(() {
                      progress = 0;
                    });
                    return;
                  }

                  final input = double.tryParse(value);
                  if (input != null) {
                    double clamped = input.clamp(0, 100);
                    setState(() {
                      progress = clamped / 100;
                    });
                  }
                },
                style: TextStyle(
                  fontFamily: 'PretendardGOV',
                  fontWeight: FontWeight.w500,
                  fontSize: 32.sp,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: '\t예 : 50',
                    hintStyle: TextStyle(
                      fontFamily: 'PretendardGOV',
                      fontWeight: FontWeight.w500,
                      fontSize: 32.sp,
                      color: Color(0xff9ea3a2),
                    ),
                    suffixText: '%',
                    suffixStyle: TextStyle(
                      fontFamily: 'PretendardGOV',
                      fontWeight: FontWeight.w500,
                      fontSize: 32.sp,
                      color: Color(0xff1d222e),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    contentPadding:
                        EdgeInsets.only(bottom: 25.h, right: 50.w, left: 50.w)),
              ),
            ),
            SizedBox(height: 39.7.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100.w,
                  height: 40.h,

                  // padding: EdgeInsets.only(top:),
                  decoration: BoxDecoration(
                    color: Color(0xff3182ce),
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isEditing = false;
                      });
                    },
                    child: Text(
                      '취소',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'PretendardGOV',
                          fontWeight: FontWeight.w500,
                          fontSize: 24.sp,
                          color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: 47.w),
                Container(
                  width: 100.w,
                  height: 40.h,

                  // padding: EdgeInsets.only(top:),
                  decoration: BoxDecoration(
                    color: Color(0xff3182ce),
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: InkWell(
                    onTap: () async {
                      double? input = double.tryParse(_controller.text);
                      if (input != null && input >= 0 && input <= 100) {
                        // ✅ 기존 duty를 불러와서 progress만 수정
                        final duty = await DutyController.fetchLatestDuty();
                        if (duty != null) {
                          final updated = Duty(
                            id: duty.id,
                            dutyName: duty.dutyName,
                            startDate: duty.startDate,
                            endDate: duty.endDate,
                            progress: input.toInt(), // ✅ progress만 변경
                          );

                          await DutyController.updateLatestDuty(updated);

                          setState(() {
                            progress = input / 100;
                            isEditing = false;
                          });
                        } else {
                          // 예외 처리: duty가 없을 때
                          await showDialog(
                            context: context,
                            builder: (_) => const DialogForm(
                              mainText: '진행 중인 작업이 없습니다.',
                              btnText: '확인',
                              fontSize: 20,
                            ),
                          );
                        }
                      }
                    },

                    child: Text(
                      '완료',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'PretendardGOV',
                          fontWeight: FontWeight.w500,
                          fontSize: 24.sp,
                          color: Colors.white),
                    ),
                  ),
                ),

                // ElevatedButton(
                //   onPressed: () {
                //     double? input = double.tryParse(_controller.text);
                //     if (input != null && input >= 0 && input <= 100) {
                //       setState(() {
                //         progress = input / 100;
                //         isEditing = false;
                //       });
                //     }
                //   },
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: const Color(0xff3182ce),
                //   ),
                //   child: Text('확인'),
                // ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

Widget buildGradientBar(double percent) {
  return Container(
    width: 432.w,
    height: 50.h,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(50.r),
    ),
    child: Stack(
      children: [
        // 그라데이션 바
        Container(
          width: 432.w * percent.clamp(0.0, 1.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF7D87A3),
                Color(0xFF0F166A),
              ],
            ),
            borderRadius: BorderRadius.circular(50.r),
          ),
        ),
      ],
    ),
  );
}

String _getFormattedDate() {
  final now = DateTime.now().toUtc().add(const Duration(hours: 9));
  return '${now.year}년 ${now.month.toString().padLeft(2, '0')}월 ${now.day.toString().padLeft(2, '0')}일 현재';
}

Widget _legendItem(Color baseColor, String label) {
  return Row(
    children: [
      ClipOval(
        child: Container(
          width: 16.w,
          height: 16.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                darken(baseColor, 0.2),
                baseColor,
                brighten(baseColor, 0.2),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      SizedBox(width: 8.w),
      Text(
        label,
        style: TextStyle(
          fontFamily: 'PretendardGOV',
          fontSize: 21.sp,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      ),
    ],
  );
}

Color darken(Color color, [double amount = .1]) {
  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
  return hslDark.toColor();
}

Color brighten(Color color, [double amount = .1]) {
  final hsl = HSLColor.fromColor(color);
  final hslBright = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
  return hslBright.toColor();
}
