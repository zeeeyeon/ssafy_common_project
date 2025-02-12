import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/features/profile/data/models/profile_model.dart';
import 'package:kkulkkulk/features/profile/view_models/profile_view_model.dart';
import 'package:table_calendar/table_calendar.dart';

class ProfileScreenEdit extends ConsumerStatefulWidget {
  const ProfileScreenEdit({super.key});

  @override
  _ProfileScreenEditState createState() => _ProfileScreenEditState();
}

class _ProfileScreenEditState extends ConsumerState<ProfileScreenEdit> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _armSpanController = TextEditingController();
  DateTime? _selectedStartDate;
  bool _isCalendarVisible = false;

  @override
  void initState() {
    super.initState();
    final userProfile = ref.read(profileProvider).value;
    if (userProfile != null) {
      _nicknameController.text = userProfile.nickname;
      _heightController.text = userProfile.height.toString();
      _armSpanController.text = userProfile.armSpan.toString();
      _selectedStartDate = userProfile.startDate;
    }
  }

  /// 🔥 프로필 저장 함수
  void _saveProfile() {
    final double? newHeight = double.tryParse(_heightController.text);
    final double? newArmSpan = double.tryParse(_armSpanController.text);
    final userProfile = ref.read(profileProvider).value; // ✅ 기존 프로필 가져오기

    if (newHeight != null && newArmSpan != null && userProfile != null) {
      final updatedProfile = UserProfile(
          nickname: _nicknameController.text,
          height: newHeight,
          armSpan: newArmSpan,
          profileImageUrl: userProfile.profileImageUrl, // ✅ 기존 값 유지
          userTier: userProfile.userTier, // ✅ 기존 티어 값 유지
          dday: userProfile.dday, // ✅ 기존 D-Day 유지
          startDate: _selectedStartDate);

      ref.read(profileProvider.notifier).updateUserProfile(updatedProfile);

      // 🔹 프로필을 다시 불러와서 최신 데이터 반영
      // ref.read(profileProvider.notifier).loadUserProfile();

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("키와 팔길이를 올바르게 입력하세요!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 수정'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 닉네임 입력
            const Text('닉네임',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '닉네임을 입력하세요.',
              ),
            ),
            const SizedBox(height: 24),

            // 🔹 클라이밍 시작일 선택
            const Text('클라이밍 시작일',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                      _selectedStartDate != null
                          ? "${_selectedStartDate!.year}-${_selectedStartDate!.month}-${_selectedStartDate!.day}"
                          : "클라이밍 시작일을 선택해주세요.",
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // 🔹 달력 표시
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: TableCalendar(
                firstDay: DateTime(2000),
                lastDay: DateTime(2100),
                focusedDay: _selectedStartDate ?? DateTime.now(),
                selectedDayPredicate: (day) =>
                    isSameDay(_selectedStartDate, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedStartDate = selectedDay;
                    _isCalendarVisible = false;
                  });
                },
              ),
              crossFadeState: _isCalendarVisible
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
            const SizedBox(height: 24),

            // 🔹 키 & 팔길이 입력
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('키 (cm)',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _heightController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(), hintText: '키 입력'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('팔길이 (cm)',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _armSpanController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(), hintText: '팔길이 입력'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _saveProfile,
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.all(16)),
          child: const Text('저장',
              style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ),
    );
  }
}
