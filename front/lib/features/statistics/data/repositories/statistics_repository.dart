import 'package:dio/dio.dart';
import 'package:kkulkkulk/common/network/dio_client.dart';

class StatisticsRepository {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> fetchWeeklyStatistics(
      int userId, String date) async {
    try {
      final response = await _dio.get(
        '/api/user-climbground/weekly',
        queryParameters: {
          'userId': userId,
          'date': date,
        },
      );
      return response.data; // JSON 데이터를 그대로 반환
    } catch (e) {
      throw Exception('Failed to fetch statistics: $e');
    }
  }
}
