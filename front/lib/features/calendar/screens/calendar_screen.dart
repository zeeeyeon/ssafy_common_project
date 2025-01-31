import 'package:flutter/material.dart';
import 'package:kkulkkulk/common/widgets/layout/custom_app_bar.dart';
import 'package:go_router/go_router.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  bool _showFAB = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: '캘린더',
        showBackButton: false,
      ),
      body: const Center(
        child: Text('Calendar Screen'),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 상세기록 버튼
          if (_showFAB) ...[
            FloatingActionButton(
              heroTag: 'detail',
              onPressed: () {
                context.push('/calendar/detail/2024-03-14');
              },
              child: const Icon(Icons.note_add),
            ),
            const SizedBox(height: 10),
            // 카메라 버튼
            FloatingActionButton(
              heroTag: 'camera',
              onPressed: () {
                context.go('/camera');
              },
              child: const Icon(Icons.camera_alt),
            ),
            const SizedBox(height: 10),
          ],
          // 메인 FAB
          FloatingActionButton(
            heroTag: 'main',
            onPressed: () {
              setState(() {
                _showFAB = !_showFAB;
              });
            },
            child: Icon(_showFAB ? Icons.close : Icons.add),
          ),
        ],
      ),
    );
  }
}
