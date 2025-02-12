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

  /// ✅ 프로필 정보 업데이트 후 최신 프로필 다시 불러오기
  Future<void> updateUserProfile(UserProfile updatedProfile) async {
    try {
      await _repository.updateUserProfile(updatedProfile);

      // ✅ 프로필 수정 후, 다시 조회하여 최신 데이터 반영
      await _loadUserProfile();
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
