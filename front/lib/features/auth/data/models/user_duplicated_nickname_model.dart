class UserDuplicatedNicknameModel {
  final String nickname;

  UserDuplicatedNicknameModel({
    required this.nickname,
  });

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
    };
  }

  factory UserDuplicatedNicknameModel.fromJson(Map<String, dynamic> json) {
    return UserDuplicatedNicknameModel(
      nickname: json['nickname'],
    );
  }
}