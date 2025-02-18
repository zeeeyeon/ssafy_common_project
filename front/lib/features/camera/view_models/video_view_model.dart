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
  bool _isUploading = false;

  VideoViewModel(this._repository) : super(const AsyncValue.data(null));

  Future<bool> uploadVideo({
    required File videoFile,
    required String color,
    required bool isSuccess,
    required int userDateId,
    required int holdId,
  }) async {
    if (_isUploading) {
      logger.w('이미 업로드가 진행 중입니다.');
      return false;
    }

    _isUploading = true;
    state = const AsyncValue.loading();

    try {
      logger.d('비디오 업로드 시작: $color, $isSuccess, $userDateId, $holdId');

      File processedVideo = await _processVideo(videoFile);
      logger.d('비디오 전처리 완료: ${processedVideo.path}');

      final response = await _repository.uploadVideo(
        videoFile: processedVideo,
        isSuccess: isSuccess,
        userDateId: userDateId,
        holdId: holdId,
        onSendProgress: (int sentBytes, int totalBytes) {
          final progress = sentBytes / totalBytes;
          logger.d('업로드 진행률: ${(progress * 100).toStringAsFixed(2)}%');
        },
      );

      state = AsyncValue.data(response);
      logger.d('비디오 업로드 완료: ${response.url}');
      return true;
    } catch (e, stack) {
      logger.e('비디오 업로드 실패: $e\n$stack');
      state = AsyncValue.error(e, stack);
      return false;
    } finally {
      _isUploading = false;
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

  void resetState() {
    state = const AsyncValue.data(null);
    _isUploading = false;
  }
}
