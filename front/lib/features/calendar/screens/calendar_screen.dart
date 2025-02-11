import 'package:flutter/material.dart';
import 'package:kkulkkulk/common/widgets/layout/custom_app_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/features/calendar/data/models/calendar_model.dart';
import 'package:kkulkkulk/features/calendar/view_models/calendar_view_model.dart';
import 'package:kkulkkulk/common/providers/user_provider.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';

final logger = Logger();

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  CalendarScreenState createState() => CalendarScreenState();
}

class CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime currentMonth;
  late PageController pageController;
  int previousPage = 0;

  @override
  void initState() {
    super.initState();
    currentMonth = DateTime.now();
    pageController = PageController(initialPage: 500);
    previousPage = 500; // 초기값을 init 으로 맞춰줌
    _initializeDate(); // 📌 화면 진입 시 API 요청
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  // 📌 초기 데이터 로드 및 달 변경 시 호출
  void _initializeDate() {
    final userId = ref.read(userIdProvider);
    ref.read(calendarProvider.notifier).fetchCalendarData(userId, currentMonth);
  }

  // 현재 화면이 캘린더 화면인지 확인하고 새로고침하는 함수
  void _refreshIfCalendarScreen() {
    final location = GoRouterState.of(context).uri.toString();
    if (location == '/calendar') {
      logger.d("캘린더 화면 새로고침");
      _initializeDate();
    }
  }

  // 📌 월 변경 시 API 요청 (setState 이후 호출)
  void handleMonthChange(int pageIndex) {
    int monthDiff = pageIndex - previousPage; // 🔹 이전 페이지와 현재 페이지 비교
    previousPage = pageIndex; // 🔹 이전 페이지 값 업데이트

    final userId = ref.read(userIdProvider);
    setState(() {
      int newYear = currentMonth.year;
      int newMonth = currentMonth.month + monthDiff;

      if (newMonth < 1) {
        newYear -= 1;
        newMonth = 12; // 🔹 이전 해의 12월로 변경
      } else if (newMonth > 12) {
        newYear += 1;
        newMonth = 1; // 🔹 다음 해의 1월로 변경
      }

      currentMonth = DateTime(newYear, newMonth);
    });

    ref.read(calendarProvider.notifier).fetchCalendarData(userId, currentMonth);
  }

  @override
  Widget build(BuildContext context) {
    final calendarData = ref.watch(calendarProvider);
    // 빈 칸 계산 (일요일부터 시작하도록 하였음)
    final int blankCount = getFirstWeekdayOfMonth() % 7;
    final int totalItems = getDaysInMonth() + blankCount;

    return Scaffold(
      appBar: CustomAppBar(
        title: '${currentMonth.year}년 ${currentMonth.month}월',
        showBackButton: false,
        leading: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () {
            _refreshIfCalendarScreen(); // 캘린더 아이콘 클릭 시 새로고침
            selectDate(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            buildWeekdayHeader(),
            Expanded(
              child: PageView.builder(
                controller: pageController,
                onPageChanged: handleMonthChange,
                itemBuilder: (context, index) {
                  return calendarData == null
                      ? const Center(child: CircularProgressIndicator())
                      : GestureDetector(
                          onVerticalDragEnd: (details) {
                            if (details.primaryVelocity! > 0) {
                              handleMonthChange(previousPage - 1);
                            } else if (details.primaryVelocity! < 0) {
                              handleMonthChange(previousPage + 1);
                            }
                          },
                          child: GridView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              mainAxisSpacing: 4,
                              crossAxisSpacing: 4,
                              childAspectRatio: 0.6,
                            ),
                            itemCount: totalItems,
                            itemBuilder: (context, index) {
                              if (index < blankCount) {
                                return Container();
                              }
                              final dayNumber = index - blankCount + 1;
                              final currentDate = DateTime(
                                currentMonth.year,
                                currentMonth.month,
                                dayNumber,
                              );

                              final int dailyAttempts = _getDailyAttemptCount(
                                  currentDate, calendarData);
                              final bool hasRecord = dailyAttempts > 0;

                              return buildDayCell(currentDate, hasRecord,
                                  dailyAttempts: dailyAttempts);
                            },
                          ),
                        );
                },
              ),
            ),
          ],
        ),
      ),
      // FloatingActionButton을 누르면 하단에서 올라오는 custom dialog를 호출
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showCustomDialog(context),
      ),
    );
  }

  Widget buildWeekdayHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: ['일', '월', '화', '수', '목', '금', '토']
            .map((day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: day == '일' ? Colors.red : Colors.black87,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget buildDayCell(DateTime date, bool hasRecord, {int dailyAttempts = 0}) {
    final isToday = DateTime.now().year == date.year &&
        DateTime.now().month == date.month &&
        DateTime.now().day == date.day;

    return InkWell(
      onTap: hasRecord ? () => onDaySelected(date) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          color: hasRecord
              ? const Color.fromRGBO(33, 150, 243, 0.1)
              : null, // ✅ 배경색 변경
          border: isToday
              ? Border.all(color: Colors.blue, width: 2)
              : Border.all(color: Colors.grey[300]!, width: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                '${date.day}',
                style: TextStyle(
                  fontWeight: hasRecord ? FontWeight.bold : FontWeight.normal,
                  color: date.weekday == DateTime.sunday ? Colors.red : null,
                ),
              ),
            ),
            if (hasRecord)
              Expanded(
                  child: Container(
                margin:
                    const EdgeInsets.only(left: 6, right: 6, bottom: 2, top: 2),
                decoration: BoxDecoration(
                  color: hasRecord
                      ? Color.fromRGBO(
                          33, 150, 245, _getOpacityFromAttempts(dailyAttempts))
                      : null,
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(6)),
                ),
              ))
          ],
        ),
      ),
    );
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentMonth,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('ko', ''),
    );
    if (picked != null) {
      setState(() {
        currentMonth = picked;
      });
      _initializeDate();
    }
  }

  void onDaySelected(DateTime date) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    logger.i('Navigating to: /calendar/detail/$formattedDate');
    context.push('/calendar/detail/$formattedDate');
  }

  int getDaysInMonth() {
    return DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
  }

  int getFirstWeekdayOfMonth() {
    int weekday = DateTime(currentMonth.year, currentMonth.month, 1).weekday;
    return (weekday % 7);
  }

  double _getOpacityFromAttempts(int attempts) {
    if (attempts >= 20) return 1.0;
    if (attempts >= 10) return 0.6;
    if (attempts > 0) return 0.2;
    return 0.0;
  }

  int _getDailyAttemptCount(DateTime date, List<CalendarModel>? calendarData) {
    if (calendarData == null) return 0;

    final record = calendarData
        .firstWhere(
          (data) => data.year == date.year && data.month == date.month,
          orElse: () =>
              CalendarModel(year: date.year, month: date.month, records: []),
        )
        .records
        .firstWhere(
          (r) => r.day == date.day,
          orElse: () =>
              CalendarRecord(day: date.day, hasRecord: false, totalCount: 0),
        );

    return record.totalCount;
  }

  // 하단에서 슬라이드 업 하는 커스텀 다이얼로그 (Bottom Sheet) 호출 함수
  void _showCustomDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          width: 300,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.withOpacity(0.4), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCustomButton(
                context,
                '카메라',
                Icons.camera_alt,
                Colors.blue,
                () {
                  context.push('/camera');
                },
              ),
              const SizedBox(height: 10),
              _buildCustomButton(
                context,
                '앨범',
                Icons.photo_album,
                Colors.blue,
                () {
                  context.push('/album');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // custom bottom sheet 내 버튼 디자인 (ElevatedButton 스타일)
  Widget _buildCustomButton(BuildContext context, String text, IconData icon,
      Color color, Function() onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.9),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 20),
        ),
        onPressed: () {
          Navigator.pop(context);
          onPressed();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
