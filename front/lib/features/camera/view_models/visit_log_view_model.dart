import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/features/camera/data/models/visit_log_model.dart';
import 'package:kkulkkulk/features/camera/data/repositories/visit_log_repository.dart';
import 'package:logger/logger.dart';
import 'package:kkulkkulk/common/storage/storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

final logger = Logger();

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

      // 토큰에서 userId 가져오기
      final token = await Storage.getToken();
      if (token == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final decodedToken = JwtDecoder.decode(token.replaceAll("Bearer ", ''));
      final userId = decodedToken['id'] as int;
      logger.d("토큰에서 가져온 userId: $userId");

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
      logger.e("방문 일지 조회 실패: $e");
      state = AsyncValue.error(e, stack);
    }
  }
}
