class UserSubmitPhoneCodeModel {
  final String phone;

  UserSubmitPhoneCodeModel({
    required this.phone
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
    };
  }

  factory UserSubmitPhoneCodeModel.fromJson(Map<String, dynamic> json) {
    return UserSubmitPhoneCodeModel(
      phone: json['phone'],
    );
  }
}