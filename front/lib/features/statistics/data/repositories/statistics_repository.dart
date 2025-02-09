import 'package:flutter/material.dart';
import 'package:kkulkkulk/common/network/dio_client.dart';
import 'package:kkulkkulk/features/statistics/data/models/statistics_model.dart';

class StatisticsRepository {
  final DioClient _dioClient;

  StatisticsRepository(this._dioClient);

  /// ✅ 주간, 월간, 연간 통계를 한 번에 처리하는 함수
  Future<StatisticsModel> fetchStatistics({
    required int userId,
    required String date, // YYYY-MM-DD 형식
    required String period, // 'weekly', 'monthly', 'year'
  }) async {
    try {
      debugPrint('📡 API 요청 시작: $period 통계 조회 (userId=$userId, date=$date)');

      final response = await _dioClient.dio.get(
        '/api/user-climbground/$period', // ✅ 요청 URL을 동적으로 변경
        queryParameters: {
          'userId': userId,
          'date': date,
        },
      );

      debugPrint('✅ API 응답 받음: ${response.data}');
      return StatisticsModel.fromJson(response.data);
    } catch (e) {
      debugPrint('❌ API 요청 실패 ($period) - $e');
      throw Exception('Failed to load $period statistics: $e');
    }
  }
}
