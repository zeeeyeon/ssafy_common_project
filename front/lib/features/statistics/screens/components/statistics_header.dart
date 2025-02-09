import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// ✅ 날짜 선택 UI (좌우 버튼)
class StatisticsHeader extends StatelessWidget {
  final String period;
  final DateTime selectedDate;
  final Function(String, int) onDateChange;

  const StatisticsHeader({
    super.key,
    required this.period,
    required this.selectedDate,
    required this.onDateChange,
  });

  String _getFormattedDateForUI() {
    if (period == 'weekly') {
      return DateFormat('yyyy.MM.dd').format(selectedDate);
    } else if (period == 'monthly') {
      return DateFormat('yyyy.MM').format(selectedDate);
    } else {
      return DateFormat('yyyy').format(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => onDateChange(period, -1)),
        Text(_getFormattedDateForUI(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => onDateChange(period, 1)),
      ],
    );
  }
}
