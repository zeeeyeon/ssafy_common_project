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
    'yearly'
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
                _buildStatisticsView('weekly'),
                _buildStatisticsView('monthly'),
                _buildStatisticsView('year'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ 통계 카드 UI
  Widget _buildStatisticsView(String period) {
    final statisticsState = ref.watch(statisticsProvider(period));

    return statisticsState.when(
      data: (stats) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('📅 ${period.toUpperCase()} 통계',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),

              const SizedBox(height: 10),

              // ✅ 통계 카드 UI (4개)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard('장소', '${stats.climbGround.climbGround}곳'),
                  _buildStatCard('방문 횟수', '${stats.climbGround.visited}회'),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard('달성율', '${stats.successRate}%'),
                  _buildStatCard('시도 횟수', '${stats.tryCount}회'),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('데이터 로드 실패: $e')),
    );
  }

  /// ✅ 개별 통계 카드 위젯
  Widget _buildStatCard(String title, String value) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// class StatisticsScreen extends StatelessWidget {
//   const StatisticsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('통계')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text('📊 통계 메인 화면'),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const StatisticsWeeklyScreen(),
//                   ),
//                 );
//               },
//               child: const Text('📅 주간 통계 보기'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const StatisticsMonthlyScreen(),
//                   ),
//                 );
//               },
//               child: const Text('📅 월간 통계 보기'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const StatisticsYearlyScreen(),
//                   ),
//                 );
//               },
//               child: const Text('📅 연간 통계 보기'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
