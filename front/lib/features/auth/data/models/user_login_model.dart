class UserLoginModel {
  final String email;
  final String password;

  UserLoginModel({
    required this.email, 
    required this.password
  });

  // JSON 데이터로 변환
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
  
  // JSON을 UserLoginModel 객체로 변환
  factory UserLoginModel.fromJson(Map<String, dynamic> json) {
    return UserLoginModel(
      email: json['email'],
      password: json['password'],
    );
  }
}