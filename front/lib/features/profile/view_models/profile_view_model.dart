import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart'; // debugPrint 사용
import 'package:kkulkkulk/features/profile/data/models/profile_model.dart';
import 'package:kkulkkulk/features/profile/data/repositories/profile_repository.dart';
import 'package:kkulkkulk/common/network/dio_client.dart';

class ProfileViewModel extends StateNotifier<AsyncValue<UserProfile>> {
  final ProfileRepository _repository;

  ProfileViewModel(this._repository) : super(const AsyncValue.loading()) {
    fetchUserProfile(); // ✅ 생성자에서 자동 실행!
  }

  /// ✅ 사용자 프로필 가져오기
  Future<void> fetchUserProfile() async {
    debugPrint("📡 [ProfileViewModel] 프로필 데이터 요청 시작");
    try {
      final profile = await _repository.fetchUserProfile();
      debugPrint("✅ [ProfileViewModel] 프로필 데이터 수신: ${profile.toJson()}");
      state = AsyncValue.data(profile);
    } catch (e, stackTrace) {
      debugPrint("❌ [ProfileViewModel] 프로필 데이터 로딩 실패: $e");
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// ✅ 프로필 정보 업데이트 (성공 시 최신 데이터 다시 불러오기)
  Future<void> updateUserProfile(UserProfile updatedProfile) async {
    debugPrint("📡 [ProfileViewModel] 프로필 업데이트 요청 시작");
    try {
      await _repository.updateUserProfile(updatedProfile);
      debugPrint("✅ [ProfileViewModel] 프로필 업데이트 성공, 최신 데이터 불러오기");
      await fetchUserProfile(); // ✅ 최신 데이터 반영
    } catch (e, stackTrace) {
      debugPrint("❌ [ProfileViewModel] 프로필 업데이트 실패: $e");
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 🔥 팔길이 측정 요청
  Future<double> measureArmSpan(String imagePath, double height) async {
    try {
      final armSpan = await _repository.measureArmSpan(imagePath, height);
      return armSpan;
    } catch (e) {
      throw Exception("팔길이 측정 실패");
    }
  }
}

/// ✅ ProfileRepository Provider
final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(DioClient()),
);

/// ✅ ProfileViewModel Provider
final profileProvider =
    StateNotifierProvider<ProfileViewModel, AsyncValue<UserProfile>>(
  (ref) => ProfileViewModel(ref.watch(profileRepositoryProvider)),
);
