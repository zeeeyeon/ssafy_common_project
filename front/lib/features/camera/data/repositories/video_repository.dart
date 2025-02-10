import 'package:dio/dio.dart';
import 'package:kkulkkulk/common/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class VideoRepository {
  static const String _path = '/climbing/record/save';
  final Dio _dio;

  VideoRepository(this._dio);

  Future<Map<String, dynamic>> uploadVideo(FormData formData) async {
    try {
      logger.d("비디오 업로드 시작", {
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
        return response.data['content'];
      } else {
        throw Exception(response.data['status']['message'] ?? '비디오 업로드 실패');
      }
    } catch (e) {
      logger.e("비디오 업로드 API 오류", e);
      rethrow;
    }
  }
}

final videoRepositoryProvider = Provider<VideoRepository>((ref) {
  return VideoRepository(ref.read(dioClientProvider).dio);
});
