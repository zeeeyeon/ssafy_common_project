// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:kkulkkulk/common/widgets/layout/custom_app_bar.dart';
// import 'package:kkulkkulk/features/profile/screens/profile_screen_edit.dart';
// import 'package:kkulkkulk/features/profile/view_models/profile_view_model.dart';

// class ProfileScreen extends ConsumerWidget {
//   const ProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Riverpod 상태 읽기
//     final userProfile = ref.watch(profileProvider);
//     return Scaffold(
//       appBar: CustomAppBar(
//         title: 'My',
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.settings),
//             onPressed: () {
//               // 설정 화면으로 이동
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         // 🔹 스크롤 가능하도록 추가
//         physics: const BouncingScrollPhysics(), // 🔹 iOS에서도 부드러운 스크롤
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               // 프로필 섹션
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       CircleAvatar(
//                         radius: 30,
//                         backgroundImage:
//                             AssetImage(userProfile.effectiveProfileImage),
//                       ),
//                       const SizedBox(width: 16),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             userProfile.nickname,
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           InkWell(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) =>
//                                       const ProfileScreenEdit(),
//                                 ),
//                               );
//                             },
//                             borderRadius: BorderRadius.circular(4),
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(
//                                   vertical: 4.0, horizontal: 4.0),
//                               child: Text(
//                                 userProfile.startDate != null
//                                     ? "${userProfile.startDate!.year}년${userProfile.startDate!.month}월${userProfile.startDate!.day}일 클라이밍 시작🚀"
//                                     : "언제 클라이밍을 시작했나요?",
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   color: Color.fromARGB(255, 121, 163, 231),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.edit),
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const ProfileScreenEdit(),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),
//               // 클라이밍 시작 카드
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(16.0),
//                 decoration: BoxDecoration(
//                   color: const Color.fromARGB(255, 80, 118, 232),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     const Text(
//                       '클라이밍 시작한지',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       '${userProfile.dDay} 일',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 10),
//               // 키와 팔길이 카드
//               Row(
//                 children: [
//                   Expanded(
//                     child: _buildInfoCard('키', userProfile.height),
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: _buildInfoCard('팔길이', userProfile.armSpan),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),
//               // 티어 이미지 추가
//               Align(
//                 alignment: Alignment.center, // 중앙 정렬
//                 child: Column(
//                   children: [
//                     const Text(
//                       "나의 클라이밍 티어",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     SizedBox(
//                       width: 230, // 크기를 키우기
//                       height: 230,
//                       child: ClipOval(
//                         child: Image.asset(
//                           userProfile.tierImage,
//                           fit: BoxFit.cover, // 꽉 차게 맞추기
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       userProfile.tierText,
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blueAccent,
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoCard(String title, double value) {
//     // 🔹 타입 변경: String → double
//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: const Color.fromARGB(255, 80, 118, 232),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             "${value.toStringAsFixed(1)} CM", // 🔹 double을 String으로 변환
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/common/widgets/layout/custom_app_bar.dart';
import 'package:kkulkkulk/features/profile/screens/profile_screen_edit.dart';
import 'package:kkulkkulk/features/profile/view_models/profile_view_model.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔹 프로필 상태 감시 (API 데이터 불러오기)
    final userProfile = ref.watch(profileProvider);

    // 🔄 API 데이터 로드 중이면 로딩 화면 표시
    if (userProfile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    print("📌 [UI 업데이트] 프로필 정보 로드 완료: ${userProfile.nickname}");

    return Scaffold(
      appBar: CustomAppBar(
        title: 'My',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 🔹 프로필 섹션
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: userProfile.profileImage.isNotEmpty
                        ? NetworkImage(userProfile.profileImage)
                        : const AssetImage("assets/images/default_profile.png")
                            as ImageProvider,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userProfile.nickname,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreenEdit(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 4.0),
                          child: Text(
                            userProfile.climbingStartDate != null
                                ? "${userProfile.climbingStartDate!.year}년 ${userProfile.climbingStartDate!.month}월 ${userProfile.climbingStartDate!.day}일 클라이밍 시작🚀"
                                : "언제 클라이밍을 시작했나요?",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 121, 163, 231),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // 🔹 클라이밍 시작 카드
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 80, 118, 232),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '클라이밍 시작한지',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_calculateDDay(userProfile.climbingStartDate)} 일',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // 🔹 키와 팔길이 카드
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard('키', userProfile.height),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoCard('팔길이', userProfile.armSpan),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // 🔹 티어 이미지 추가
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    const Text(
                      "나의 클라이밍 티어",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 230,
                      height: 230,
                      child: ClipOval(
                        child: Image.asset(
                          "assets/images/tier_${_getTier(userProfile.climbingStartDate)}.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getTierText(userProfile.climbingStartDate),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 키와 팔길이 카드 UI
  Widget _buildInfoCard(String title, double value) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 80, 118, 232),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${value.toStringAsFixed(1)} CM",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 D-Day 계산
  int _calculateDDay(DateTime? startDate) {
    if (startDate == null) return 0;
    return DateTime.now().difference(startDate).inDays;
  }

  // 🔹 티어 이미지 결정
  String _getTier(DateTime? startDate) {
    final dDay = _calculateDDay(startDate);
    if (dDay < 30) return "bronze";
    if (dDay < 90) return "silver";
    if (dDay < 180) return "gold";
    return "diamond";
  }

  // 🔹 티어 텍스트 결정
  String _getTierText(DateTime? startDate) {
    final dDay = _calculateDDay(startDate);
    if (dDay < 30) return "브론즈 클라이머";
    if (dDay < 90) return "실버 클라이머";
    if (dDay < 180) return "골드 클라이머";
    return "다이아 클라이머";
  }
}
