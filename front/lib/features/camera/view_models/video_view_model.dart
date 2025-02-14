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
      logger.d('비디오 업로드 시작: $color, $isSuccess, $userDateId, $holdId');

      // 파일 처리 로직
      File processedVideo = await _processVideo(videoFile);

      // 실제 업로드 수행
      final response = await _repository.uploadVideo(
        videoFile: processedVideo,
        isSuccess: isSuccess,
        userDateId: userDateId,
        holdId: holdId,
      );

      state = AsyncValue.data(response);
      logger.d('비디오 업로드 완료');
    } catch (e, stack) {
      logger.e('비디오 업로드 실패: $e');
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<File> _processVideo(File videoFile) async {
    final fileSize = await videoFile.length();
    if (fileSize <= 10 * 1024 * 1024) return videoFile;

    try {
      final MediaInfo? mediaInfo = await VideoCompress.compressVideo(
        videoFile.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
        includeAudio: true,
      );

      if (mediaInfo?.file == null) {
        throw Exception('비디오 압축 실패');
      }

      return mediaInfo!.file!;
    } catch (e) {
      logger.e('비디오 압축 중 오류 발생: $e');
      return videoFile;
    }
  }
}
