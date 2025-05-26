import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import '../screen/dashboard_screen.dart';
import '../screen/detail_screen.dart';
import '../screen/digitaltwin_screen.dart';
import '../screen/timeseries_screen.dart';
import '../screen/admin_screen.dart';
import '../screen/login_screen.dart';
import '../screen/find_account_screen.dart';
import 'transition.dart';
import 'package:iot_dashboard/utils/auth_service.dart';


final router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final isLoggedIn = AuthService.isAuthenticated();
    final path = state.uri.path;

    final isLogin = path == '/login';
    final isFindAccount = path == '/find_account';

    // 🔓 로그인 안 한 사용자도 이 두 경로는 접근 허용
    if (!isLoggedIn && !(isLogin || isFindAccount)) {
      return '/login';
    }

    // 🔐 로그인한 사용자가 다시 /login 접근 못 하게 막기
    if (isLoggedIn && isLogin) {
      return '/dashboard0';
    }

    return null;
  }
  ,
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
  ],
);
