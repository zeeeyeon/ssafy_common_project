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
  }) async {
    try {
      final videoBytes = await videoFile.readAsBytes();
      final multipartFile = MultipartFile.fromBytes(
        videoBytes,
        filename: 'video.mp4',
        contentType: MediaType('video', 'mp4'),
      );

      final formData = FormData.fromMap({
        'userId': 1,
        'holdId': holdId,
        'userDateId': userDateId,
        'isSuccess': isSuccess,
        'file': multipartFile,
      });

      logger.d("비디오 업로드 요청", {
        "url": "${_dio.options.baseUrl}$_path",
        "formData": {
          "userId": formData.fields
              .where((field) => field.key == 'userId')
              .firstOrNull
              ?.value,
          "holdId": formData.fields
              .where((field) => field.key == 'holdId')
              .firstOrNull
              ?.value,
          "userDateId": formData.fields
              .where((field) => field.key == 'userDateId')
              .firstOrNull
              ?.value,
          "isSuccess": formData.fields
              .where((field) => field.key == 'isSuccess')
              .firstOrNull
              ?.value,
        }
      });

      final response = await _dio.post(
        _path,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 201) {
        logger.d("비디오 업로드 성공", {
          "statusCode": response.statusCode,
          "data": response.data,
        });
        return VideoResponse.fromJson(response.data['content']);
      } else {
        final message = response.data['status']['message'] ?? '비디오 업로드 실패';
        throw Exception(message);
      }
    } catch (e) {
      logger.e("비디오 업로드 API 오류", e);
      rethrow;
    }
  }
}

final videoRepositoryProvider = Provider<VideoRepository>((ref) {
  return VideoRepository();
});
