// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:kkulkkulk/features/profile/view_models/profile_view_model.dart';

// class ProfileScreenEdit extends ConsumerWidget {
//   const ProfileScreenEdit({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final userProfile = ref.watch(profileProvider);

//     // 컨트롤러 정의
//     final TextEditingController nameController =
//         TextEditingController(text: userProfile.name);
//     final TextEditingController heightController =
//         TextEditingController(text: userProfile.height);
//     final TextEditingController armSpanController =
//         TextEditingController(text: userProfile.armSpan);
//     DateTime? selectedDate = userProfile.startDate;

//     // 날짜 선택 함수
//     Future<void> selectDate(BuildContext context) async {
//       final pickedDate = await showDatePicker(
//         context: context,
//         initialDate: selectedDate ?? DateTime.now(),
//         firstDate: DateTime(2000),
//         lastDate: DateTime.now(),
//       );

//       if (pickedDate != null) {
//         selectedDate = pickedDate;
//       }
//     }

//     // 저장 버튼 함수
//     void saveProfile() {
//       ref.read(profileProvider.notifier).updateName(nameController.text);
//       ref.read(profileProvider.notifier).updateBodyInfo(
//             heightController.text,
//             armSpanController.text,
//           );
//       if (selectedDate != null) {
//         ref.read(profileProvider.notifier).updateStartDate(selectedDate!);
//       }
//       Navigator.pop(context);
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('내 정보 수정'),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 이름 입력
//             const Text(
//               '이름',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(
//                 hintText: '이름을 입력하세요.',
//               ),
//             ),

//             const SizedBox(height: 16),

//             // 클라이밍 시작일
//             const Text(
//               '클라이밍 시작일',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             GestureDetector(
//               onTap: () => selectDate(context),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 16.0, vertical: 12.0),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       selectedDate != null
//                           ? "${selectedDate?.year}-${selectedDate?.month}-${selectedDate?.day}"
//                           : "클라이밍 시작일을 선택해주세요.",
//                       style: const TextStyle(fontSize: 16),
//                     ),
//                     const Icon(Icons.arrow_drop_down),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),

//             // 키와 팔길이 입력
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         '키',
//                         style: TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                       TextField(
//                         controller: heightController,
//                         keyboardType: TextInputType.number,
//                         decoration: const InputDecoration(
//                           hintText: '-CM',
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         '팔길이',
//                         style: TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                       TextField(
//                         controller: armSpanController,
//                         keyboardType: TextInputType.number,
//                         decoration: const InputDecoration(
//                           hintText: '-CM',
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),

//             const Spacer(),

//             // 측정하기 버튼
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 IconButton(
//                   onPressed: () {
//                     // 왼쪽 카메라 기능 추가
//                   },
//                   icon: const Icon(Icons.camera_alt),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     // 측정하기 기능 추가
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.black,
//                   ),
//                   child: const Text(
//                     '측정하기',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: () {
//                     // 오른쪽 카메라 기능 추가
//                   },
//                   icon: const Icon(Icons.camera_alt),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ElevatedButton(
//           onPressed: saveProfile,
//           style: ElevatedButton.styleFrom(
//             padding: const EdgeInsets.symmetric(vertical: 16.0),
//           ),
//           child: const Text(
//             '저장',
//             style: TextStyle(fontSize: 18),
//           ),
//         ),
//       ),
//     );
//   }
// }

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
//   DateTime _focusedDay = DateTime.now(); // 현재 포커스된 날짜
//   DateTime? _selectedDay; // 선택된 날짜
//   bool _isCalendarVisible = false; // 달력 표시 여부

//   final TextEditingController _heightController = TextEditingController();
//   final TextEditingController _armSpanController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     final userProfile = ref.read(profileProvider);
//     _heightController.text = userProfile.height;
//     _armSpanController.text = userProfile.armSpan;
//   }

//   void _saveProfile() {
//     ref.read(profileProvider.notifier).updateName("클라이밍 유저");
//     ref.read(profileProvider.notifier).updateBodyInfo(
//           _heightController.text,
//           _armSpanController.text,
//         );

//     if (_selectedDay != null) {
//       ref.read(profileProvider.notifier).updateStartDate(_selectedDay!);
//     }
//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final userProfile = ref.watch(profileProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('내 정보 수정'),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         // 여기에서 스크롤 가능하도록 처리
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // 이름 입력 필드
//               const Text(
//                 '이름',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               TextField(
//                 controller: TextEditingController(text: userProfile.name),
//                 decoration: const InputDecoration(
//                   hintText: '이름을 입력하세요.',
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // 달력 선택 필드
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
//                         style: const TextStyle(fontSize: 16),
//                       ),
//                       const Icon(Icons.arrow_drop_down),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),

//               // 달력 표시/숨기기
//               Visibility(
//                 visible: _isCalendarVisible,
//                 child: Container(
//                   padding: const EdgeInsets.all(8.0),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey),
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                   child: TableCalendar(
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
//                         color: Colors.blue,
//                         shape: BoxShape.circle,
//                       ),
//                       todayDecoration: BoxDecoration(
//                         color: Colors.orange,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                     headerStyle: const HeaderStyle(
//                       formatButtonVisible: false,
//                       titleCentered: true,
//                     ),
//                   ),
//                 ),
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
//                           '키',
//                           style: TextStyle(
//                               fontSize: 16, fontWeight: FontWeight.bold),
//                         ),
//                         TextField(
//                           controller: _heightController,
//                           keyboardType: TextInputType.number,
//                           decoration: const InputDecoration(
//                             hintText: '-CM',
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
//                           '팔길이',
//                           style: TextStyle(
//                               fontSize: 16, fontWeight: FontWeight.bold),
//                         ),
//                         TextField(
//                           controller: _armSpanController,
//                           keyboardType: TextInputType.number,
//                           decoration: const InputDecoration(
//                             hintText: '-CM',
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
//                 child: ElevatedButton(
//                   onPressed: _saveProfile,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 32.0, vertical: 16.0),
//                   ),
//                   child: const Text(
//                     '저장',
//                     style: TextStyle(fontSize: 18),
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
