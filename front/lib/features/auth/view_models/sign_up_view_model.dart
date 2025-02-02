import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/features/auth/data/models/user_signup_model.dart';
import 'package:kkulkkulk/features/auth/data/repositories/auth_repository.dart';

class SignUpViewModel extends ChangeNotifier{
  final AuthRepository _authRepository = AuthRepository();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController checkPasswordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();

  bool isLoading = false;
  
  String errorMessage = '';
  String successMessage = '';

  // 이메일 유효성 검사
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요';
    }
    // 이메일 형식 체크
    final emailRegExp = RegExp(r"^[a-zA-Z0-9]+@[0-9a-zA-Z]+\.[a-z]+$");
    if (!emailRegExp.hasMatch(value)) {
      return '이메일 형식이어야 합니다.';
    }
    return null;
  }

  // 비밀번호 유효성 검사
  String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return '비밀번호를 입력해주세요';
  }
  // 비밀번호 형식 체크: 대소문자, 숫자, 특수문자 조합 (8 ~ 128자)
    final passwordRegExp = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d|(?=.*\W)).{8,128}$');
    if (!passwordRegExp.hasMatch(value)) {
      return '대소문자, 숫자, 특수문자 조합으로 8 ~ 128자리여야 합니다.';
    }
  return null;
}


  // 비밀번호 확인 유효성 검사
  String? validateCheckPassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호 확인을 입력해주세요';
    }
    // 비밀번호와 비밀번호 확인이 일치하는지 확인
    if (value != passwordController.text) {
      return '비밀번호가 일치하지 않습니다.';
    }
    return null;
  }

  // 이름 유효성 검사
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return '이름은 공백일 수 없습니다.';
    }
    return null;
  }

  // 전화번호 유효성 검사
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return '전화번호는 공백일 수 없습니다.';
    }
    // 정규식: 하이픈 없이 전화번호 (01012345678 형태)
    final phoneRegExp = RegExp(r'^(01[0-9])\d{3,4}\d{4}$');
    if (!phoneRegExp.hasMatch(value)) {
      return '유효한 전화번호를 입력해주세요.';
    }
    return null;
  }



  // 닉네임 유효성 검사
  String? validateNickname(String? value) {
    if (value == null || value.isEmpty) {
      return '닉네임은 공백일 수 없습니다.';
    }
    return null;
  }

  // 유효성 검사 함수
  bool validateInputs() {
    final emailError = validateEmail(emailController.text);
    final passwordError = validatePassword(passwordController.text);
    final checkPasswordError = validateCheckPassword(checkPasswordController.text);
    final usernameError = validateUsername(usernameController.text);
    final phoneError = validatePhone(phoneController.text);
    final nicknameError = validateNickname(nicknameController.text);

    if (emailError != null || passwordError != null || checkPasswordError != null || usernameError != null || phoneError != null || nicknameError != null) {
      return false;
    }
    return true;
  }

  // 이메일 중복 확인
  Future<bool> duplicatedEmail() async {
    final String email = emailController.text;
    try {
      isLoading = true;
      notifyListeners();

      final Response response = await _authRepository.duplicatedEmail(email);

      if(response.statusCode == 200) {
        if(response.data['header']['httpStatus'] == 400) {
          print('이메일 중복');
          errorMessage = '이미 존재하는 계정의 이메일입니다';
          notifyListeners();
          return false;
        }else if(response.data['header']['httpStatus'] == 200) {
          print('사용가능한 이메일입니다');
          successMessage = '사용가능한 이메일입니다';
          notifyListeners();
          return true;
        }
      }

    } catch (e) {
      return false;
    }
    return false;
  }

  // 닉네임 중복 확인

  // 회원가입
  Future<void> signUp() async {
    final String email = emailController.text;
    final String password = passwordController.text;
    final String username = usernameController.text;
    final String phone = phoneController.text;
    final String nickname = nicknameController.text;

    final UserSignupModel userSignupModel = UserSignupModel(
      email: email, 
      password: password, 
      username: username, 
      phone: phone, 
      nickname: nickname
    );

    try {
      isLoading = true;
      notifyListeners();

      final Response response = await _authRepository.signup(userSignupModel);

      if(response.statusCode == 200) {
        print(response);
      }
      
    } catch (e) {
      print('에러 발생 $e');
    }
  }



}

final signUpViewModelProvider = ChangeNotifierProvider<SignUpViewModel>((ref) {
  return SignUpViewModel();
});