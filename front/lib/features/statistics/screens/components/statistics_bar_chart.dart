import 'package:flutter/material.dart';
import 'statistics_colors.dart';

/// ✅ 막대 그래프 UI (정렬 및 공백 추가 로직 수정)
class StatisticsBarChart extends StatelessWidget {
  final dynamic stats;

  const StatisticsBarChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: stats.holds.map<Widget>((hold) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🔹 색상 원형 아이콘 (왼쪽 정렬)
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: getColorFromName(hold.color),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),

                // 🔹 성공/시도 횟수 텍스트 (아이콘 오른쪽, 공백 추가)
                Text(
                  '${hold.success}/${hold.tryCount}${' ' * _getPaddingCount(hold.success, hold.tryCount)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 8), // ✅ 텍스트와 막대 사이 간격 조정

                // 🔹 가로 막대 그래프
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double maxWidth = constraints.maxWidth;
                      double successRate = hold.tryCount > 0
                          ? (hold.success / hold.tryCount)
                          : 0; // 성공률 (0~1 범위)
                      double barWidth = successRate * maxWidth;

                      return Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          // 🔸 배경 바 (연한 회색)
                          Container(
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.grey[300], // ✅ 더 연한 회색
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),

                          // 🔸 실제 데이터 값 (컬러 바)
                          Container(
                            width: barWidth,
                            height: 20,
                            decoration: BoxDecoration(
                              color: getColorFromName(hold.color),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // 🔹 퍼센트 텍스트 (막대 우측 정렬)
                Text(
                  '${(hold.success / hold.tryCount * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// ✅ 공백 개수를 결정하는 함수 (cnt 값에 따라 다르게 적용)
  int _getPaddingCount(int success, int tryCount) {
    int cnt = 0;
    if (success >= 10) cnt++; // 성공 횟수가 10 이상이면 cnt++
    if (tryCount >= 10) cnt++; // 시도 횟수가 10 이상이면 cnt++

    // ✅ cnt 값에 따른 공백 적용
    if (cnt == 0) return 4; // 공백 4게
    if (cnt == 1) return 2; // 공백 2개
    return 0; // cnt == 2이면 공백 없음
  }
}
