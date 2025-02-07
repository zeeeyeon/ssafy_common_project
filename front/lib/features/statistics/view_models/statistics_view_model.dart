// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../data/repositories/statistics_repository.dart';
// import '../data/models/statistics_model.dart';

// final statisticsRepositoryProvider = Provider<StatisticsRepository>((ref) {
//   return StatisticsRepository();
// });

// final statisticsProvider =
//     StateNotifierProvider<StatisticsNotifier, AsyncValue<StatisticsModel>>(
//   (ref) => StatisticsNotifier(ref.watch(statisticsRepositoryProvider)),
// );

// class StatisticsNotifier extends StateNotifier<AsyncValue<StatisticsModel>> {
//   final StatisticsRepository repository;

//   StatisticsNotifier(this.repository) : super(const AsyncLoading());

//   Future<void> fetchWeeklyStatistics(int userId, String date) async {
//     if (state.isLoading) {
//       print('⏳ 요청 중복 방지: 이미 로딩 상태입니다.');
//       return;
//     }

//     state = const AsyncLoading();
//     print('⏳ ViewModel: 상태를 AsyncLoading으로 설정');

//     try {
//       // 올바른 값으로 API 호출
//       print('🔄 API 호출 중: userId=$userId, date=$date');
//       final data = await repository.fetchWeeklyStatistics(userId, date);

//       print('✅ ViewModel: 데이터 로드 성공');
//       state = AsyncValue.data(data);
//     } catch (e, stackTrace) {
//       print('❌ ViewModel: 데이터 로드 실패 - $e');
//       state = AsyncValue.error(e, stackTrace);
//     }
//   }
// }

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/statistics_repository.dart';
import '../data/models/statistics_model.dart';
import 'package:kkulkkulk/common/network/dio_client.dart';

// StatisticsRepository를 제공하는 Provider
final statisticsRepositoryProvider = Provider<StatisticsRepository>((ref) {
  return StatisticsRepository(); // DioClient는 내부에서 자동 생성됨
});

// StateNotifierProvider를 사용하여 상태 관리
final statisticsProvider =
    StateNotifierProvider<StatisticsNotifier, AsyncValue<Map<String, dynamic>>>(
  (ref) => StatisticsNotifier(ref.watch(statisticsRepositoryProvider)),
);

// StateNotifier 클래스
class StatisticsNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final StatisticsRepository repository;

  StatisticsNotifier(this.repository) : super(const AsyncLoading());

  // 주별 통계 데이터를 가져오는 메서드
  Future<void> fetchWeeklyStatistics(int userId, String date) async {
    state = const AsyncLoading(); // 로딩 상태 설정
    try {
      final data = await repository.fetchWeeklyStatistics(
          userId, date); // Repository에서 데이터 가져오기
      state = AsyncValue.data(data); // 성공 상태로 업데이트
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace); // 에러 상태로 업데이트
    }
  }
}
