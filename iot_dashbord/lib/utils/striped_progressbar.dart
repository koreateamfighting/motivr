import 'package:flutter/material.dart';
import 'dart:math';

class StripedProgressBar extends StatefulWidget {
  final double width;
  final double height;

  const StripedProgressBar({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  State<StripedProgressBar> createState() => _StripedProgressBarState();
}

class _StripedProgressBarState extends State<StripedProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.height / 2),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _StripedPainter(_controller.value),
            size: Size(widget.width, widget.height),
          );
        },
      ),
    );
  }
}

class _StripedPainter extends CustomPainter {
  final double animationValue;

  _StripedPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xffd8d8d8);
    final stripePaint = Paint()..color = const Color(0xff1e2331);
    final stripeWidth = 40.0;
    final spacing = 20.0;

    // 배경 바
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.height / 2),
    );
    canvas.drawRRect(rrect, bgPaint);

    // 사선 스트라이프
    canvas.save();
    canvas.clipRRect(rrect);
    canvas.translate(-((animationValue * (stripeWidth + spacing)) % (stripeWidth + spacing)), 0);

    for (double x = -size.height; x < size.width + size.height; x += stripeWidth + spacing) {
      final path = Path()
        ..moveTo(x, 0)
        ..lineTo(x + stripeWidth, 0)
        ..lineTo(x + stripeWidth - size.height, size.height)
        ..lineTo(x - size.height, size.height)
        ..close();
      canvas.drawPath(path, stripePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _StripedPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
