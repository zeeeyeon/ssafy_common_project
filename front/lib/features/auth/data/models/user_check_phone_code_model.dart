class UserCheckPhoneCodeModel {
  final String authCode;

  UserCheckPhoneCodeModel({
    required this.authCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'authCode': authCode,
    };
  }

  factory UserCheckPhoneCodeModel.fromJson(Map<String, dynamic> json) {
    return UserCheckPhoneCodeModel(
      authCode: json['authCode'],
    );
  }
}