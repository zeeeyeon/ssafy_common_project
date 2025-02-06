// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:kkulkkulk/features/profile/view_models/profile_view_model.dart';

// class ProfileScreenEdit extends ConsumerStatefulWidget {
//   const ProfileScreenEdit({super.key});

//   @override
//   _ProfileScreenEditState createState() => _ProfileScreenEditState();
// }

// class _ProfileScreenEditState extends ConsumerState<ProfileScreenEdit> {
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;
//   bool _isCalendarVisible = false;

//   final TextEditingController _nicknameController = TextEditingController();
//   final TextEditingController _heightController = TextEditingController();
//   final TextEditingController _armSpanController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     final userProfile = ref.read(profileProvider);

//     _nicknameController.text = userProfile.nickname;
//     _heightController.text = userProfile.height.toString();
//     _armSpanController.text = userProfile.armSpan.toString();
//   }

//   void _saveProfile() {
//     final double? newHeight = double.tryParse(_heightController.text);
//     final double? newArmSpan = double.tryParse(_armSpanController.text);

//     if (newHeight != null && newArmSpan != null) {
//       ref
//           .read(profileProvider.notifier)
//           .updateNickname(_nicknameController.text);
//       ref.read(profileProvider.notifier).updateBodyInfo(newHeight, newArmSpan);

//       if (_selectedDay != null) {
//         ref.read(profileProvider.notifier).updateStartDate(_selectedDay!);
//       }

//       Navigator.pop(context);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("키와 팔길이를 올바르게 입력하세요!")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final userProfile = ref.watch(profileProvider); // UI 변경 감지

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('내 정보 수정'),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 '닉네임',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 8),
//               TextField(
//                 controller: _nicknameController,
//                 decoration: const InputDecoration(
//                   border: OutlineInputBorder(),
//                   hintText: '닉네임을 입력하세요.',
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // 클라이밍 시작일 선택
//               const Text(
//                 '클라이밍 시작일',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     _isCalendarVisible = !_isCalendarVisible;
//                   });
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 16.0, vertical: 12.0),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey),
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         _selectedDay != null
//                             ? "${_selectedDay?.year}-${_selectedDay?.month}-${_selectedDay?.day}"
//                             : "클라이밍 시작일을 선택해주세요.",
//                         style:
//                             const TextStyle(fontSize: 16, color: Colors.grey),
//                       ),
//                       const Icon(Icons.arrow_drop_down),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),

//               // 달력 표시/숨기기
//               AnimatedCrossFade(
//                 firstChild: const SizedBox.shrink(),
//                 secondChild: Container(
//                   padding: const EdgeInsets.all(8.0),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey),
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                   child: TableCalendar(
//                     // locale: 'ko_KR',
//                     firstDay: DateTime(2000),
//                     lastDay: DateTime(2100),
//                     focusedDay: _focusedDay,
//                     selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
//                     onDaySelected: (selectedDay, focusedDay) {
//                       setState(() {
//                         _selectedDay = selectedDay;
//                         _focusedDay = focusedDay;
//                         _isCalendarVisible = false;
//                       });
//                     },
//                     calendarStyle: const CalendarStyle(
//                       selectedDecoration: BoxDecoration(
//                         color: Colors.orange,
//                         shape: BoxShape.circle,
//                       ),
//                       todayDecoration: BoxDecoration(
//                         color: Colors.blue,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                     headerStyle: const HeaderStyle(
//                       formatButtonVisible: false,
//                       titleCentered: true,
//                     ),
//                   ),
//                 ),
//                 crossFadeState: _isCalendarVisible
//                     ? CrossFadeState.showSecond
//                     : CrossFadeState.showFirst,
//                 duration: const Duration(milliseconds: 300),
//               ),
//               const SizedBox(height: 24),

//               // 키와 팔길이 입력 필드
//               Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           '키 (cm)',
//                           style: TextStyle(
//                               fontSize: 16, fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 8),
//                         TextField(
//                           controller: _heightController,
//                           keyboardType: const TextInputType.numberWithOptions(
//                               decimal: true),
//                           decoration: const InputDecoration(
//                             border: OutlineInputBorder(),
//                             hintText: '키 입력',
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           '팔길이 (cm)',
//                           style: TextStyle(
//                               fontSize: 16, fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 8),
//                         TextField(
//                           controller: _armSpanController,
//                           keyboardType: const TextInputType.numberWithOptions(
//                               decimal: true),
//                           decoration: const InputDecoration(
//                             border: OutlineInputBorder(),
//                             hintText: '팔길이 입력',
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),

//               // 저장 버튼
//               Center(
//                 child: SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _saveProfile,
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16.0),
//                       backgroundColor: Colors.blueAccent,
//                     ),
//                     child: const Text(
//                       '저장',
//                       style: TextStyle(fontSize: 18, color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
// // branch chec

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

  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _armSpanController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final userProfile = ref.read(profileProvider);

    if (userProfile != null) {
      // 🔹 null 체크 추가
      _nicknameController.text = userProfile.nickname;
      _heightController.text = userProfile.height.toString();
      _armSpanController.text = userProfile.armSpan.toString();
      _selectedDay = userProfile.climbingStartDate; // 기존 날짜 설정
    } else {
      print("⚠️ [에러 방지] userProfile이 null이라 기본값 사용");
    }
  }

  /// 🔹 프로필 수정 후 API에 반영
  Future<void> _saveProfile() async {
    final double? newHeight = double.tryParse(_heightController.text);
    final double? newArmSpan = double.tryParse(_armSpanController.text);

    if (newHeight != null && newArmSpan != null) {
      try {
        print("🔄 [프로필 업데이트 요청]");
        await ref.read(profileProvider.notifier).updateProfile(
              nickname: _nicknameController.text,
              height: newHeight,
              armSpan: newArmSpan,
              climbingStartDate: _selectedDay,
            );

        print("✅ [프로필 업데이트 성공]");
        Navigator.pop(context);
      } catch (e) {
        print("❌ [프로필 업데이트 오류]: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("프로필 업데이트 중 오류가 발생했습니다.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("키와 팔길이를 올바르게 입력하세요!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(profileProvider); // UI 변경 감지

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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
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
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 🔹 달력 표시/숨기기
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TableCalendar(
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

              // 🔹 키와 팔길이 입력 필드
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '키 (cm)',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _heightController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '키 입력',
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
                          '팔길이 (cm)',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _armSpanController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '팔길이 입력',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 🔹 저장 버튼 (API 요청 포함)
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: const Text(
                      '저장',
                      style: TextStyle(fontSize: 18, color: Colors.white),
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
