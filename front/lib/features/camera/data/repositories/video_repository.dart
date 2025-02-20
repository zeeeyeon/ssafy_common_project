import 'dart:io';
import 'package:dio/dio.dart';
import 'package:kkulkkulk/common/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:http_parser/http_parser.dart';
import 'package:kkulkkulk/features/camera/data/models/video_model.dart';

final logger = Logger();

class VideoRepository {
  static const String _path = '/api/climbing/record/save';
  final Dio _dio;

  VideoRepository() : _dio = DioClient().dio;

  Future<VideoResponse> uploadVideo({
    required File videoFile,
    required int userDateId,
    required int holdId,
    required bool isSuccess,
    void Function(int sentBytes, int totalBytes)? onSendProgress,
  }) async {
    try {
      final videoBytes = await videoFile.readAsBytes();
      final multipartFile = MultipartFile.fromBytes(
        videoBytes,
        filename: 'video.mp4',
        contentType: MediaType('video', 'mp4'),
      );

      final formData = FormData.fromMap({
        'holdId': holdId,
        'userDateId': userDateId,
        'isSuccess': isSuccess,
        'file': multipartFile,
      });

      final response = await _dio.post(
        _path,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
        onSendProgress: onSendProgress,
      );

      if (response.statusCode == 201) {
        return VideoResponse.fromJson(response.data['content']);
      } else {
        final message = response.data['status']['message'] ?? '비디오 업로드 실패';
        throw Exception(message);
      }
    } catch (e) {
      rethrow;
    }
  }
}

final videoRepositoryProvider = Provider<VideoRepository>((ref) {
  return VideoRepository();
});
