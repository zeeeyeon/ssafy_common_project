import 'package:dio/dio.dart';
import 'package:kkulkkulk/common/network/dio_client.dart';
import 'package:kkulkkulk/features/auth/data/models/user_check_phone_code_model.dart';
import 'package:kkulkkulk/features/auth/data/models/user_duplicated_email_model.dart';
import 'package:kkulkkulk/features/auth/data/models/user_duplicated_nickname_model.dart';
import 'package:kkulkkulk/features/auth/data/models/user_login_model.dart';
import 'package:kkulkkulk/features/auth/data/models/user_signup_model.dart';
import 'package:kkulkkulk/features/auth/data/models/user_submit_phone_code_model.dart';

class AuthRepository {
  final Dio _dio = DioClient().dio;

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
  Future<Response> duplicatedEmail(String email) async {
    try {
      final response = await _dio.get(
        '/user/email-check',
        queryParameters: {'email' : email},
      );
      return response;
    } catch(e) {
      rethrow;
    }
  }

  // 닉네임 중복 확인
  Future<Response> duplicatedNickname(String nickname) async {
    try {
      final response = await _dio.get(
        '/user/nickname-check',
        queryParameters: {'nickname' : nickname},
      );
      return response;
    } catch(e) {
      rethrow;
    }
  }

  // 회원가입
  Future<Response> signup(UserSignupModel userSignupModel) async {
    try {
      final response = await _dio.post(
        '/user/sign-up',
        data: userSignupModel.toJson(),
      );
      return response;
    } catch(e) {
      print(e);
      rethrow;
    }
  }
}