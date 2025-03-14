import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/common/jwt/jwt_token_provider.dart';
import 'package:kkulkkulk/common/storage/storage.dart';
import 'package:kkulkkulk/features/auth/data/models/user_login_model.dart';
import 'package:kkulkkulk/features/auth/data/repositories/auth_repository.dart';

class LogInViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  String errorMessage = '';
  String successMessage = '';
  String? username = '';

  // 상태 초기화 함수
  void reset() {
    emailController.clear();
    passwordController.clear();
    isLoading = false;
    errorMessage = '';
    successMessage = '';
    username = '';
    notifyListeners();
  }

  // 일반 로그인
  Future<bool> login(BuildContext context, WidgetRef ref) async {
    bool flag = false;
    final String email = emailController.text;
    final String password = passwordController.text;

    final UserLoginModel userLoginModel = UserLoginModel(
      email: email,
      password: password,
    );

    try {
      isLoading = true;
      notifyListeners();
      // print('email: $email password: $password');
      final Response response = await _authRepository.login(userLoginModel);
      // print('response: $response');
      if (response.statusCode == 200) {
        final String? token = response.headers.value('authorization');

        if (token != null) {
          // Bearer 접두어 제거
          final String actualToken = token.replaceFirst('Bearer ', '');
          // print('actualToken: $actualToken');

          await Storage.saveToken(token);
          final String? checkToken = await Storage.getToken();
          print('checkToken => $checkToken');
          // 토큰을 업데이트
          ref.read(jwtTokenProvider.notifier).state = actualToken;

          successMessage = '로그인 성공';
          flag = true;
          return flag;
        }
      }
    } catch (e) {
      errorMessage = '로그인 실패';
      print(e);
      return flag;
    }
    return flag;
  }

  @override
  void dispose() {
    // 텍스트 필드 초기화
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

final logInViewModelProvider = ChangeNotifierProvider<LogInViewModel>((ref) {
  return LogInViewModel();
});
