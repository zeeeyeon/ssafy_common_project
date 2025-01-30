import 'package:dio/dio.dart';
import 'package:kkulkkulk/features/auth/data/models/user_check_phone_code_model.dart';
import 'package:kkulkkulk/features/auth/data/models/user_duplicated_email_model.dart';
import 'package:kkulkkulk/features/auth/data/models/user_duplicated_nickname_model.dart';
import 'package:kkulkkulk/features/auth/data/models/user_login_model.dart';
import 'package:kkulkkulk/features/auth/data/models/user_signup_model.dart';
import 'package:kkulkkulk/features/auth/data/models/user_submit_phone_code_model.dart';

class AuthRepository {
  final Dio _dio = Dio();

  // 로그인
  Future<Response> login(UserLoginModel userLoginModel) async {
    final String url = 'http://localhost:8080/api/user/log-in';

    try {
      final response = await _dio.post(
        url,
        data: userLoginModel.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      return response;
    } catch(e) {
      rethrow;
    }
  }

  // 이메일 중복 확인
  Future<Response> duplicatedEmail(UserDuplicatedEmailModel UserDuplicatedEmailModel) async {
    final String url = 'http://localhost:8080/api/user/email';

    try {
      final response = await _dio.get(
        url,
        data: UserDuplicatedEmailModel.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      return response;
    } catch(e) {
      rethrow;
    }
  }

  // 휴대폰 인증코드 발송
  Future<Response> submitPhoneCode(UserSubmitPhoneCodeModel UserSubmitPhoneCodeModel) async {
    final String url = 'http://localhost:8080/api/user/auth-code';

    try {
      final response = await _dio.post(
        url,
        data: UserSubmitPhoneCodeModel.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      return response;
    } catch(e) {
      rethrow;
    }
  }

  // 휴대폰 인증코드 확인
  Future<Response> checkPhoneCode(UserCheckPhoneCodeModel UserCheckPhoneCodeModel) async {
    final String url = 'http://localhost:8080/api/user/auth-code';

    try {
      final response = await _dio.get(
        url,
        data: UserCheckPhoneCodeModel.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      return response;
    } catch(e) {
      rethrow;
    }
  }

  // 닉네임 중복 확인
  Future<Response> duplicatedNickname(UserDuplicatedNicknameModel UserDuplicatedNicknameModel) async {
    final String url = 'http://localhost:8080/api/user/nickname';

    try {
      final response = await _dio.get(
        url,
        data: UserDuplicatedNicknameModel.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      return response;
    } catch(e) {
      rethrow;
    }
  }

  // 회원가입
  Future<Response> signup(UserSignupModel UserSignupModel) async {
    final String url = 'http://localhost:8080/api/user/sign-up';

    try {
      final response = await _dio.post(
        url,
        data: UserSignupModel.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      return response;
    } catch(e) {
      rethrow;
    }
  }
}