import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:iot_dashboard/utils/striped_progressbar.dart';

void showLoadingDialog(BuildContext context,{VoidCallback? onCancel}) {
  showDialog(
    context: context,
    barrierDismissible: false, // 외부 탭 방지
    builder: (context) {
      return Center(
        child: Container(
          width: 1000.w,
          height: 400.h,
          decoration: BoxDecoration(
            color: Color(0xff272e3f),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Colors.white, width: 3.w),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // 상단 상태 표시줄
              Container(
                height: 77.49.h,
                decoration: BoxDecoration(
                  color: Color(0xff0c0c0c),
                  border: Border(
                    bottom: BorderSide(color: Colors.white,width: 1.w)
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.r),
                    topRight: Radius.circular(10.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 23.32.w,),
                    RotatingSpinner(),
                    SizedBox(width: 15.68.w,),
                    Text(
                      "준비중",
                      style: GoogleFonts.inter(
                        color: Color(0xfff9f9f9),
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),

              SizedBox(height: 37.7.h),
              Text(
                "시계열 데이터를 불러오고 있습니다.\n잠시만 기다려주세요.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Color(0xfff9f9f9),
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 60.h),
              StripedProgressBar(
                width: 675.w,
                height: 15.h,
              ),

              SizedBox(height: 49.h),
              Container(
                width: 160.w,
                height: 60.h,
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    if (onCancel != null) onCancel(); // ✅ 콜백 실행
                  }, // 비어있는 onPressed
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff3182ce),
                    // 파란색
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.w, vertical: 8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                  ),
                  child: Text(
                    '취소',
                    style: TextStyle(
                      fontSize: 40.sp,
                      fontFamily: 'PretendardGOV',
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}

class RotatingSpinner extends StatefulWidget {
  const RotatingSpinner({super.key});

  @override
  State<RotatingSpinner> createState() => _RotatingSpinnerState();
}

class _RotatingSpinnerState extends State<RotatingSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40.w,
      height: 40.h,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) => Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: child,
        ),
        child: CustomPaint(
          painter: _SpinnerPainter(),
        ),
      ),
    );
  }
}



class _SpinnerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 3.0;
    final radius = (size.width - strokeWidth) / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const int segments = 12;
    final angleStep = 2 * math.pi / segments;

    for (int i = 0; i < segments; i++) {
      final alpha = (255 * (i + 1) / segments).toInt();
      paint.color = Colors.blue.withAlpha(alpha);

      final startAngle = i * angleStep;
      final x1 = size.width / 2 + radius * math.cos(startAngle);
      final y1 = size.height / 2 + radius * math.sin(startAngle);
      final x2 = size.width / 2 + (radius - 6) * math.cos(startAngle);
      final y2 = size.height / 2 + (radius - 6) * math.sin(startAngle);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}