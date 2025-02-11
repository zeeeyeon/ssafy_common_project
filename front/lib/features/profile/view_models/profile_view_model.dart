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
      state = AsyncValue.data(profile);
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
