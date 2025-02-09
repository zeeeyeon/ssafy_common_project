import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/statistics_view_model.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> periods = [
    'weekly',
    'monthly',
    'year'
  ]; // API 요청용 period 값

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData(periods[0]); // 초기 로딩: 주간 데이터
  }

  /// ✅ 선택된 탭에 따라 데이터 로드
  void _loadData(String period) {
    ref.read(statisticsProvider(period).notifier).loadStatistics(
          userId: 1,
          date: '2025-02-01', // 기본 날짜 (선택 가능하도록 나중에 수정)
          period: period,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ✅ TabBar
          TabBar(
            controller: _tabController,
            onTap: (index) {
              _loadData(periods[index]); // 선택한 탭의 데이터 로드
            },
            tabs: const [
              Tab(text: '주간'),
              Tab(text: '월간'),
              Tab(text: '연간'),
            ],
          ),

          // ✅ TabBarView - 주간, 월간, 연간 통계 데이터 표시
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

  /// ✅ 스크롤 가능한 통계 뷰
  Widget _buildScrollableStatisticsView(String period) {
    final statisticsState = ref.watch(statisticsProvider(period));

    return statisticsState.when(
      data: (stats) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(), // ✅ 부드러운 스크롤 효과
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 10),

                // ✅ 반응형 통계 카드
                Row(
                  children: [
                    Expanded(
                        child: _buildStatCard(
                            '장소', '${stats.climbGround.climbGround}곳')),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _buildStatCard(
                            '방문 횟수', '${stats.climbGround.visited}회')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                        child: _buildStatCard('달성율', '${stats.successRate}%')),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _buildStatCard('시도 횟수', '${stats.tryCount}회')),
                  ],
                ),

                const SizedBox(height: 20),

                // ✅ 막대 그래프 (높이가 많아지면 스크롤 가능)
                _buildBarChart(stats),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('데이터 로드 실패: $e')),
    );
  }

  /// ✅ 개별 통계 카드 UI
  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 80, 118, 232),
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

  /// ✅ 막대 그래프 UI (가로형 + 성공 횟수 / 시도 횟수 표시)
  Widget _buildBarChart(statistics) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ...statistics.holds.map((hold) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                children: [
                  // 🔹 색상 원형 아이콘
                  _buildColorCircle(hold.color),
                  const SizedBox(width: 12),

                  // 🔹 가로 막대 그래프 (텍스트 추가)
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double maxWidth = constraints.maxWidth;
                        double successRate = hold.tryCount > 0
                            ? (hold.success / hold.tryCount) * 100
                            : 0; // 성공률 (0~100%)
                        double barWidth = (hold.tryCount > 0)
                            ? (hold.success / hold.tryCount) * maxWidth
                            : 0;

                        return Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            // 🔸 배경 바 (연한 회색)
                            Container(
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color: Colors.black54, width: 0.8),
                              ),
                            ),

                            // 🔸 실제 데이터 값 (컬러 바)
                            Container(
                              width: barWidth,
                              height: 24,
                              decoration: BoxDecoration(
                                color: _getColorFromName(hold.color),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color: Colors.black54, width: 0.8),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 2,
                                    offset: Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),

                            // 🔹 성공 횟수 / 시도 횟수 텍스트 추가
                            Positioned.fill(
                              child: Align(
                                alignment:
                                    Alignment.centerRight, // ✅ 막대 내부에서 오른쪽 정렬
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 8), // ✅ 텍스트가 막대 끝에 붙지 않도록 여백 추가
                                  child: Text(
                                    '${hold.success} / ${hold.tryCount} (${successRate.toStringAsFixed(1)}%)',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  /// ✅ 색상 원형 아이콘 (크기 증가)
  Widget _buildColorCircle(String colorName) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: _getColorFromName(colorName),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black54, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2,
            offset: Offset(1, 1),
          ),
        ],
      ),
    );
  }

  /// ✅ 클라이밍 홀드 색상 변환 함수
  Color _getColorFromName(String colorName) {
    switch (colorName.toUpperCase()) {
      case 'RED':
        return Colors.red;
      case 'ORANGE':
        return Colors.orange;
      case 'YELLOW':
        return Colors.yellow;
      case 'GREEN':
        return Colors.green;
      case 'BLUE':
        return const Color.fromARGB(255, 4, 83, 148);
      case 'SODOMY':
        return const Color.fromARGB(255, 43, 1, 114);
      case 'PURPLE':
        return Colors.purple;
      case 'BROWN':
        return Colors.brown;
      case 'PINK':
        return Colors.pink;
      case 'GRAY':
        return Colors.grey;
      case 'BLACK':
        return Colors.black;
      case 'WHITE':
        return Colors.white;
      case 'SKYBLUE':
        return const Color.fromARGB(255, 130, 192, 220);
      case 'LIGHT_GREEN':
        return Colors.lightGreen;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
