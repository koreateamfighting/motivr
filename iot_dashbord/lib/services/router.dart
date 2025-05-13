import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import '../screen/dashboard_screen.dart';
import '../screen/detail_screen.dart';
import '../screen/digitaltwin_screen.dart';
import '../screen/timeseries_screen.dart';
import '../screen/admin_screen.dart';
import '../screen/login_screen.dart';
import 'transition.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => buildSlideTransitionPage(const LoginScreen()),
    ),
    GoRoute(
      path: '/dashboard0',
      pageBuilder: (context, state) => buildSlideTransitionPage(const DashBoard()),
    ),
    GoRoute(
      path: '/detail',
      pageBuilder: (context, state) => buildSlideTransitionPage(const DetailScreen()),
    ),
    GoRoute(
      path: '/timeseries',
      pageBuilder: (context, state) => buildSlideTransitionPage(const TimeSeriesScreen()),
    ),
    GoRoute(
      path: '/twin',
      pageBuilder: (context, state) => buildSlideTransitionPage(const DigitalTwinScreen()),
    ),
    GoRoute(
      path: '/admin',
      pageBuilder: (context, state) => buildSlideTransitionPage(const AdminScreen()),
    ),
  ],
);
