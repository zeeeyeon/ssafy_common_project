import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../../../common/network/dio_client.dart';
import '../models/calendar_model.dart';
import 'package:intl/intl.dart';
import '../models/calendar_detail_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalendarRepository {
  final Dio _dio;
  final Logger logger = Logger(); // ✅ Logger 추가

  CalendarRepository(this._dio);

  Future<List<CalendarModel>> getCalendar(DateTime date) async {
    try {
      final formattedDate = DateFormat('yyyy-MM').format(date);
      logger.i("📡 API 요청: api/record/monthly?date=$formattedDate");
      final response = await _dio.get(
        '/api/record/monthly',
        queryParameters: {'date': formattedDate},
      );

      logger.d("✅ API 응답 데이터: ${response.data}");

      final content = response.data['content'];
      if (content == null) {
        throw Exception("❌ 응답에서 'content' 필드를 찾을 수 없음.");
      }

      return [CalendarModel.fromJson(content)];
    } on DioException catch (e) {
      throw Exception("API 요청 실패: ${e.message}");
    } catch (e) {
      throw Exception("알 수 없는 오류 발생: $e");
    }
  }

  Future<CalendarDetailModel> fetchDailyData(DateTime date) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      logger.i("📡 API 요청: /record/daily?date=$formattedDate");

      final response = await _dio.get(
        '/api/record/daily',
        queryParameters: {'date': formattedDate},
      );

      logger.d("✅ API 응답 데이터: ${response.data}");

      // "content" 필드가 존재하는지 확인
      final content = response.data['content'];
      if (content == null) {
        throw Exception("❌ 응답에서 'content' 필드를 찾을 수 없음.");
      }

      return CalendarDetailModel.fromJson(content);
    } on DioException catch (e) {
      throw Exception('일별 데이터 요청 실패: ${e.message}');
    } catch (e, stackTrace) {
      throw Exception("알 수 없는 오류 발생: $e");
    }
  }
}

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  return CalendarRepository(ref.read(dioClientProvider).dio);
});
