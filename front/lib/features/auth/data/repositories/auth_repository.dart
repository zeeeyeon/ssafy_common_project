import 'package:dio/dio.dart';
import 'package:kkulkkulk/common/network/dio_client.dart';
import 'package:kkulkkulk/features/auth/data/models/translate_social_to_user_model.dart';
import 'package:kkulkkulk/features/auth/data/models/user_login_model.dart';
import 'package:kkulkkulk/features/auth/data/models/user_signup_model.dart';

class AuthRepository {
  final Dio _dio = DioClient().dio;

  // 로그인
  Future<Response> login(UserLoginModel userLoginModel) async {
    try {
      final response = await _dio.post(
        '/api/user/login',
        data: userLoginModel.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      return response;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  // 연동 로그인
  Future<Response> kakaoLogin() async {
    print('api 호출');
    try {
      final response = await _dio.get(
        '/api/user/social/kakao/login',
      );
      print(response);
      return response;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  // 소셜 사용자에서 일반 사요자로 전환
  Future<Response> translateSocialToUser(
      TranslateSocialToUserModel translateSocialToUserModel) async {
    try {
      final response = await _dio.post(
        '/api/user/social/kakao/complete-signup',
        data: translateSocialToUserModel.toJson(),
      );
      return response;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  // 이메일 중복 확인
  Future<Response> duplicatedEmail(String email) async {
    try {
      final response = await _dio.get(
        '/api/user/email-check',
        queryParameters: {'email': email},
      );
      return response;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  // 닉네임 중복 확인
  Future<Response> duplicatedNickname(String nickname) async {
    try {
      final response = await _dio.get(
        '/api/user/nickname-check',
        queryParameters: {'nickname': nickname},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // 회원가입
  Future<Response> signup(UserSignupModel userSignupModel) async {
    try {
      final response = await _dio.post(
        '/api/user/signup',
        data: userSignupModel.toJson(),
      );
      return response;
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
