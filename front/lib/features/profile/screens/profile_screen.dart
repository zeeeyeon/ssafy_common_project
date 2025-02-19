import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kkulkkulk/common/storage/storage.dart';
import 'package:kkulkkulk/common/widgets/layout/custom_app_bar.dart';
import 'package:kkulkkulk/features/profile/view_models/profile_view_model.dart';
import 'package:kkulkkulk/features/profile/data/models/profile_model.dart';
import 'profile_screen_edit.dart';
import 'dart:io';
import 'profile_image_picker.dart';
import 'package:kkulkkulk/features/profile/view_models/profile_image_view_model.dart';
import 'package:kkulkkulk/common/dialogs/logout_dialog.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // 화면에 들어갈 때마다 프로필 정보를 새로 요청
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.refresh(profileProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 프로필 데이터 가져오기
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'My',
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              showLogoutDialog(context, () {
                debugPrint("로그아웃 실행!");
                ref.invalidate(profileProvider);
                Storage.removeToken();
                context.push('/login');
                print(Storage.getToken());
              });
            },
          ),
        ],
      ),
      body: profileState.when(
        data: (userProfile) {
          debugPrint("🔥 UI에 표시될 프로필 데이터: ${userProfile.toJson()}");
          return _buildProfileUI(context, userProfile);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          debugPrint("프로필 데이터 로드 오류: $error\n$stack");
          return Center(child: Text('데이터 불러오기 실패: $error'));
        },
      ),
    );
  }

  /// 프로필 UI 구성
  Widget _buildProfileUI(BuildContext context, UserProfile userProfile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildProfileHeader(context, userProfile),
          const SizedBox(height: 24),
          _buildDdayCard(userProfile.dday),
          const SizedBox(height: 16),
          _buildBodyInfo(userProfile),
          const SizedBox(height: 24),
          _buildTierInfo(userProfile),
        ],
      ),
    );
  }

  /// 프로필 사진 & 닉네임 영역
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
            // 별도의 Consumer 위젯을 사용해서 이미지 업로드 시 상태를 반영
            Consumer(
              builder: (context, ref, child) {
                return GestureDetector(
                  onTap: () async {
                    try {
                      final File? newImage =
                          await ProfileImagePicker.pickImageFromGallery();
                      if (newImage != null) {
                        await ref
                            .read(profileImageProvider.notifier)
                            .uploadProfileImage(newImage);
                        // 업로드 후 프로필 정보 다시 불러오기 (UI 업데이트)
                        await ref
                            .read(profileProvider.notifier)
                            .refreshProfile();
                      }
                    } catch (e) {
                      debugPrint("프로필 이미지 업로드 오류: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('프로필 이미지 업로드에 실패했습니다.')),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color.fromARGB(255, 248, 139, 5),
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
            Text(
              userProfile.nickname,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "클라이밍 시작: ${userProfile.dday}일",
              style: TextStyle(color: Colors.grey[600]),
            ),
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

  /// D-Day 카드
  Widget _buildDdayCard(int dday) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 248, 139, 5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            "D-day",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            "$dday일",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// 키 & 팔길이 정보
  Widget _buildBodyInfo(UserProfile userProfile) {
    return Row(
      children: [
        Expanded(child: _buildInfoCard("키", "${userProfile.height}cm")),
        const SizedBox(width: 8),
        Expanded(child: _buildInfoCard("팔길이", "${userProfile.armSpan}cm")),
      ],
    );
  }

  /// 클라이밍 티어 정보
  Widget _buildTierInfo(UserProfile userProfile) {
    return Column(
      children: [
        const Text("나의 클라이밍 티어",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(
          width: 200,
          child: Image.asset(userProfile.tierImage, fit: BoxFit.cover),
        ),
        Text(
          userProfile.tierText,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 공통 정보 카드 위젯
  Widget _buildInfoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 248, 139, 5),
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
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
