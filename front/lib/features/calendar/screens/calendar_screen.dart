import 'package:flutter/material.dart';
import 'package:kkulkkulk/common/widgets/layout/custom_app_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  CalendarScreenState createState() => CalendarScreenState();
}

class CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime currentMonth;
  bool showFAB = false;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    currentMonth = DateTime.now();
    pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '${currentMonth.year}년 ${currentMonth.month}월',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => selectDate(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 공지사항 영역
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.yellow[100],
              child: const Text(
                '공지사항: 다음 주에 중요한 업데이트가 있습니다!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            buildWeekdayHeader(),
            Expanded(
              child: GestureDetector(
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity! > 0) {
                    setState(() {
                      currentMonth = DateTime(
                        currentMonth.year,
                        currentMonth.month - 1,
                      );
                    });
                  } else if (details.primaryVelocity! < 0) {
                    setState(() {
                      currentMonth = DateTime(
                        currentMonth.year,
                        currentMonth.month + 1,
                      );
                    });
                  }
                },
                child: GridView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: getDaysInMonth() + getFirstWeekdayOfMonth() - 1,
                  itemBuilder: (context, index) {
                    if (index < getFirstWeekdayOfMonth() - 1) {
                      return Container();
                    }

                    final dayNumber = index - getFirstWeekdayOfMonth() + 2;
                    final currentDate = DateTime(
                      currentMonth.year,
                      currentMonth.month,
                      dayNumber,
                    );

                    final hasRecord = dayNumber % 3 == 0;
                    return buildDayCell(currentDate, hasRecord);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (showFAB) ...[
            FloatingActionButton(
              heroTag: 'detail',
              onPressed: () {
                final now = DateTime.now();
                final month = now.month.toString().padLeft(2, '0');
                final day = now.day.toString().padLeft(2, '0');
                context.push('/calendar/detail/${now.year}-$month-$day');
              },
              child: const Icon(Icons.note_add),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              heroTag: 'camera',
              onPressed: () {
                context.go('/camera');
              },
              child: const Icon(Icons.camera_alt),
            ),
            const SizedBox(height: 10),
          ],
          FloatingActionButton(
            heroTag: 'main',
            onPressed: () {
              setState(() {
                showFAB = !showFAB;
              });
            },
            child: Icon(showFAB ? Icons.close : Icons.add),
          ),
        ],
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

  Widget buildDayCell(DateTime date, bool hasRecord) {
    final isToday = DateTime.now().year == date.year &&
        DateTime.now().month == date.month &&
        DateTime.now().day == date.day;

    return InkWell(
      onTap: hasRecord ? () => onDaySelected(date) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          color: hasRecord ? Colors.blue.withOpacity(0.1) : null,
          border: isToday
              ? Border.all(color: Colors.blue, width: 2)
              : Border.all(color: Colors.grey[300]!, width: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                '${date.day}',
                style: TextStyle(
                  fontWeight: hasRecord ? FontWeight.bold : FontWeight.normal,
                  color: date.weekday == DateTime.sunday ? Colors.red : null,
                ),
              ),
            ),
            if (hasRecord)
              Container(
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ... rest of your methods remain the same
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
    }
  }

  void onDaySelected(DateTime date) {
    final formattedDate =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    logger.i('Navigating to: /calendar/detail/$formattedDate');
    context.push('/calendar/detail/$formattedDate');
  }

  int getDaysInMonth() {
    return DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
  }

  int getFirstWeekdayOfMonth() {
    return DateTime(currentMonth.year, currentMonth.month, 1).weekday;
  }
}
