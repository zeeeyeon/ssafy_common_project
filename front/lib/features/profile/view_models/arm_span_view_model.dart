import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/features/profile/data/models/arm_span_model.dart';
import 'package:kkulkkulk/features/profile/data/repositories/arm_span_repository.dart';
import 'package:kkulkkulk/common/network/dio_client.dart';
import 'package:flutter/foundation.dart';

/// ✅ **팔길이 측정 상태 관리 ViewModel**
class ArmSpanViewModel extends StateNotifier<AsyncValue<ArmSpanResult>> {
  final ArmSpanRepository _repository;

  ArmSpanViewModel(this._repository)
      : super(AsyncValue.data(ArmSpanResult(armSpan: 0.0))); // ✅ 초기값 설정

  /// 🔥 **팔길이 측정 요청**
  Future<void> measureArmSpan(String imagePath, double height) async {
    debugPrint(
        "📌 [DEBUG] measureArmSpan() 호출됨: imagePath=$imagePath, height=$height");
    debugPrint("📌 [DEBUG] 현재 상태: $state");

    state = const AsyncValue.loading(); // ✅ 로딩 상태
    debugPrint("📌 [DEBUG] 상태 변경: Loading...");

    try {
      final result = await _repository.measureArmSpan(imagePath, height);
      debugPrint("📌 [DEBUG] 서버 응답 성공: ${result.armSpan}");

      state = AsyncValue.data(result); // ✅ 성공 시 상태 변경
      debugPrint("📌 [DEBUG] 상태 변경: $state");
    } catch (e, stackTrace) {
      debugPrint("❌ [ERROR] 팔길이 측정 실패: $e");
      debugPrint("❌ [ERROR] 스택 트레이스: $stackTrace");

      state = AsyncValue.error(e, stackTrace); // ❌ 실패 시 에러 처리
    }
  }
}

/// ✅ **Provider 등록**
final armSpanRepositoryProvider = Provider<ArmSpanRepository>(
  (ref) => ArmSpanRepository(DioClient()),
);

final armSpanViewModelProvider =
    StateNotifierProvider<ArmSpanViewModel, AsyncValue<ArmSpanResult>>(
  (ref) => ArmSpanViewModel(ref.watch(armSpanRepositoryProvider)),
);
