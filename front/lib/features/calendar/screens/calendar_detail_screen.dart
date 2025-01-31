import 'package:flutter/material.dart';
import 'package:kkulkkulk/common/widgets/layout/custom_app_bar.dart';

class CalendarDetailScreen extends StatelessWidget {
  final String date;

  const CalendarDetailScreen({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: date,
        showBackButton: true,
      ),
      body: Center(
        child: Text('$date의 운동 기록'),
      ),
    );
  }
}
