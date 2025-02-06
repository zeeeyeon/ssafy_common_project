// import 'package:flutter_riverpod/flutter_riverpod.dart';

// /// 기본 프로필 이미지 경로
// const String defaultProfileImage = "assets/images/default_profile.png";

// /// 사용자 프로필 데이터 모델
// class UserProfile {
//   final String nickname; // 닉네임
//   final String profileImage; // 프로필 이미지 URL
//   final DateTime? startDate; // 클라이밍 시작일
//   final double height; // 🔹 변경: String → double (키)
//   final double armSpan; // 🔹 변경: String → double (팔길이)

//   UserProfile({
//     required this.nickname,
//     required this.profileImage,
//     this.startDate,
//     required this.height,
//     required this.armSpan,
//   });

//   /// 클라이밍 시작일 기준 계산 (클라이밍 시작일이 있는 경우만)
//   int get dDay {
//     if (startDate == null) return 0;
//     final now = DateTime.now();
//     return now.difference(startDate!).inDays;
//   }

//   /// 🔹 D-Day에 따른 티어 이미지 반환
//   String get tierImage {
//     if (dDay >= 365) return "assets/images/tier/diamond.webp";
//     if (dDay >= 270) return "assets/images/tier/platinum.webp";
//     if (dDay >= 180) return "assets/images/tier/gold.webp";
//     if (dDay >= 90) return "assets/images/tier/silver.webp";
//     if (dDay >= 30) return "assets/images/tier/bronze.webp";
//     return "assets/images/tier/unranked.webp";
//   }

//   /// 🔹 D-Day에 따른 티어 이름 반환
//   String get tierText {
//     if (dDay >= 365) return "다이아몬드";
//     if (dDay >= 270) return "플래티넘";
//     if (dDay >= 180) return "골드";
//     if (dDay >= 90) return "실버";
//     if (dDay >= 30) return "브론즈";
//     return "비기너";
//   }

//   /// 데이터 복사를 위한 copyWith 메서드 (불변 객체 패턴)
//   UserProfile copyWith({
//     String? nickname,
//     String? profileImage,
//     DateTime? startDate,
//     double? height, // 🔹 String → double
//     double? armSpan, // 🔹 String → double
//   }) {
//     return UserProfile(
//       nickname: nickname ?? this.nickname,
//       startDate: startDate ?? this.startDate,
//       profileImage: profileImage ?? this.profileImage,
//       height: height ?? this.height,
//       armSpan: armSpan ?? this.armSpan,
//     );
//   }

//   /// 프로필 이미지가 비어있으면 기본 프로필 이미지 반환
//   String get effectiveProfileImage {
//     return profileImage.isNotEmpty ? profileImage : defaultProfileImage;
//   }
// }

// /// 상태를 관리하는 Notifier
// class ProfileNotifier extends StateNotifier<UserProfile> {
//   ProfileNotifier()
//       : super(UserProfile(
//           nickname: "클라이밍 유저",
//           profileImage: "",
//           startDate: null,
//           height: 0.0, // 🔹 초기값 변경
//           armSpan: 0.0, // 🔹 초기값 변경
//         ));

//   /// 닉네임 업데이트
//   void updateNickname(String newNickname) {
//     state = state.copyWith(nickname: newNickname);
//   }

//   /// 키와 팔길이 업데이트
//   void updateBodyInfo(double newHeight, double newArmSpan) {
//     state = state.copyWith(height: newHeight, armSpan: newArmSpan);
//   }

//   /// 클라이밍 시작일 업데이트
//   void updateStartDate(DateTime newStartDate) {
//     state = state.copyWith(startDate: newStartDate);
//   }

//   /// 프로필 이미지 업데이트
//   void updateProfileImage(String newImageUrl) {
//     state = state.copyWith(profileImage: newImageUrl);
//   }
// }

// /// 전역 프로필 상태 Provider
// final profileProvider =
//     StateNotifierProvider<ProfileNotifier, UserProfile>((ref) {
//   return ProfileNotifier();
// });

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/profile_model.dart';
import '../data/repositories/profile_repository.dart';

/// 기본 프로필 이미지 경로
const String defaultProfileImage = "assets/images/default_profile.png";

/// 🔹 ProfileViewModel: 프로필 데이터를 관리하는 StateNotifier
class ProfileViewModel extends StateNotifier<ProfileModel?> {
  final ProfileRepository _repository;

  /// 🔥 생성자에서 `_loadProfile()` 실행하여 앱 시작 시 자동으로 프로필 불러오기
  ProfileViewModel(this._repository) : super(null) {
    _loadProfile();
  }

  /// 🔹 프로필 불러오기 (API 호출)
  Future<void> _loadProfile() async {
    try {
      print("🔄 [프로필 로드 시작]");
      final profile = await _repository.fetchUserProfile();
      state = profile;
      print("✅ [프로필 로드 완료]: ${profile.nickname}");
    } catch (e) {
      print("❌ [프로필 로드 오류]: $e");
    }
  }

  /// 🔹 프로필 업데이트 (닉네임, 키, 팔길이, 클라이밍 시작일)
  Future<void> updateProfile({
    required String nickname,
    required double height,
    required double armSpan,
    required DateTime? climbingStartDate,
  }) async {
    try {
      print("🔄 [프로필 업데이트 요청]");
      await _repository.updateProfile(
        nickname: nickname,
        height: height,
        armSpan: armSpan,
        climbingStartDate: climbingStartDate,
      );

      /// 🔥 상태(state) 업데이트: UI에 즉시 반영되도록 변경
      state = ProfileModel(
        nickname: nickname,
        profileImage: state?.profileImage ?? '',
        height: height,
        armSpan: armSpan,
        climbingStartDate: climbingStartDate,
      );

      print("✅ [프로필 업데이트 성공]");
    } catch (e) {
      print("❌ [프로필 업데이트 오류]: $e");
    }
  }
}

/// 🔹 Provider 정의: 전역에서 `profileProvider`를 통해 상태를 감시할 수 있음.
final profileProvider =
    StateNotifierProvider<ProfileViewModel, ProfileModel?>((ref) {
  return ProfileViewModel(ProfileRepository());
});
