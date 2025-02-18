import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/statistics_view_model.dart';
import 'package:intl/intl.dart';
import 'components/statistics_header.dart';
import 'components/statistics_card.dart';
import 'components/statistics_bar_chart.dart';
import 'components/climbing_gym_statistics_screen.dart';

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
      appBar: AppBar(
        title: TabBar(
            controller: _tabController,
            onTap: (index) {
              _loadData(periods[index]);
            },
            tabs: const [
              Tab(text: '주간'),
              Tab(text: '월간'),
              Tab(text: '연간'),
            ],
            labelColor: const Color.fromARGB(255, 248, 139, 5),
            indicatorColor: const Color.fromARGB(255, 248, 139, 5)),
      ),
      body: Column(
        children: [
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

  void _showLocationList(List<int> climbGroundIds) {
    final climbingGymListNotifier = ref.read(climbingGymListProvider.notifier);

    // ✅ 기존 데이터 초기화 후 API 요청
    climbingGymListNotifier.loadClimbingGymList(
      userId: 1,
      climbGroundIds: climbGroundIds,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final climbingGymListState = ref.watch(climbingGymListProvider);

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.5,
              maxChildSize: 0.9,
              minChildSize: 0.3,
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ 헤더
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '방문한 장소 목록',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const Divider(),

                      // ✅ 장소 리스트 상태 확인
                      Expanded(
                        child: climbingGymListState.when(
                          data: (climbingGyms) {
                            return ListView.builder(
                              controller: scrollController,
                              itemCount: climbingGyms.length,
                              itemBuilder: (context, index) {
                                final gym = climbingGyms[index];
                                return ListTile(
                                  leading: ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(10), // 더 부드러운 모서리
                                    child: Image.network(
                                      gym.image,
                                      width: 52, // ✅ 기존보다 1.3배 증가 (40 → 52)
                                      height: 52, // ✅ 기존보다 1.3배 증가 (40 → 52)
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  title: Text(
                                    gym.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5, // 가독성 향상
                                    ),
                                  ),
                                  subtitle: Text(
                                    gym.address,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600], // 부드러운 회색으로 조정
                                    ),
                                    overflow: TextOverflow
                                        .ellipsis, // 너무 긴 텍스트는 말줄임표 처리
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ClimbingGymStatisticsScreen(
                                          climbGroundId: gym.id,
                                          gymName: gym.name,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Center(child: Text('데이터 로드 실패: $e')),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
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
                const SizedBox(height: 0),
                StatisticsHeader(
                  period: period,
                  selectedDate: selectedDate,
                  onDateChange: _changeDate,
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showLocationList(
                            stats.climbGround.list), // ✅ 클릭 시 모달 표시
                        child: StatisticsCard(
                          title: '장소',
                          value: '${stats.climbGround.climbGround}곳 🔎',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatisticsCard(
                        title: '방문 횟수',
                        value: '${stats.climbGround.visited}회',
                      ),
                    ),
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
