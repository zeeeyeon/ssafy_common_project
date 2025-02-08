import 'package:kkulkkulk/common/network/dio_client.dart';
import 'package:kkulkkulk/features/statistics/data/models/statistics_model.dart';

class StatisticsRepository {
  final DioClient _dioClient;

  StatisticsRepository(this._dioClient);

  Future<StatisticsModel> fetchWeeklyStatistics() async {
    try {
      final response = await _dioClient.dio.get(
        '/api/user-climbground/weekly',
        queryParameters: {
          'userId': 1,
          'date': '2025-02-01',
        },
      );

      return StatisticsModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load weekly statistics: $e');
    }
  }
}
