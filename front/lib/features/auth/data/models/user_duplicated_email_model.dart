class UserDuplicatedEmailModel {
  final String email;

  UserDuplicatedEmailModel({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }

  factory UserDuplicatedEmailModel.fromJson(Map<String, dynamic> json) {
    return UserDuplicatedEmailModel(
      email: json['email'],
    );
  }
}