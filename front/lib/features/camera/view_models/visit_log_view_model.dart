import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/features/camera/data/models/visit_log_model.dart';
import 'package:kkulkkulk/features/camera/data/repositories/visit_log_repository.dart';
import 'package:logger/logger.dart';

final logger = Logger();

/// 선택된 홀드를 관리하는 Provider
final selectedHoldProvider = StateProvider<Hold?>((ref) => null);

final visitLogViewModelProvider =
    StateNotifierProvider<VisitLogViewModel, AsyncValue<VisitLogResponse?>>(
  (ref) => VisitLogViewModel(ref.read(visitLogRepositoryProvider)),
);

class VisitLogViewModel extends StateNotifier<AsyncValue<VisitLogResponse?>> {
  final VisitLogRepository _repository;

  VisitLogViewModel(this._repository) : super(const AsyncValue.data(null));

  Future<void> fetchVisitLog() async {
    logger.d("방문 일지 조회 시작: state=${state.toString()}");

    state = const AsyncValue.loading();
    try {
      const latitude = 35.108829783;
      const longitude = 128.967147745;
      logger.d("현재 위치 확인: latitude=$latitude, longitude=$longitude");

      // TODO: userId는 실제 로그인된 사용자 ID로 변경 필요
      const userId = 1;

      final response = await _repository.createVisitLog(
        userId: userId,
        latitude: latitude,
        longitude: longitude,
      );

      state = AsyncValue.data(response);

      logger.d(
        "방문 일지 ${response.newlyCreated ? '생성' : '조회'} 성공: "
        "userDateId=${response.userDateId}, "
        "gymName=${response.name}",
      );
    } catch (e, stack) {
      logger.e("방문 일지 생성 실패", e, stack);
      state = AsyncValue.error(e, stack);
    }
  }
}
