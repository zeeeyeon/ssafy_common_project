import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 기본 프로필 이미지 경로
const String defaultProfileImage = "assets/images/default_profile.png";

/// 사용자 프로필 데이터 모델
class UserProfile {
  final String name; // 닉네임
  final String profileImage; // 프로필 이미지 URL
  final DateTime? startDate; // 클라이밍 시작일
  final String height; // 키
  final String armSpan; // 팔길이

  UserProfile({
    required this.name,
    required this.profileImage,
    this.startDate,
    required this.height,
    required this.armSpan,
  });

  /// 클라이밍 시작일 기준 계산 (클라이밍 시작일이 있는 경우만)
  int get dDay {
    if (startDate == null) return 0;
    final now = DateTime.now();
    return now.difference(startDate!).inDays;
  }

  /// 🔹 D-Day에 따른 티어 이미지 반환
  String get tierImage {
    if (dDay >= 365) return "assets/images/tier/diamond.webp";
    if (dDay >= 270) return "assets/images/tier/platinum.webp";
    if (dDay >= 180) return "assets/images/tier/gold.webp";
    if (dDay >= 90) return "assets/images/tier/silver.webp";
    if (dDay >= 30) return "assets/images/tier/bronze.webp";
    return "assets/images/tier/unranked.webp";
  }

  /// 🔹 D-Day에 따른 티어 이름 반환
  String get tierText {
    if (dDay >= 365) return "다이아몬드";
    if (dDay >= 270) return "플래티넘";
    if (dDay >= 180) return "골드";
    if (dDay >= 90) return "실버";
    if (dDay >= 30) return "브론즈";
    return "비기너";
  }

  /// 데이터 복사를 위한 copyWith 메서드 (불변 객체 패턴)
  UserProfile copyWith({
    String? name,
    String? profileImage,
    DateTime? startDate,
    String? height,
    String? armSpan,
  }) {
    return UserProfile(
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      startDate: startDate ?? this.startDate,
      height: height ?? this.height,
      armSpan: armSpan ?? this.armSpan,
    );
  }

  /// 프로필 이미지가 비어있으면 기본 프로필 이미지 반환
  String get effectiveProfileImage {
    return profileImage.isNotEmpty ? profileImage : defaultProfileImage;
  }
}

/// 상태를 관리하는 Notifier
class ProfileNotifier extends StateNotifier<UserProfile> {
  ProfileNotifier()
      : super(UserProfile(
          name: "클라이밍 유저",
          profileImage: "",
          startDate: null,
          height: "-CM",
          armSpan: "-CM",
        ));

  /// 닉네임 업데이트
  void updateName(String newName) {
    state = state.copyWith(name: newName);
  }

  /// 키와 팔길이 업데이트
  void updateBodyInfo(String newHeight, String newArmSpan) {
    state = state.copyWith(height: newHeight, armSpan: newArmSpan);
  }

  /// 클라이밍 시작일 업데이트
  void updateStartDate(DateTime newStartDate) {
    state = state.copyWith(startDate: newStartDate);
  }

  /// 프로필 이미지 업데이트 (추후 카메라 연동 시 활용 가능)
  void updateProfileImage(String newImageUrl) {
    state = state.copyWith(profileImage: newImageUrl);
  }
}

/// 전역 프로필 상태 Provider
final profileProvider =
    StateNotifierProvider<ProfileNotifier, UserProfile>((ref) {
  return ProfileNotifier();
});
