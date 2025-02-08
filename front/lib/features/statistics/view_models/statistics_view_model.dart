import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/features/statistics/data/models/statistics_model.dart';
import 'package:kkulkkulk/features/statistics/data/repositories/statistics_repository.dart';
import 'package:kkulkkulk/common/network/dio_client.dart';

class StatisticsViewModel extends StateNotifier<AsyncValue<StatisticsModel>> {
  final StatisticsRepository _repository;

  StatisticsViewModel(this._repository) : super(const AsyncValue.loading()) {
    loadWeeklyStatistics();
  } // ✅ 화면 처음 로드 시 API 실행

  Future<void> loadWeeklyStatistics() async {
    try {
      final data = await _repository.fetchWeeklyStatistics();
      state = AsyncValue.data(data);
    } catch (e) {
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

final statisticsProvider =
    StateNotifierProvider<StatisticsViewModel, AsyncValue<StatisticsModel>>(
  (ref) {
    return StatisticsViewModel(ref.watch(statisticsRepositoryProvider));
  },
);
