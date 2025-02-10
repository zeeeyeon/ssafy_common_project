import 'package:flutter/material.dart';
import 'package:kkulkkulk/common/network/dio_client.dart';
import 'package:kkulkkulk/features/statistics/data/models/statistics_model.dart';

/// ✅ 통계 데이터를 API에서 가져오는 역할을 하는 Repository 클래스
class StatisticsRepository {
  final DioClient _dioClient;

  StatisticsRepository(this._dioClient);

  /// ✅ 주간, 월간, 연간 통계를 가져오는 함
  Future<StatisticsModel> fetchStatistics({
    required int userId,
    required String date,
    required String period,
  }) async {
    try {
      debugPrint('📡 API 요청 시작: $period 통계 조회 (userId=$userId, date=$date)');

      final response = await _dioClient.dio.get(
        '/api/user-climbground/$period', // ✅ 동적인 요청 URL
        queryParameters: {
          'userId': userId,
          'date': date,
        },
      );

      debugPrint('✅ API 응답 받음: ${response.data}');
      return StatisticsModel.fromJson(response.data); // ✅ JSON 데이터를 모델로 변환
    } catch (e) {
      debugPrint('❌ API 요청 실패 ($period) - $e');
      throw Exception('Failed to load $period statistics: $e');
    }
  }

  /// ✅ 특정 클라이밍장 통계를 가져오는 함수
  Future<ClimbingGymStatistics> fetchClimbingGymStatistics({
    required int userId,
    required int climbGroundId,
    required String date,
    required String period,
  }) async {
    try {
      debugPrint(
          '📡 API 요청 시작: 특정 클라이밍장 통계 조회 (userId=$userId, climbGroundId=$climbGroundId, date=$date)');

      final response = await _dioClient.dio.get(
        '/api/user-climbground/climb/$period', // ✅ 클라이밍장 개별 통계 API
        queryParameters: {
          'userId': userId,
          'climbGroundId': climbGroundId,
          'date': date,
        },
      );

      debugPrint('✅ API 응답 받음: ${response.data}');
      return ClimbingGymStatistics.fromJson(
          response.data); // ✅ JSON 데이터를 모델로 변환
    } catch (e) {
      debugPrint('❌ API 요청 실패 (특정 클라이밍장) - $e');
      throw Exception('Failed to load climbing gym statistics: $e');
    }
  }

  /// ✅ 특정 날짜에 방문한 클라이밍장 리스트 가져오기
  Future<List<ClimbingGym>> fetchClimbingGroundNames({
    required List<int> climbGroundIds, // ✅ 여러 클라이밍장 ID 리스트
  }) async {
    try {
      debugPrint(
          '📡 API 요청 시작: 방문한 장소 리스트 조회 (climbGroundIds=$climbGroundIds)');

      final response = await _dioClient.dio.post(
        '/api/climbground/my-climbground', // ✅ 변경된 API 엔드포인트
        data: {
          'climbGroundIds': climbGroundIds, // ✅ ID 리스트 전달
        },
      );

      debugPrint('✅ API 응답 받음: ${response.data}');

      // ✅ 응답에서 클라이밍장 리스트 변환
      return (response.data['content'] as List)
          .map((gym) => ClimbingGym.fromJson(gym))
          .toList();
    } catch (e) {
      debugPrint('❌ API 요청 실패 (방문한 장소 리스트) - $e');
      throw Exception('Failed to load climbing ground names: $e');
    }
  }
}
