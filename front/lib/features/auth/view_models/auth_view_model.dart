import 'package:flutter/material.dart';
import 'package:kkulkkulk/features/auth/data/models/user_login_model.dart';
import 'package:kkulkkulk/features/auth/data/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 로그인
  Future<void> login(UserLoginModel userLoginModel) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authRepository.login(userLoginModel);
      if(response.statusCode == 200) {
        // 로그인 성공
        _errorMessage = null;
        // 추가 처리 (예: JWT 토큰 저장, 홈 화면 이동 등)
      } else {
        // 로그인 실패
        _errorMessage = '로그인 실패: ${response.data}';
      }
    }catch(e) {
      _errorMessage = '네트워크 오류: $e';
    }finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 이메일 중복 확인
  

}