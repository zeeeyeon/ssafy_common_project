import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/features/statistics/view_models/statistics_view_model.dart';
import 'package:intl/intl.dart';
import '../components/statistics_bar_chart.dart';

class ClimbingGymStatisticsScreen extends ConsumerStatefulWidget {
  final int climbGroundId;
  final String gymName;

  const ClimbingGymStatisticsScreen({
    super.key,
    required this.climbGroundId,
    required this.gymName,
  });

  @override
  ConsumerState<ClimbingGymStatisticsScreen> createState() =>
      _ClimbingGymStatisticsScreenState();
}

class _ClimbingGymStatisticsScreenState
    extends ConsumerState<ClimbingGymStatisticsScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    String requestDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    ref.read(climbingGymStatisticsProvider.notifier).loadClimbingGymStatistics(
          userId: 1,
          climbGroundId: widget.climbGroundId,
          date: requestDate,
          period: 'year', // ✅ 연간 통계 요청
        );
  }

  void _changeDate(int amount) {
    setState(() {
      selectedDate = DateTime(selectedDate.year + amount, 1, 1);
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final gymStatisticsState = ref.watch(climbingGymStatisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gymName, style: const TextStyle(fontSize: 18)),
        centerTitle: true,
      ),
      body: gymStatisticsState.when(
        data: (stats) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ 날짜 변경 UI
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => _changeDate(-1),
                    ),
                    Text(
                      DateFormat('yyyy').format(selectedDate),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => _changeDate(1),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ✅ 통계 카드 (총 방문 횟수, 달성율, 시도 횟수)
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard('총 방문 횟수', '${stats.totalVisited}회',
                          Colors.blueAccent),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                          '달성율', '${stats.successRate}%', Colors.blueAccent),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                          '시도 횟수', '${stats.tryCount}회', Colors.blueAccent),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ✅ 막대 그래프 (성공률)
                StatisticsBarChart(stats: stats),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('데이터 로드 실패: $e')),
      ),
    );
  }

  /// ✅ 개별 통계 카드 UI
  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
