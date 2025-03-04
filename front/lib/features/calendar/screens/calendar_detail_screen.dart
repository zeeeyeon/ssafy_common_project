import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/features/calendar/data/repositories/calendar_repository.dart';
import 'package:logger/logger.dart';
import 'package:go_router/go_router.dart';
import 'package:kkulkkulk/common/utils/color_converter.dart';

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
  String? _climbGroundName;

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
      // Provider 상태 초기화
      ref
          .read(statisticsProvider.notifier)
          .setStatistics({"회차": "--", "완등 횟수": "--", "컨디션": "--", "완등률": "0"});
      ref.read(problemProvider.notifier).setProblems([]);
      ref.read(difficultyProvider.notifier).setDifficulties([]);

      setState(() {
        _climbGroundName = null;
      });

      fetchAllData();
    });
  }

  @override
  void didUpdateWidget(CalendarDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.date != widget.date) {
      // 날짜가 변경되었을 때도 Provider 상태 초기화
      ref
          .read(statisticsProvider.notifier)
          .setStatistics({"회차": "--", "완등 횟수": "--", "컨디션": "--", "완등률": "0"});
      ref.read(problemProvider.notifier).setProblems([]);
      ref.read(difficultyProvider.notifier).setDifficulties([]);

      setState(() {
        _climbGroundName = null;
      });

      Future.microtask(() {
        fetchAllData();
      });
    }
  }

  Future<void> fetchAllData() async {
    try {
      // userId 파라미터 제거
      final detail = await ref
          .read(calendarRepositoryProvider)
          .fetchDailyData(selectedDate);

      // 클라이밍장 이름 업데이트
      setState(() {
        _climbGroundName = detail.climbGroundName;
      });

      // 통계 업데이트
      ref.read(statisticsProvider.notifier).setStatistics({
        "회차": detail.visitCount.toString(),
        "완등 횟수": detail.successCount.toString(),
        "컨디션": _getConditionFromCompletionRate(detail.completionRate),
        "완등률": detail.completionRate.toStringAsFixed(1),
      });

      // 문제 데이터 업데이트
      List<Map<String, dynamic>> problems = [];
      detail.colorAttempts.forEach((colorName, attempts) {
        final success = detail.colorSuccesses[colorName] ?? 0;
        problems.add({
          "color": ColorConverter.fromString(colorName),
          "attempts": attempts,
          "success": success,
        });
      });
      ref.read(problemProvider.notifier).setProblems(problems);

      // 난이도 업데이트
      List<Map<String, dynamic>> difficulties = [];
      for (var color in detail.holdColorLevel.keys) {
        difficulties.add({
          "color": ColorConverter.fromString(color),
        });
      }
      ref.read(difficultyProvider.notifier).setDifficulties(difficulties);
    } catch (e) {
      logger.e('❌ fetchAllData() 오류: ${e.toString()}');
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
      body: SingleChildScrollView(
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
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _climbGroundName ?? '클라이밍장 이름',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
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
            _buildProgressBar(clearRate, const Color.fromARGB(255, 0, 123, 49)),
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
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: Text(
              '${percentage.toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
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
              color: difficulty["color"] as Color,
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
            problem["color"] as Color, problem["success"], problem["attempts"]);
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 248, 139, 5),
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

  // 헬퍼 함수: 완등률에 따른 컨디션 문자열 반환
  String _getConditionFromCompletionRate(double rate) {
    if (rate >= 50) return "좋음";
    if (rate >= 30) return "보통";
    return "나쁨";
  }
}
