import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../screen/dashboard_screen.dart';
import '../screen/detail_screen.dart';
import '../screen/digitaltwin_screen.dart';
import '../screen/timeseries_screen.dart';
import '../screen/admin_screen.dart';
import '../screen/login_screen.dart';
import '../screen/forbidden_screen.dart';
import '../screen/find_account_screen.dart';
import 'transition.dart';
import 'package:iot_dashboard/utils/auth_service.dart';
import 'package:iot_dashboard/component/dialog_form.dart';


final router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final isLoggedIn = AuthService.isAuthenticated();
    final isAdmin = AuthService.isAdmin();
    final path = state.uri.path;

    final isLogin = path == '/login';
    final isFindAccount = path == '/find_account';

    // 비로그인 사용자는 로그인/아이디찾기 외 접근 차단
    if (!isLoggedIn && !(isLogin || isFindAccount)) {
      return '/login';
    }

    // 로그인된 사용자는 /login 재접근 차단
    if (isLoggedIn && isLogin) {
      return '/dashboard0';
    }

    if (path == '/admin' && !isAdmin) {
      return '/forbidden';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => buildSlideTransitionPage(LoginScreen()),
    ),
    GoRoute(
      path: '/find_account',
      pageBuilder: (context, state) {
        final tab = state.uri.queryParameters['tab'] ?? 'id';
        return buildSlideTransitionPage(FindAccountScreen(tab: tab));
      },
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
    GoRoute(
      path: '/forbidden',
      pageBuilder: (context, state) =>
          buildSlideTransitionPage(const ForbiddenScreen()),
    ),

  ],
);
