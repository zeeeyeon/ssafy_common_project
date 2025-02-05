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

  Future<List<CalendarModel>> getCalendar(int userId, DateTime date) async {
    try {
      final formattedDate = DateFormat('yyyy-MM').format(date);
      logger.i(
          "📡 API 요청: /record/monthly/$userId?date=$formattedDate"); // ✅ 요청 로그 추가

      final response = await _dio.get(
        '/record/monthly/$userId',
        queryParameters: {'date': formattedDate},
      );

      logger.d("✅ API 응답 데이터: ${response.data}"); // ✅ 응답 로그 추가

      // ✅ "content" 부분만 추출
      final content = response.data['content'];
      if (content == null) {
        throw Exception("❌ 응답에서 'content' 필드를 찾을 수 없음.");
      }

      return [CalendarModel.fromJson(content)];
    } on DioException catch (e) {
      logger.e("⛔ DioException 발생: ${e.message}", e,
          e.stackTrace); // 이름 없는 positional parameter로 변경
      throw Exception("API 요청 실패: ${e.message}");
    } catch (e, stackTrace) {
      logger.e("⛔ 알 수 없는 오류 발생", e, stackTrace); // 이름 없는 parameter로 변경
      throw Exception("알 수 없는 오류 발생: $e");
    }
  }

  Future<CalendarDetailModel> fetchDailyData(int userId, DateTime date) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      logger.i("📡 API 요청: /record/daily/$userId?date=$formattedDate");

      final response = await _dio.get(
        '/record/daily/$userId',
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
      logger.e("⛔ DioException 발생: ${e.message}", e, e.stackTrace);
      throw Exception('일별 데이터 요청 실패: ${e.message}');
    } catch (e, stackTrace) {
      logger.e("⛔ 알 수 없는 오류 발생", e, stackTrace);
      throw Exception("알 수 없는 오류 발생: $e");
    }
  }
}

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  return CalendarRepository(ref.read(dioClientProvider).dio);
});
