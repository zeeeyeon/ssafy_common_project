import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/common/widgets/layout/custom_app_bar.dart';
import 'package:kkulkkulk/features/profile/view_models/profile_view_model.dart';
import 'package:kkulkkulk/features/profile/data/models/profile_model.dart';
import 'profile_screen_edit.dart';
import 'dart:io';
import 'profile_image_picker.dart';
import 'package:kkulkkulk/features/profile/view_models/profile_image_view_model.dart';

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
          debugPrint("🔥 UI에 표시될 프로필 데이터: ${userProfile.toJson()}");
          return _buildProfileUI(context, userProfile); // ✅ context 전달
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('데이터 불러오기 실패: $error')),
      ),
    );
  }

  /// 🔥 프로필 UI 구성
  Widget _buildProfileUI(BuildContext context, UserProfile userProfile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildProfileHeader(context, userProfile), // 🔹 프로필 사진 & 닉네임
          const SizedBox(height: 24),
          _buildDdayCard(userProfile.dday), // 🔹 클라이밍 시작 D-Day 카드
          const SizedBox(height: 16),
          _buildBodyInfo(userProfile), // 🔹 키 & 팔길이 정보
          const SizedBox(height: 24),
          _buildTierInfo(userProfile), // 🔹 클라이밍 티어
        ],
      ),
    );
  }

  /// 🔹 **프로필 사진 & 닉네임 영역**
  Widget _buildProfileHeader(BuildContext context, UserProfile userProfile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(userProfile.profileImageUrl),
            ),
            Consumer(
              builder: (context, ref, child) {
                return GestureDetector(
                  onTap: () async {
                    File? newImage =
                        await ProfileImagePicker.pickImageFromGallery();
                    if (newImage != null) {
                      await ref
                          .read(profileImageProvider.notifier)
                          .uploadProfileImage(newImage);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blueAccent,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                );
              },
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(userProfile.nickname,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("클라이밍 시작: ${userProfile.dday}일",
                style: TextStyle(color: Colors.grey[600])),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.grey),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ProfileScreenEdit()),
            );
          },
        ),
      ],
    );
  }

  /// 🔹 **D-Day 카드**
  Widget _buildDdayCard(int dday) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text("D-day",
              style: TextStyle(fontSize: 16, color: Colors.white)),
          const SizedBox(height: 8),
          Text(
            "$dday일",
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  /// 🔹 **키 & 팔길이 정보**
  Widget _buildBodyInfo(UserProfile userProfile) {
    return Row(
      children: [
        Expanded(child: _buildInfoCard("키", "${userProfile.height}cm")),
        const SizedBox(width: 8),
        Expanded(child: _buildInfoCard("팔길이", "${userProfile.armSpan}cm")),
      ],
    );
  }

  /// 🔹 **클라이밍 티어 정보**
  Widget _buildTierInfo(UserProfile userProfile) {
    return Column(
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
    );
  }

  /// 🔹 **공통 정보 카드 위젯**
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
