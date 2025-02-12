import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:kkulkkulk/features/camera/data/repositories/video_repository.dart';
import 'package:kkulkkulk/features/camera/data/models/video_model.dart';
import 'package:video_compress/video_compress.dart';

final logger = Logger();

final videoViewModelProvider =
    StateNotifierProvider<VideoViewModel, AsyncValue<VideoResponse?>>(
  (ref) => VideoViewModel(ref.read(videoRepositoryProvider)),
);

class VideoViewModel extends StateNotifier<AsyncValue<VideoResponse?>> {
  final VideoRepository _repository;

  VideoViewModel(this._repository) : super(const AsyncValue.data(null));

  Future<void> uploadVideo({
    required File videoFile,
    required String color,
    required bool isSuccess,
    required int userDateId,
    required int holdId,
  }) async {
    state = const AsyncValue.loading();

    try {
      logger.d("비디오 압축 시작");
      final MediaInfo? mediaInfo = await VideoCompress.compressVideo(
        videoFile.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
        includeAudio: true,
      );

      if (mediaInfo?.file == null) {
        throw Exception('비디오 압축 실패');
      }

      final response = await _repository.uploadVideo(
        videoFile: mediaInfo!.file!,
        userDateId: userDateId,
        holdId: holdId,
        isSuccess: isSuccess,
      );

      await mediaInfo.file?.delete();

      state = AsyncValue.data(response);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}
