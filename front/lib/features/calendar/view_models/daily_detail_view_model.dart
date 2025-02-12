import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/features/calendar/data/models/calendar_detail_model.dart';
import 'package:kkulkkulk/features/calendar/data/repositories/calendar_repository.dart';

class DailyDetailState {
  final CalendarDetailModel? data;
  final bool isLoading;
  final String? error;

  DailyDetailState({
    this.data,
    this.isLoading = false,
    this.error,
  });
}

class DailyDetailViewModel extends StateNotifier<DailyDetailState> {
  final CalendarRepository _repository;

  DailyDetailViewModel(this._repository) : super(DailyDetailState());

  Future<void> loadDailyData(int userId, DateTime date) async {
    state = DailyDetailState(isLoading: true);

    try {
      final data = await _repository.fetchDailyData(userId, date);
      state = DailyDetailState(data: data);
    } catch (e) {
      state = DailyDetailState(error: e.toString());
    }
  }
}

// Provider 등록
final dailyDetailProvider =
    StateNotifierProvider.autoDispose<DailyDetailViewModel, DailyDetailState>(
  (ref) => DailyDetailViewModel(ref.read(calendarRepositoryProvider)),
);
