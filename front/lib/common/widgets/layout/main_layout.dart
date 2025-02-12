import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onTap(context, index),
        backgroundColor: Colors.white,
        elevation: 0,
        height: 60,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: Colors.transparent,
        destinations: [
          _buildNavDestination(
            context,
            Icons.emoji_events,
            '챌린지',
            0,
          ),
          _buildNavDestination(
            context,
            Icons.place,
            '장소',
            1,
          ),
          _buildNavDestination(
            context,
            Icons.home,
            '홈',
            2,
          ),
          _buildNavDestination(
            context,
            Icons.bar_chart,
            '통계',
            3,
          ),
          _buildNavDestination(
            context,
            Icons.person,
            '프로필',
            4,
          ),
        ],
      ),
    );
  }

  NavigationDestination _buildNavDestination(
    BuildContext context,
    IconData icon,
    String label,
    int index,
  ) {
    final isSelected = _calculateSelectedIndex(context) == index;
    return NavigationDestination(
      icon: Icon(
        icon,
        color: isSelected ? Colors.blue : Colors.grey,
      ),
      label: label,
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/challenge')) return 0;
    if (location.startsWith('/place')) return 1;
    if (location.startsWith('/calendar')) return 2;
    if (location.startsWith('/statistics')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 2; // 기본값은 홈(캘린더)
  }

  void _onTap(BuildContext context, int index) {
    final currentLocation = GoRouterState.of(context).uri.toString();
    final newLocation = _getLocationFromIndex(index);

    // 홈 탭으로 이동하거나 같은 탭을 누른 경우 새로고침
    if (newLocation == '/calendar' || currentLocation == newLocation) {
      context.go(newLocation, extra: {'isRefresh': true});
      return;
    }

    // 다른 탭으로 이동
    context.go(newLocation);
  }

  String _getLocationFromIndex(int index) {
    switch (index) {
      case 0:
        return '/challenge';
      case 1:
        return '/place';
      case 2:
        return '/calendar';
      case 3:
        return '/statistics';
      case 4:
        return '/profile';
      default:
        return '/calendar';
    }
  }
}
