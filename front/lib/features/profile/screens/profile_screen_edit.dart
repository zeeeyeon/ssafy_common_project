import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:kkulkkulk/features/profile/view_models/profile_view_model.dart';

class ProfileScreenEdit extends ConsumerStatefulWidget {
  const ProfileScreenEdit({super.key});

  @override
  _ProfileScreenEditState createState() => _ProfileScreenEditState();
}

class _ProfileScreenEditState extends ConsumerState<ProfileScreenEdit> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isCalendarVisible = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _armSpanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final userProfile = ref.read(profileProvider);

    _nameController.text = userProfile.name; // 🛠️ 이름 필드 초기화
    _heightController.text = userProfile.height;
    _armSpanController.text = userProfile.armSpan;
  }

  void _saveProfile() {
    ref
        .read(profileProvider.notifier)
        .updateName(_nameController.text); // 🛠️ 이름 업데이트 추가
    ref.read(profileProvider.notifier).updateBodyInfo(
          _heightController.text,
          _armSpanController.text,
        );

    if (_selectedDay != null) {
      ref.read(profileProvider.notifier).updateStartDate(_selectedDay!);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 정보 수정'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '닉네임',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8), // 텍스트와 박스 사이 간격
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextField(
                  controller: _nameController, // 🛠️ 수정 가능하도록 컨트롤러 사용
                  decoration: const InputDecoration(
                    hintText: '닉네임을 입력하세요.',
                    border: InputBorder.none, // 내부 박스의 기본 테두리 제거
                  ),
                  onTap: () {
                    _nameController.clear();
                  },
                ),
              ),
              const SizedBox(height: 24),

              // 클라이밍 시작일 선택
              const Text(
                '클라이밍 시작일',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isCalendarVisible = !_isCalendarVisible;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDay != null
                            ? "${_selectedDay?.year}-${_selectedDay?.month}-${_selectedDay?.day}"
                            : "클라이밍 시작일을 선택해주세요.",
                        style: const TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 187, 184, 184)),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 달력 표시/숨기기
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(), // 숨겨진 상태
                secondChild: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TableCalendar(
                    // locale: 'ko_KR',
                    firstDay: DateTime(2000),
                    lastDay: DateTime(2100),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                        _isCalendarVisible = false;
                      });
                    },
                    calendarStyle: const CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                  ),
                ),
                crossFadeState: _isCalendarVisible
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
              const SizedBox(height: 24),

              // 키와 팔길이 입력 필드
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '키',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8), // 텍스트와 박스 사이 간격
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: TextField(
                            controller: _heightController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: const InputDecoration(
                              hintText: '-CM',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              border: InputBorder.none, // 내부 박스의 기본 테두리 제거
                            ),
                            onTap: () {
                              // 입력 필드를 클릭하면 기존 값 제거
                              if (_heightController.text.endsWith('CM')) {
                                _heightController.clear();
                              }
                            },
                            onChanged: (value) {
                              // 숫자만 입력 가능하도록 필터링하고, CM을 자동 추가
                              String newValue =
                                  value.replaceAll(RegExp(r'[^0-9]'), '');
                              if (newValue.isNotEmpty) {
                                _heightController.value = TextEditingValue(
                                  text: '$newValue CM',
                                  selection: TextSelection.collapsed(
                                      offset: newValue.length),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '팔길이',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8), // 텍스트와 박스 사이 간격
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: TextField(
                            controller: _armSpanController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: '-CM',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              border: InputBorder.none, // 내부 박스의 기본 테두리 제거
                            ),
                            onTap: () {
                              // 입력 필드를 클릭하면 기존 값 제거
                              if (_armSpanController.text.endsWith('CM')) {
                                _armSpanController.clear();
                              }
                            },
                            onChanged: (value) {
                              // 숫자만 입력 가능하도록 필터링하고, CM을 자동 추가
                              String newValue =
                                  value.replaceAll(RegExp(r'[^0-9]'), '');
                              if (newValue.isNotEmpty) {
                                _armSpanController.value = TextEditingValue(
                                  text: '$newValue CM',
                                  selection: TextSelection.collapsed(
                                      offset: newValue.length),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 저장 버튼
              // 저장 버튼
              Center(
                child: SizedBox(
                  width: double.infinity, // 🔹 반응형으로 너비 조절
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor: const Color.fromARGB(255, 80, 118, 232),
                    ),
                    child: const Text(
                      '저장',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color.fromARGB(220, 255, 255, 255),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
