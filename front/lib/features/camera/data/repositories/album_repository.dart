import 'package:dio/dio.dart';
import 'package:kkulkkulk/common/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class AlbumRepository {
  static const String _path = '/api/album/daily';
  final Dio _dio;

  AlbumRepository() : _dio = DioClient().dio;

  Future<Response> getAlbums({
    required int userId,
    required String date,
    required bool isSuccess,
  }) async {
    logger.d("앨범 API 호출: userId=$userId, date=$date, isSuccess=$isSuccess");
    try {
      logger.d("요청 URL: $_path");
      logger.d("요청 파라미터: ${{
        'userId': userId,
        'date': date,
        'isSuccess': isSuccess,
      }}");

      final response = await _dio.get(
        _path,
        queryParameters: {
          'userId': userId,
          'date': date,
          'isSuccess': isSuccess,
        },
      );

      logger.d("응답 상태 코드: ${response.statusCode}");
      logger.d("응답 데이터: ${response.data}");
      return response;
    } catch (e, stack) {
      if (e is DioException && e.response != null) {
        logger.e("에러 응답 데이터: ${e.response?.data}");
      }
      rethrow;
    }
  }
}

final albumRepositoryProvider = Provider<AlbumRepository>((ref) {
  return AlbumRepository();
});
