/// 기본 프로필 이미지 URL (서버 제공 기본 이미지)
const String defaultProfileImage =
    "https://ssafy-ori-bucket.s3.ap-northeast-2.amazonaws.com/profile_default.png";

class UserProfile {
  final String nickname;
  final double height;
  final double armSpan;
  final String profileImageUrl;
  final String userTier;
  final int dday; // ✅ dDay 필드 추가
  final DateTime? startDate;

  UserProfile({
    required this.nickname,
    required this.height,
    required this.armSpan,
    required this.profileImageUrl,
    required this.userTier,
    required this.dday, // ✅ dDay 필드 추가
    this.startDate,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final content = json['content'] ?? {}; // ✅ content 내부 값 가져오기
    return UserProfile(
      nickname: content['nickname'] ?? "클라이머", // ✅ 올바르게 매핑
      height: (content['height'] as num?)?.toDouble() ?? 0.0, // ✅ 올바르게 매핑
      armSpan: (content['armSpan'] as num?)?.toDouble() ?? 0.0, // ✅ 올바르게 매핑
      profileImageUrl:
          content['profileImageUrl'] ?? defaultProfileImage, // ✅ 기본값 유지
      userTier: content['userTier'] ?? "UNRANK", // ✅ 올바르게 매핑
      dday: content['dday'] ?? 0, // ✅ 올바르게 매핑
      startDate: content['startDate'] != null
          ? DateTime.parse(content['startDate'])
          : null, // ✅ null 허용
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'height': height,
      'armSpan': armSpan,
      'profileImageUrl': profileImageUrl,
      'userTier': userTier,
      'dday': dday,
      'startDate': startDate?.toIso8601String(),
    };
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
