import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/statistics_view_model.dart';
import 'package:intl/intl.dart';
import 'components/statistics_header.dart';
import 'components/statistics_card.dart';
import 'components/statistics_bar_chart.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> periods = ['weekly', 'monthly', 'year'];
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData(periods[0]);
  }

  void _loadData(String period) {
    String requestDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    ref.read(statisticsProvider(period).notifier).loadStatistics(
          userId: 1,
          date: requestDate,
          period: period,
        );
  }

  void _changeDate(String period, int amount) {
    setState(() {
      if (period == 'weekly') {
        selectedDate = selectedDate.add(Duration(days: amount));
      } else if (period == 'monthly') {
        selectedDate =
            DateTime(selectedDate.year, selectedDate.month + amount, 1);
      } else {
        selectedDate = DateTime(selectedDate.year + amount, 1, 1);
      }
    });
    _loadData(period);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            onTap: (index) {
              _loadData(periods[index]);
            },
            tabs: const [
              Tab(text: '주간'),
              Tab(text: '월간'),
              Tab(text: '연간'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildScrollableStatisticsView('weekly'),
                _buildScrollableStatisticsView('monthly'),
                _buildScrollableStatisticsView('year'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableStatisticsView(String period) {
    final statisticsState = ref.watch(statisticsProvider(period));

    return statisticsState.when(
      data: (stats) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                StatisticsHeader(
                  period: period,
                  selectedDate: selectedDate,
                  onDateChange: _changeDate,
                ),
                Row(
                  children: [
                    Expanded(
                        child: StatisticsCard(
                            title: '장소',
                            value: '${stats.climbGround.climbGround}곳')),
                    const SizedBox(width: 8),
                    Expanded(
                        child: StatisticsCard(
                            title: '방문 횟수',
                            value: '${stats.climbGround.visited}회')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                        child: StatisticsCard(
                            title: '달성율', value: '${stats.successRate}%')),
                    const SizedBox(width: 8),
                    Expanded(
                        child: StatisticsCard(
                            title: '시도 횟수', value: '${stats.tryCount}회')),
                  ],
                ),
                const SizedBox(height: 20),
                StatisticsBarChart(stats: stats),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('데이터 로드 실패: $e')),
    );
  }
}
