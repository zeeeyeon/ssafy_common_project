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
      logger.d("비디오 업로드 시작: ${videoFile.path}");

      // 원본 파일 크기 확인
      final fileSize = await videoFile.length();
      logger.d("원본 파일 크기: ${fileSize ~/ 1024}KB");

      File fileToUpload;
      if (fileSize > 10 * 1024 * 1024) {
        // 10MB 이상인 경우에만 압축
        logger.d("비디오 압축 시작");
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
          fileToUpload = mediaInfo!.file!;
          logger.d("압축 후 파일 크기: ${await fileToUpload.length() ~/ 1024}KB");
        } catch (e) {
          logger.e("비디오 압축 중 오류 발생: $e");
          // 압축 실패 시 원본 파일 사용
          fileToUpload = videoFile;
        }
      } else {
        fileToUpload = videoFile;
      }

      final response = await _repository.uploadVideo(
        videoFile: fileToUpload,
        userDateId: userDateId,
        holdId: holdId,
        isSuccess: isSuccess,
      );

      // 압축된 임시 파일 삭제
      if (fileToUpload.path != videoFile.path) {
        try {
          await fileToUpload.delete();
        } catch (e) {
          logger.e("임시 파일 삭제 중 오류: $e");
        }
      }

      state = AsyncValue.data(response);
      logger.d("비디오 업로드 완료");
    } catch (e, stack) {
      logger.e("비디오 업로드 실패: $e");
      state = AsyncValue.error(e, stack);
      rethrow;
    } finally {
      await VideoCompress.cancelCompression();
    }
  }
}
