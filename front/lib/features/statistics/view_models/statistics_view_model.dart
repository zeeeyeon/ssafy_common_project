import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/features/statistics/data/models/statistics_model.dart';
import 'package:kkulkkulk/features/statistics/data/repositories/statistics_repository.dart';
import 'package:kkulkkulk/common/network/dio_client.dart';

class StatisticsViewModel extends StateNotifier<AsyncValue<StatisticsModel>> {
  final StatisticsRepository _repository;

  StatisticsViewModel(this._repository) : super(const AsyncValue.loading());

  Future<void> loadStatistics({
    required int userId,
    required String date,
    required String period, // 'weekly', 'monthly', 'year'
  }) async {
    try {
      debugPrint(
          '📡 ViewModel: $period 통계 데이터 요청 (userId=$userId, date=$date)');
      final data = await _repository.fetchStatistics(
        userId: userId,
        date: date,
        period: period,
      );
      debugPrint('✅ ViewModel: $period 통계 데이터 성공적으로 로드됨');
      state = AsyncValue.data(data);
    } catch (e) {
      debugPrint('❌ ViewModel: $period 통계 데이터 로드 실패 - $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

/// ✅ 특정 클라이밍장 통계 ViewModel
class ClimbingGymStatisticsViewModel
    extends StateNotifier<AsyncValue<ClimbingGymStatistics>> {
  final StatisticsRepository _repository;

  ClimbingGymStatisticsViewModel(this._repository)
      : super(const AsyncValue.loading());

  /// ✅ 특정 클라이밍장 통계 불러오기
  Future<void> loadClimbingGymStatistics({
    required int userId,
    required int climbGroundId,
    required String date,
    required String period, // 'weekly', 'monthly', 'year'
  }) async {
    try {
      debugPrint(
          '📡 ViewModel: 특정 클라이밍장 데이터 요청 (userId=$userId, climbGroundId=$climbGroundId, date=$date)');
      final data = await _repository.fetchClimbingGymStatistics(
        userId: userId,
        climbGroundId: climbGroundId,
        date: date,
        period: period,
      );
      debugPrint('✅ ViewModel: 특정 클라이밍장 데이터 성공적으로 로드됨');
      state = AsyncValue.data(data);
    } catch (e) {
      debugPrint('❌ ViewModel: 특정 클라이밍장 데이터 로드 실패 - $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

/// ✅ 특정 날짜의 방문한 클라이밍장 리스트 ViewModel
class ClimbingGymListViewModel
    extends StateNotifier<AsyncValue<List<ClimbingGym>>> {
  final StatisticsRepository _repository;

  ClimbingGymListViewModel(this._repository)
      : super(const AsyncValue.loading());

  /// ✅ 특정 날짜의 방문한 클라이밍장 리스트 불러오기
  Future<void> loadClimbingGymList({
    required int userId,
    required List<int> climbGroundIds,
  }) async {
    try {
      debugPrint('📡 ViewModel: 방문한 클라이밍장 리스트 요청 시작');

      // ✅ 기존 데이터 초기화 (UI가 즉시 반영됨)
      state = const AsyncValue.loading();

      // ✅ 최소 로딩 시간 보장 (1초)
      final stopwatch = Stopwatch()..start();

      final climbingGymList = await _repository.fetchClimbingGroundNames(
        climbGroundIds: climbGroundIds,
      );

      // ✅ 최소 1초 로딩 유지
      final elapsedTime = stopwatch.elapsedMilliseconds;
      if (elapsedTime < 1000) {
        await Future.delayed(Duration(milliseconds: 1000 - elapsedTime));
      }

      debugPrint('✅ ViewModel: 방문한 클라이밍장 리스트 성공적으로 로드됨');

      // ✅ API 응답을 받은 후 UI 업데이트
      state = AsyncValue.data(climbingGymList);
    } catch (e) {
      debugPrint('❌ ViewModel: 방문한 클라이밍장 리스트 로드 실패 - $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

/// ✅ 일반 통계 데이터 Provider(UI에서 데이터 구독 가능)
final statisticsRepositoryProvider = Provider<StatisticsRepository>(
  (ref) {
    return StatisticsRepository(DioClient());
  },
);

final statisticsProvider = StateNotifierProvider.family<StatisticsViewModel,
    AsyncValue<StatisticsModel>, String>(
  (ref, period) {
    final repository = ref.watch(statisticsRepositoryProvider);
    final viewModel = StatisticsViewModel(repository);

    return viewModel;
  },
);

/// ✅ 특정 클라이밍장 통계 데이터 Provider
final climbingGymStatisticsProvider = StateNotifierProvider<
    ClimbingGymStatisticsViewModel, AsyncValue<ClimbingGymStatistics>>(
  (ref) {
    return ClimbingGymStatisticsViewModel(
        ref.watch(statisticsRepositoryProvider));
  },
);

//// ✅ 특정 날짜의 방문한 클라이밍장 리스트 Provider
final climbingGymListProvider = StateNotifierProvider<ClimbingGymListViewModel,
    AsyncValue<List<ClimbingGym>>>(
  (ref) {
    return ClimbingGymListViewModel(ref.watch(statisticsRepositoryProvider));
  },
);
