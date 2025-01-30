class UserSignupModel {
  final String email;
  final String password;
  final String name;
  final String phone;
  final String nickname;

  UserSignupModel({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
    required this.nickname,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
      'nickname': nickname,
    };
  }

  factory UserSignupModel.fromJson(Map<String, dynamic> json) {
    return UserSignupModel(
      email: json['email'],
      password: json['password'],
      name: json['name'],
      phone: json['phone'],
      nickname: json['nickname'],
    );
  }
}