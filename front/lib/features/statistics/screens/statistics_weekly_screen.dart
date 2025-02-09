import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/statistics_view_model.dart';

class StatisticsWeeklyScreen extends ConsumerWidget {
  const StatisticsWeeklyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statisticsState = ref.watch(statisticsProvider('weekly'));

    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Statistics')),
      body: statisticsState.when(
        data: (stats) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('✅ 데이터 불러옴'),
                Text('장소: ${stats.climbGround.climbGround}'),
                Text('방문 횟수: ${stats.climbGround.visited}'),
                Text('달성율: ${stats.successRate}%'),
                Text('시도횟수: ${stats.tryCount}'),
                Text('홀더: ${stats.holds[0].color}'),
                Text('홀더 시도횟수: ${stats.holds[0].tryCount}'),
                Text('홀더 성공횟수: ${stats.holds[0].success}'),
              ],
            ),
          );
        },
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
        error: (e, _) {
          return Center(child: Text('데이터 로드 실패: $e'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(statisticsProvider('weekly').notifier).loadStatistics(
                userId: 1,
                date: '2025-02-01',
                period: 'weekly',
              );
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
