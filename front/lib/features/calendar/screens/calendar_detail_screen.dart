import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:go_router/go_router.dart';

final logger = Logger();

// ✅ 통계 데이터 관리 (완등률 포함)
final statisticsProvider =
    StateNotifierProvider<StatisticsNotifier, Map<String, String>>(
  (ref) => StatisticsNotifier(),
);

class StatisticsNotifier extends StateNotifier<Map<String, String>> {
  StatisticsNotifier()
      : super({"회차": "--", "완등 횟수": "--", "컨디션": "--", "완등률": "0"});

  void setStatistics(Map<String, String> newStats) {
    state = newStats;
  }
}

// ✅ 문제 데이터 관리 (색상 코드 사용)
final problemProvider =
    StateNotifierProvider<ProblemNotifier, List<Map<String, dynamic>>>(
  (ref) => ProblemNotifier(),
);

class ProblemNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  ProblemNotifier() : super([]);

  void setProblems(List<Map<String, dynamic>> problems) {
    state = problems;
  }
}

// ✅ 클라이밍장 난이도 관리
final difficultyProvider =
    StateNotifierProvider<DifficultyNotifier, List<Map<String, dynamic>>>(
  (ref) => DifficultyNotifier(),
);

class DifficultyNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  DifficultyNotifier() : super([]);

  void setDifficulties(List<Map<String, dynamic>> difficulties) {
    state = difficulties;
  }
}

class CalendarDetailScreen extends ConsumerStatefulWidget {
  final String date;

  const CalendarDetailScreen({
    super.key,
    required this.date,
  });

  @override
  CalendarDetailScreenState createState() => CalendarDetailScreenState();
}

class CalendarDetailScreenState extends ConsumerState<CalendarDetailScreen> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    logger.i('📌 CalendarDetailScreen initState() 실행됨. 받은 날짜: ${widget.date}');

    try {
      final dateParts = widget.date.split('-');
      selectedDate = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      );
    } catch (e) {
      logger.e('❌ Date parsing error: ${e.toString()}');
      selectedDate = DateTime.now();
    }

    Future.microtask(() {
      fetchProblemData();
      fetchStatisticsData();
      fetchDifficultyData();
    });
  }

  Future<void> fetchProblemData() async {
    try {
      final double? dummyOpacity = _getDummyOpacity(selectedDate);
      int baseAttempts =
          (dummyOpacity != null) ? (dummyOpacity * 10).round() : 0;
      final dummyData = (dummyOpacity != null)
          ? [
              {
                "color": 0xFFFF0000,
                "success": (baseAttempts / 2).round(),
                "attempts": baseAttempts
              },
              {
                "color": 0xFFFFA500,
                "success": (baseAttempts / 3).round(),
                "attempts": baseAttempts
              },
              {
                "color": 0xFFFFFF00,
                "success": (baseAttempts / 4).round(),
                "attempts": baseAttempts
              },
            ]
          : [
              {"color": 0xFFFF0000, "success": 2, "attempts": 3},
              {"color": 0xFFFFA500, "success": 1, "attempts": 1},
              {"color": 0xFFFFFF00, "success": 1, "attempts": 2},
            ];
      ref.read(problemProvider.notifier).setProblems(dummyData);
    } catch (e) {
      logger.e('❌ fetchProblemData() 오류: ${e.toString()}');
    }
  }

  Future<void> fetchStatisticsData() async {
    try {
      final dummyStats = {
        "회차": "5",
        "완등 횟수": "12",
        "컨디션": "좋음",
        "완등률": "65",
      };
      ref.read(statisticsProvider.notifier).setStatistics(dummyStats);
    } catch (e) {
      logger.e('❌ fetchStatisticsData() 오류: ${e.toString()}');
    }
  }

  Future<void> fetchDifficultyData() async {
    try {
      final dummyData = [
        {"color": 0xFFFF0000}, // 🔴 빨강
        {"color": 0xFFFFA500}, // 🟠 주황
        {"color": 0xFFFFFF00}, // 🟡 노랑
        {"color": 0xFF008000}, // 🟢 초록
        {"color": 0xFF0000FF}, // 🔵 파랑
        {"color": 0xFF4B0082}, // 🟣 남색
        {"color": 0xFFEE82EE}, // 💜 보라
        {"color": 0xFF00CED1}, // 💠 청록
        {"color": 0xFF8A2BE2}, // 💜 보라 (다른 톤)
        {"color": 0xFFFF4500}, // 🟠 주황 (다른 톤)
      ];

      ref.read(difficultyProvider.notifier).setDifficulties(dummyData);
    } catch (e) {
      logger.e('❌ fetchDifficultyData() 오류: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final statistics = ref.watch(statisticsProvider);
    final double clearRate = double.tryParse(statistics["완등률"] ?? "0") ?? 0;
    final problems = ref.watch(problemProvider);
    final difficulties = ref.watch(difficultyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                if (context.mounted) {
                  context.go('/calendar');
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '클라이밍장 이름',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('통계',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Column(
              children: statistics.entries
                  .where((entry) => entry.key != "완등률")
                  .map((entry) => _buildStatItem(entry.key, entry.value))
                  .toList(),
            ),
            const SizedBox(height: 20),
            const Text('완등률',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            _buildProgressBar(clearRate, Colors.green),
            const SizedBox(height: 20),
            const Text('클라이밍장 난이도',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _difficultyGraph(difficulties),
            const SizedBox(height: 20),
            const Text('문제',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _problemList(problems),
            const SizedBox(height: 20),
            _buildAttemptStatus(_calculateTotalAttempts(problems)),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(double percentage, Color color) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Container(
          height: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey[300],
          ),
        ),
        FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: (percentage / 100).clamp(0.0, 1.0),
          child: Container(
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _difficultyGraph(List<Map<String, dynamic>> difficulties) {
    return Row(
      children: difficulties.map((difficulty) {
        return Expanded(
          child: Container(
            height: 25,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: Color(difficulty["color"]),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _problemList(List<Map<String, dynamic>> problems) {
    if (problems.isEmpty) {
      return const Text('도전한 문제가 없습니다.');
    }

    return Column(
      children: problems.map((problem) {
        return _buildProblemItem(
            Color(problem["color"]), problem["success"], problem["attempts"]);
      }).toList(),
    );
  }

  Widget _buildProblemItem(Color color, int success, int attempts) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
          const SizedBox(width: 10),
          Text('$success/$attempts', style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.grey[300],
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: attempts > 0 ? success / attempts : 0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: color,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _calculateTotalAttempts(List<Map<String, dynamic>> problems) {
    return problems.fold(
        0, (sum, problem) => sum + (problem['attempts'] as int));
  }

  Widget _buildAttemptStatus(int totalAttempts) {
    double opacity;
    if (totalAttempts >= 20) {
      opacity = 1.0;
    } else if (totalAttempts >= 10) {
      opacity = 0.6;
    } else if (totalAttempts >= 5) {
      opacity = 0.3;
    } else {
      opacity = 0.1;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color.fromRGBO(33, 150, 243, opacity),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '총 시도 횟수: $totalAttempts회',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // 추가: 날짜별 dummy opacity 반환 (3,15,24 -> 0.3, 6,18 -> 0.6, 9,21 -> 0.9)
  double? _getDummyOpacity(DateTime date) {
    if (date.day == 3 || date.day == 15 || date.day == 24) return 0.3;
    if (date.day == 6 || date.day == 18) return 0.6;
    if (date.day == 9 || date.day == 21) return 0.9;
    return null;
  }
}
