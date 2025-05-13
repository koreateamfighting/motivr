import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

CustomTransitionPage buildSlideTransitionPage(Widget child) {
  return CustomTransitionPage(
    transitionDuration: const Duration(milliseconds: 600),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;
      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}
