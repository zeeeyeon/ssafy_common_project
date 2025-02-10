import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:video_compress/video_compress.dart';
import 'package:logger/logger.dart';
import 'package:kkulkkulk/features/camera/data/repositories/video_repository.dart';

final logger = Logger();

final videoViewModelProvider =
    StateNotifierProvider<VideoViewModel, AsyncValue<void>>(
  (ref) => VideoViewModel(ref.read(videoRepositoryProvider)),
);

class VideoViewModel extends StateNotifier<AsyncValue<void>> {
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
      // 파일 확장자 체크
      final extension = videoFile.path.split('.').last.toLowerCase();
      if (extension != 'mp4') {
        throw Exception('MP4 형식의 파일만 업로드 가능합니다.');
      }

      // 원본 파일 크기 체크
      final originalSize = await videoFile.length();
      if (originalSize > 10 * 1024 * 1024 * 1024) {
        // 10GB
        throw Exception('파일 크기가 10GB를 초과합니다.');
      }

      // 비디오 압축
      final MediaInfo? mediaInfo = await VideoCompress.compressVideo(
        videoFile.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
        includeAudio: true,
      );

      if (mediaInfo?.file == null) {
        throw Exception('비디오 압축 실패');
      }

      // FormData 생성
      final formData = FormData.fromMap({
        'userId': 1, // TODO: 실제 사용자 ID로 변경 필요
        'userDateId': userDateId,
        'isSuccess': isSuccess,
        'holdId': holdId,
        'file': await MultipartFile.fromFile(
          mediaInfo!.file!.path,
          filename: '${color}_${DateTime.now().millisecondsSinceEpoch}.mp4',
        ),
      });

      // 업로드 요청
      await _repository.uploadVideo(formData);

      // 압축된 임시 파일 삭제
      await mediaInfo.file?.delete();

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      logger.e('비디오 업로드 실패', e, stack);
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}
