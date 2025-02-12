/// 서버 제공 기본 이미지
const String defaultProfileImage =
    "https://ssafy-ori-bucket.s3.ap-northeast-2.amazonaws.com/profile_default.png";

class UserProfile {
  final String nickname;
  final double height;
  final double armSpan;
  final String profileImageUrl;
  final String userTier;
  final int dday;
  final DateTime? startDate;

  UserProfile({
    required this.nickname,
    required this.height,
    required this.armSpan,
    required this.profileImageUrl,
    required this.userTier,
    required this.dday,
    this.startDate,
  });

  /// ✅ API 응답 JSON을 UserProfile 객체로 변환
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final content = json['content'] ?? {}; // ✅ content 내부 값 가져오기
    return UserProfile(
      nickname: content['nickname'] ?? "클라이머", // 닉네임 기본값 설정
      height: (content['height'] as num?)?.toDouble() ?? 0.0, // 키 값 처리
      armSpan: (content['armSpan'] as num?)?.toDouble() ?? 0.0, // 팔길이 값 처리
      profileImageUrl:
          content['profileImageUrl'] ?? defaultProfileImage, // 기본 프로필 이미지 설정
      userTier: content['userTier'] ?? "UNRANK", // 기본 티어 설정
      dday: content['dday'] ?? 0, // dDay 기본값 설정
      startDate: content['startDate'] != null
          ? DateTime.parse(content['startDate'])
          : null, // startDate 값 파싱 (null 허용)
    );
  }

  /// ✅ UserProfile 객체를 JSON으로 변환
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

  /// ✅ 클라이밍 티어에 따른 텍스트 반환
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
