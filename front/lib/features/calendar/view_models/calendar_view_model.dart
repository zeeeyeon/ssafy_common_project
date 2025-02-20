import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../data/repositories/calendar_repository.dart';
import '../data/models/calendar_model.dart';

final calendarProvider =
    StateNotifierProvider<CalendarViewModel, List<CalendarModel>?>((
  ref,
) {
  return CalendarViewModel(ref);
});

class CalendarViewModel extends StateNotifier<List<CalendarModel>?> {
  final Ref _ref;
  late final CalendarRepository _repository;

  CalendarViewModel(this._ref) : super(null) {
    _repository = _ref.read(calendarRepositoryProvider); // ✅ Riverpod을 통한 주입
  }

  Future<void> fetchCalendarData(DateTime date) async {
    try {
      final data = await _repository.getCalendar(date);
      state = data;
    } catch (e) {
      state = null;
      _ref.read(loggerProvider).e('캘린더 데이터 불러오기 실패: $e');
    }
  }

  void clearData() {
    state = null;
  }
}

// ✅ Logger Provider 유지
final loggerProvider = Provider<Logger>((ref) => Logger());
