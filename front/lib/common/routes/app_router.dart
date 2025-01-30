import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kkulkkulk/common/widgets/layout/main_layout.dart';
import 'package:kkulkkulk/features/calendar/screens/calendar_screen.dart';
import 'package:kkulkkulk/features/calendar/screens/calendar_detail_screen.dart';
import 'package:kkulkkulk/features/camera/screens/camera_screen.dart';
import 'package:kkulkkulk/features/challenge/screens/challenge_screen.dart';
import 'package:kkulkkulk/features/place/screens/place_screen.dart';
import 'package:kkulkkulk/features/profile/screens/profile_screen.dart';
import 'package:kkulkkulk/features/splash/screens/splash_screen.dart';
import 'package:kkulkkulk/features/statistics/screens/statistics_screen.dart';
import 'package:kkulkkulk/features/auth/screens/login_screen.dart';
import 'package:kkulkkulk/features/auth/screens/register_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  redirect: (BuildContext context, GoRouterState state) {
    if (state.uri.toString() != '/' &&
        !state.extra.toString().contains('restart')) {
      return null;
    }
    return '/';
  },
  routes: [
    // 스플래시 화면을 최상단에 배치
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    // 인증 관련 화면
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // 메인 레이아웃을 포함하는 Shell Route
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const CalendarScreen(),
          routes: [
            GoRoute(
              path: 'detail/:date',
              builder: (context, state) {
                final date = state.pathParameters['date']!;
                return CalendarDetailScreen(date: date);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/challenge',
          builder: (context, state) => const ChallengeScreen(),
        ),
        GoRoute(
          path: '/place',
          builder: (context, state) => const PlaceScreen(),
        ),
        GoRoute(
          path: '/statistics',
          builder: (context, state) => const StatisticsScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    // 전체 화면으로 표시되는 라우트들
    GoRoute(
      path: '/camera',
      builder: (context, state) => const CameraScreen(),
      parentNavigatorKey: _rootNavigatorKey,
    ),
  ],
);
