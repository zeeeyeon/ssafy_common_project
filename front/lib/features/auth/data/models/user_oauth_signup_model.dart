class UserOauthSignupModel {
  final String password;
  final String username;
  final String phone;
  final String nickname;

  UserOauthSignupModel({
    required this.password,
    required this.username,
    required this.phone,
    required this.nickname,
  });

  Map<String, dynamic> toJson() {
    return {
      'password': password,
      'username': username,
      'phone': phone,
      'nickname:': nickname,
    };
  }

  factory UserOauthSignupModel.fromJson(Map<String, dynamic> json) {
    return UserOauthSignupModel(
      password: json['password'],
      username: json['username'],
      phone: json['phone'],
      nickname: json['nickname'],
    );
  }
}
