import 'package:dio/dio.dart';
import 'package:kkulkkulk/common/network/dio_client.dart';
import 'package:logger/logger.dart';
import 'package:kkulkkulk/features/camera/data/models/visit_log_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final logger = Logger();

class VisitLogRepository {
  static const String _path = '/api/record/start/near-location';
  final Dio _dio;

  VisitLogRepository() : _dio = DioClient().dio;

  Future<VisitLogResponse> createVisitLog({
    required int userId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.post(
        _path,
        data: {
          'userId': userId,
          'latitude': latitude,
          'longitude': longitude,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 208) {
        return VisitLogResponse.fromJson(response.data);
      } else {
        final message = response.data['status']['message'] ?? '방문 일지 생성 실패';
        throw Exception(message);
      }
    } catch (e) {
      rethrow;
    }
  }
}

final visitLogRepositoryProvider = Provider<VisitLogRepository>((ref) {
  return VisitLogRepository();
});
