class TranslateSocialToUserModel {
  final String accessToken;
  final String password;
  final String nickname;
  final String username;
  final String phone;

  TranslateSocialToUserModel({
    required this.accessToken,
    required this.password,
    required this.nickname,
    required this.username,
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'password': password,
      'nickname': nickname,
      'username': username,
      'phone': phone,
    };
  }
}