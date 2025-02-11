class UserProfile {
  final String username;
  final double height;
  final double armSpan;
  final String userTier;
  final int dDay;

  UserProfile({
    required this.username,
    required this.height,
    required this.armSpan,
    required this.userTier,
    required this.dDay,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'],
      height: (json['height'] as num).toDouble(),
      armSpan: (json['armSpan'] as num).toDouble(),
      userTier: json['userTier'],
      dDay: json['dday'],
    );
  }

  /// 클라이밍 티어에 따른 이미지 반환
  String get tierImage {
    switch (userTier) {
      case "DIAMOND":
        return "assets/images/tier/Diamond.webp";
      case "PLATINUM":
        return "assets/images/tier/Platinum.webp";
      case "GOLD":
        return "assets/images/tier/Gold.webp";
      case "SILVER":
        return "assets/images/tier/silver.webp";
      case "BRONZE":
        return "assets/images/tier/Bronze.webp";
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

  String get effectiveProfileImage {
    return "assets/images/default_profile.png"; // 기본 이미지 설정
  }
}
