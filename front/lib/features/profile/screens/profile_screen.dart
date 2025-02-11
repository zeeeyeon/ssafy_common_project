import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/common/widgets/layout/custom_app_bar.dart';
import 'package:kkulkkulk/features/profile/view_models/profile_view_model.dart';
import 'package:kkulkkulk/features/profile/data/models/profile_model.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔥 프로필 데이터 가져오기
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Page',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // 설정 화면 이동
            },
          ),
        ],
      ),
      body: profileState.when(
        data: (userProfile) => _buildProfileUI(userProfile),
        loading: () =>
            const Center(child: CircularProgressIndicator()), // 🔹 로딩 상태
        error: (error, _) =>
            Center(child: Text('데이터 불러오기 실패: $error')), // 🔹 에러 상태
      ),
    );
  }

  // 🔥 프로필 UI 구성
  Widget _buildProfileUI(UserProfile userProfile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 🔹 프로필 사진 & 닉네임
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage(userProfile.effectiveProfileImage),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userProfile.username,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "클라이밍 시작: ${userProfile.dDay.toString().split(" ")[0] ?? '미입력'}",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
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
                  "${userProfile.dDay}일",
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
