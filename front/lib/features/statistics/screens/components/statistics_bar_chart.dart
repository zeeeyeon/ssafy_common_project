import 'package:flutter/material.dart';
import 'statistics_colors.dart';

/// ✅ 막대 그래프 UI
class StatisticsBarChart extends StatelessWidget {
  final dynamic stats;

  const StatisticsBarChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: stats.holds.map<Widget>((hold) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              children: [
                // 🔹 색상 원형 아이콘
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: getColorFromName(hold.color),
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
                ),
                const SizedBox(width: 12),

                // 🔹 가로 막대 그래프
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
                              border:
                                  Border.all(color: Colors.black54, width: 0.8),
                            ),
                          ),

                          // 🔸 실제 데이터 값 (컬러 바)
                          Container(
                            width: barWidth,
                            height: 24,
                            decoration: BoxDecoration(
                              color: getColorFromName(hold.color),
                              borderRadius: BorderRadius.circular(4),
                              border:
                                  Border.all(color: Colors.black54, width: 0.8),
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
                                    right: 8), // ✅ 텍스트 여백 추가
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
      ),
    );
  }
}
