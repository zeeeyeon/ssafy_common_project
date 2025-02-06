import 'package:flutter/material.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _selectedTabIndex = 0;

  final List<String> _tabs = ['주간', '월간', '연간'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_tabs.length, (index) {
            final isSelected = _selectedTabIndex == index;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  _tabs[index],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.blue : Colors.black,
                  ),
                ),
              ),
            );
          }),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[200],
        elevation: 0,
      ),
      body: _buildStatisticsView(),
    );
  }

  Widget _buildStatisticsView() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildWeeklyStatistics();
      case 1:
        return _buildMonthlyStatistics();
      case 2:
        return _buildYearlyStatistics();
      default:
        return const Center(child: Text('알 수 없는 탭')); // Fallback
    }
  }

  Widget _buildWeeklyStatistics() {
    return const Center(
      child: Text(
        '주간 통계 화면',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildMonthlyStatistics() {
    return const Center(
      child: Text(
        '월간 통계 화면',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildYearlyStatistics() {
    return const Center(
      child: Text(
        '연간 통계 화면',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
