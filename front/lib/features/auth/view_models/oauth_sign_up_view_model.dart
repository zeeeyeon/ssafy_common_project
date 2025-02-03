import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/features/auth/data/repositories/auth_repository.dart';

class OauthSignUpViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController checkPasswordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();

  bool isLoading = false;
  
  String errorMessage = '';
  String successMessage = '';

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
    final passwordError = validatePassword(passwordController.text);
    final checkPasswordError = validateCheckPassword(checkPasswordController.text);
    final usernameError = validateUsername(usernameController.text);
    final phoneError = validatePhone(phoneController.text);
    final nicknameError = validateNickname(nicknameController.text);

    if (passwordError != null || checkPasswordError != null || usernameError != null || phoneError != null || nicknameError != null) {
      return false;
    }
    return true;
  }

  // 닉네임 중복 확인
  Future<bool> duplicatedNickname() async {
    final String nickname = nicknameController.text;
    try {
      isLoading = true;
      notifyListeners();

      final Response response = await _authRepository.duplicatedNickname(nickname);

      if(response.statusCode == 200) {
        if(response.data['header']['httpStatus'] == 400) {
          print('닉네임 중복');
          errorMessage = '이미 존재하는 닉네임입니다';
          notifyListeners();
          return false;
        }else if(response.data['header']['httpStatus'] == 200) {
          print('사용가능한 닉네임');
          successMessage = '사용가능한 닉네임입니다';
          notifyListeners();
          return true;
        }
      }

    } catch (e) {
      return false;
    }
    return false;
  }

}

final OauthSignUpViewModelProvider = ChangeNotifierProvider<OauthSignUpViewModel>((ref) {
  return OauthSignUpViewModel();
});