import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/features/profile/data/models/arm_span_model.dart';
import 'package:kkulkkulk/features/profile/data/repositories/arm_span_repository.dart';
import 'package:kkulkkulk/common/network/dio_client.dart';
import 'package:kkulkkulk/features/profile/data/models/arm_span_model.dart';

/// ✅ **팔길이 측정 상태 관리 ViewModel**
class ArmSpanViewModel extends StateNotifier<AsyncValue<ArmSpanResult>> {
  final ArmSpanRepository _repository;

  ArmSpanViewModel(this._repository)
      : super(AsyncValue.data(ArmSpanResult(armSpan: 0.0))); // 🔥 수정

  /// 🔥 **팔길이 측정 요청**
  Future<void> measureArmSpan(String imagePath, double height) async {
    state = const AsyncValue.loading(); // 🔵 로딩 상태로 변경

    try {
      final result = await _repository.measureArmSpan(imagePath, height);
      state = AsyncValue.data(result); // ✅ 성공: 데이터 저장
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace); // ❌ 실패: 에러 저장
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
