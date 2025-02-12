import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/common/widgets/layout/custom_app_bar.dart';
import 'package:kkulkkulk/features/profile/view_models/profile_view_model.dart';
import 'package:kkulkkulk/features/profile/data/models/profile_model.dart';
import 'profile_screen_edit.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔥 프로필 데이터 가져오기
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'My Page'),
      body: profileState.when(
        data: (userProfile) {
          print("🔥 UI에 표시될 프로필 데이터: ${userProfile.toJson()}");
          return _buildProfileUI(context, userProfile); // ✅ context 전달
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('데이터 불러오기 실패: $error')),
      ),
    );
  }

  // 🔥 프로필 UI 구성 (context 매개변수 추가)
  Widget _buildProfileUI(BuildContext context, UserProfile userProfile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 🔹 프로필 사진 & 닉네임
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(userProfile.profileImageUrl),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userProfile.nickname,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "클라이밍 시작: ${userProfile.dday}일",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
              // 🔥 프로필 수정 아이콘 버튼 추가
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey),
                onPressed: () {
                  Navigator.push(
                    context, // ✅ 수정: context 추가
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreenEdit(),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 🔹 클라이밍 시작 D-Day 카드
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text("클라이밍 시작한지",
                    style: TextStyle(fontSize: 16, color: Colors.white)),
                const SizedBox(height: 8),
                Text(
                  "${userProfile.dday}일",
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 🔹 키 & 팔길이 정보
          Row(
            children: [
              Expanded(child: _buildInfoCard("키", "${userProfile.height}cm")),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildInfoCard("팔길이", "${userProfile.armSpan}cm")),
            ],
          ),

          const SizedBox(height: 24),

          // 🔹 클라이밍 티어
          Column(
            children: [
              const Text("나의 클라이밍 티어",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(
                width: 200,
                height: 200,
                child: Image.asset(userProfile.tierImage, fit: BoxFit.cover),
              ),
              const SizedBox(height: 8),
              Text(
                userProfile.tierText,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🔥 정보 카드 위젯
  Widget _buildInfoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ],
      ),
    );
  }
}
