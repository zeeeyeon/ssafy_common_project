import 'package:flutter/material.dart';
import '../data/repositories/statistics_repository.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final StatisticsRepository _repository = StatisticsRepository();
  Map<String, dynamic>? _data; // API 응답 데이터 저장
  bool _isLoading = true; // 로딩 상태
  String? _error; // 에러 메시지 저장

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
  }

  Future<void> _fetchStatistics() async {
    try {
      final data = await _repository.fetchWeeklyStatistics(1, '2025-02-01');
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('주별 통계'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('에러 발생: $_error'))
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('상태 코드: ${_data?['status']['code']}'),
                      Text('메시지: ${_data?['status']['message']}'),
                      Text('성공 횟수: ${_data?['content']['success']}'),
                      Text('성공률: ${_data?['content']['success_rate']}%'),
                      Text('시도 횟수: ${_data?['content']['tryCount']}'),
                    ],
                  ),
                ),
    );
  }
}
