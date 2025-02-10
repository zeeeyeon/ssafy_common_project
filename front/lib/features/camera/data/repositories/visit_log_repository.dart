import 'package:dio/dio.dart';
import 'package:kkulkkulk/common/network/dio_client.dart';
import 'package:logger/logger.dart';
import 'package:kkulkkulk/features/camera/data/models/visit_log_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final logger = Logger();

class VisitLogRepository {
  static const String _path = '/record/start/near-location';
  final Dio _dio;

  VisitLogRepository(this._dio);

  Future<VisitLogResponse> createVisitLog({
    required int userId,
    required double latitude,
    required double longitude,
    required String date,
  }) async {
    try {
      final response = await _dio.post(
        _path,
        data: {
          'userId': userId,
          'latitude': latitude,
          'longitude': longitude,
          'date': date,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return VisitLogResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to create visit log');
      }
    } catch (e) {
      logger.e("방문 일지 API 오류", e);
      rethrow;
    }
  }
}

final visitLogRepositoryProvider = Provider<VisitLogRepository>((ref) {
  return VisitLogRepository(ref.read(dioClientProvider).dio);
});
