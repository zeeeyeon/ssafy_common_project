import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/features/profile/data/models/profile_model.dart';
import 'package:kkulkkulk/features/profile/data/repositories/profile_repository.dart';
import 'package:kkulkkulk/common/network/dio_client.dart';

class ProfileViewModel extends StateNotifier<AsyncValue<UserProfile>> {
  final ProfileRepository _repository;

  ProfileViewModel(this._repository) : super(const AsyncValue.loading()) {
    _loadUserProfile(); // ✅ 생성자에서 자동 실행!
  }

  Future<void> _loadUserProfile() async {
    // ✅ 내부에서 실행되도록 변경
    try {
      final profile = await _repository.fetchUserProfile();
      print("✅ 받아온 프로필 데이터: ${profile.toJson()}"); // 🔥 JSON으로 변환하여 출력
      state = AsyncValue.data(profile);
    } catch (e) {
      print("❌ 프로필 데이터 로딩 실패: $e");
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// ✅ 프로필 정보 업데이트
  Future<void> updateUserProfile(UserProfile updatedProfile) async {
    try {
      await _repository.updateUserProfile(updatedProfile);
      await _loadUserProfile();
      state = AsyncValue.data(updatedProfile);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(DioClient()),
);

final profileProvider =
    StateNotifierProvider<ProfileViewModel, AsyncValue<UserProfile>>(
  (ref) => ProfileViewModel(ref.watch(profileRepositoryProvider)),
);
