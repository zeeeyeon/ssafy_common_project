/// 기본 프로필 이미지 URL (서버 제공 기본 이미지)
const String defaultProfileImage =
    "https://ssafy-ori-bucket.s3.ap-northeast-2.amazonaws.com/profile_default.png";

/// ✅ 사용자 프로필 데이터 모델
class UserProfile {
  final String nickname; // 닉네임
  final double height; // 키
  final double armSpan; // 팔길이
  final String profileImageUrl; // 프로필 이미지 URL
  final String userTier; // 클라이밍 티어
  final int dDay; // 클라이밍 시작일 기준 D-Day

  UserProfile({
    required this.nickname,
    required this.height,
    required this.armSpan,
    required this.profileImageUrl,
    required this.userTier,
    required this.dDay,
  });

  /// ✅ API 응답 JSON을 UserProfile 객체로 변환
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      nickname: json['content']['nickname'] ?? "클라이머",
      height: (json['content']['height'] as num).toDouble(),
      armSpan: (json['content']['armSpan'] as num).toDouble(),
      profileImageUrl:
          json['content']['profileImageUrl'] ?? defaultProfileImage,
      userTier: json['content']['userTier'] ?? "UNRANK",
      dDay: json['content']['dday'] as int,
    );
  }

  /// ✅ 클라이밍 티어에 따른 이미지 경로 반환
  String get tierImage {
    switch (userTier.toUpperCase()) {
      case "DIAMOND":
        return "assets/images/tier/diamond.webp";
      case "PLATINUM":
        return "assets/images/tier/platinum.webp";
      case "GOLD":
        return "assets/images/tier/gold.webp";
      case "SILVER":
        return "assets/images/tier/silver.webp";
      case "BRONZE":
        return "assets/images/tier/bronze.webp";
      default:
        return "assets/images/tier/unranked.webp";
    }
  }

  /// 티어 텍스트 반환
  String get tierText {
    switch (userTier) {
      case "DIAMOND":
        return "다이아몬드";
      case "PLATINUM":
        return "플래티넘";
      case "GOLD":
        return "골드";
      case "SILVER":
        return "실버";
      case "BRONZE":
        return "브론즈";
      default:
        return "비기너";
    }
  }
}
