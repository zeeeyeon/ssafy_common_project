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

// Provider 설정, UI에서 데이터 구독 가능
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
