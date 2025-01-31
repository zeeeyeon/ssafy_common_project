class UserSignupModel {
  final String email;
  final String password;
  final String username;
  final String phone;
  final String nickname;

  UserSignupModel({
    required this.email,
    required this.password,
    required this.username,
    required this.phone,
    required this.nickname,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'username': username,
      'phone': phone,
      'nickname': nickname,
    };
  }

  factory UserSignupModel.fromJson(Map<String, dynamic> json) {
    return UserSignupModel(
      email: json['email'],
      password: json['password'],
      username: json['username'],
      phone: json['phone'],
      nickname: json['nickname'],
    );
  }
}