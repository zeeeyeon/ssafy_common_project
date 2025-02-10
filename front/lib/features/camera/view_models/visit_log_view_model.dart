import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/features/camera/data/models/visit_log_model.dart';
import 'package:kkulkkulk/features/camera/data/repositories/visit_log_repository.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

final logger = Logger();

final visitLogViewModelProvider =
    AsyncNotifierProvider<VisitLogViewModel, VisitLogResponse?>(
        () => VisitLogViewModel());

class VisitLogViewModel extends AsyncNotifier<VisitLogResponse?> {
  late final VisitLogRepository _repository;

  @override
  Future<VisitLogResponse?> build() async {
    _repository = ref.read(visitLogRepositoryProvider);
    return null;
  }

  Future<void> fetchVisitLog() async {
    state = const AsyncLoading();
    try {
      // 현재 위치 가져오기
      final position = await Geolocator.getCurrentPosition();

      // 현재 날짜 가져오기
      final now = DateTime.now();
      final dateStr =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      // TODO: userId는 실제 로그인된 사용자 ID로 변경 필요
      const userId = 1;

      final response = await _repository.createVisitLog(
        userId: userId,
        latitude: position.latitude,
        longitude: position.longitude,
        date: dateStr,
      );

      state = AsyncData(response);
    } catch (e, stack) {
      logger.e("방문 일지 조회 실패", e, stack);
      state = AsyncError(e, stack);
    }
  }
}
