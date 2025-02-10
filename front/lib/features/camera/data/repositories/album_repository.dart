import 'package:dio/dio.dart';
import 'package:kkulkkulk/common/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class AlbumRepository {
  static const String _path = '/album/daily';
  final Dio _dio;

  AlbumRepository(this._dio);

  Future<Response> getAlbums({
    required int userId,
    required String date,
    required bool isSuccess,
  }) async {
    logger.d("앨범 API 호출: userId=$userId, date=$date, isSuccess=$isSuccess");
    try {
      final response = await _dio.get(
        _path,
        queryParameters: {
          'userId': userId,
          'date': date,
          'isSuccess': isSuccess,
        },
      );
      logger.d("앨범 API 응답: ${response.data}");
      return response;
    } catch (e) {
      logger.e("앨범 API 오류", e);
      rethrow;
    }
  }
}

final albumRepositoryProvider = Provider<AlbumRepository>((ref) {
  return AlbumRepository(ref.read(dioClientProvider).dio);
});
