import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/features/profile/data/repositories/profile_image_repository.dart';
import 'package:kkulkkulk/common/network/dio_client.dart';

class ProfileImageViewModel extends StateNotifier<AsyncValue<void>> {
  final ProfileImageRepository _repository;

  ProfileImageViewModel(this._repository) : super(const AsyncValue.data(null));

  /// 🔹 **프로필 이미지 업로드**
  Future<void> uploadProfileImage(File imageFile) async {
    state = const AsyncValue.loading();
    try {
      await _repository.uploadProfileImage(imageFile);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

/// 🔥 Provider 등록
final profileImageRepositoryProvider = Provider<ProfileImageRepository>(
  (ref) => ProfileImageRepository(DioClient()),
);

final profileImageProvider =
    StateNotifierProvider<ProfileImageViewModel, AsyncValue<void>>(
  (ref) => ProfileImageViewModel(ref.watch(profileImageRepositoryProvider)),
);
