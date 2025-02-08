import 'package:flutter/material.dart';
import 'statistics_weekly_screen.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('통계 화면')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📊 통계 메인 화면'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StatisticsWeeklyScreen(),
                  ),
                );
              },
              child: const Text('📅 주간 통계 보기'),
            ),
          ],
        ),
      ),
    );
  }
}
