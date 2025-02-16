import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/common/widgets/layout/main_layout.dart';
import 'package:kkulkkulk/features/auth/screens/oauth_register_screen.dart';
import 'package:kkulkkulk/features/calendar/screens/calendar_screen.dart';
import 'package:kkulkkulk/features/calendar/screens/calendar_detail_screen.dart';
import 'package:kkulkkulk/features/camera/screens/album_screen.dart';
import 'package:kkulkkulk/features/camera/screens/camera_screen.dart';
import 'package:kkulkkulk/features/challenge/screens/challenge_detail_screen.dart';
import 'package:kkulkkulk/features/camera/screens/video_player_screen.dart';
import 'package:kkulkkulk/features/challenge/screens/challenge_screen.dart';
import 'package:kkulkkulk/features/place/screens/place_detail_screen.dart';
import 'package:kkulkkulk/features/place/screens/place_screen.dart';
import 'package:kkulkkulk/features/profile/screens/profile_screen.dart';
import 'package:kkulkkulk/features/splash/screens/splash_screen.dart';
import 'package:kkulkkulk/features/statistics/screens/statistics_screen.dart';
import 'package:kkulkkulk/features/auth/screens/login_screen.dart';
import 'package:kkulkkulk/features/auth/screens/register_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// 현재 선택된 탭 인덱스를 관리하는 provider
final selectedTabIndexProvider = StateProvider<int>((ref) => 0);

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  // redirect: (BuildContext context, GoRouterState state) {
  //   // 스플래시 화면 처리
  //   if (state.uri.toString() == '/' &&
  //       !state.extra.toString().contains('restart')) {
  //     return null;
  //   }
  //   return '/';
  // },
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
    GoRoute(
      path: '/oauth',
      builder: (context, state) => const OauthRegisterScreen(),
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
        GoRoute(
          path: '/album',
          builder: (context, state) => const AlbumScreen(),
        ),
      ],
    ),
    // 전체 화면으로 표시되는 라우트들
    GoRoute(
      path: '/camera',
      builder: (context, state) => const CameraScreen(),
      parentNavigatorKey: _rootNavigatorKey,
    ),

    // 비디오 플레이어 라우트도 ShellRoute 밖에 있음
    GoRoute(
      path: '/video-player',
      builder: (context, state) {
        final videoUrl = state.extra as Map<String, dynamic>;
        return VideoPlayerScreen(
          videoUrl['url'],
          videoUrl['date'],
          videoUrl['isSuccess'],
        );
      },
      parentNavigatorKey: _rootNavigatorKey,
    ),
    GoRoute(
      path: '/place/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return PlaceDetailScreen(id: id);
      },
    ),
    GoRoute(
      path: '/challenge/detail/:climbGroundId',
      builder: (context, state) {
        final climbGroundId = int.parse(state.pathParameters['climbGroundId']!);
        return ChallengeDetailScreen(
          climbGroundId: climbGroundId,
        );
      },
    )
  ],
);
