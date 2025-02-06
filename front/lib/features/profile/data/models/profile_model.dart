class ProfileModel {
  final String nickname;
  final String profileImage;
  final double height;
  final double armSpan;
  final DateTime? climbingStartDate;

  ProfileModel({
    required this.nickname,
    required this.profileImage,
    required this.height,
    required this.armSpan,
    this.climbingStartDate,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      nickname: json['nickname'],
      profileImage: json['profile_image'],
      height: json['height'].toDouble(),
      armSpan: json['arm_span'].toDouble(),
      climbingStartDate: json['climbing_start_date'] != null
          ? DateTime.parse(json['climbing_start_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'profile_image': profileImage,
      'height': height,
      'arm_span': armSpan,
      'climbing_start_date': climbingStartDate?.toIso8601String(),
    };
  }
}
