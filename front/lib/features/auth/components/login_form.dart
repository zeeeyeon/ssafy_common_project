import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_talk.dart';
import 'package:kkulkkulk/common/jwt/jwt_token_provider.dart';
import 'package:kkulkkulk/features/auth/components/oauth_signup_form.dart';
import 'package:kkulkkulk/features/auth/components/text_button_form.dart';
import 'package:kkulkkulk/features/auth/components/text_form.dart';
import 'package:kkulkkulk/features/auth/screens/kakao_login_screen.dart';
import 'package:kkulkkulk/features/auth/screens/oauth_register_screen.dart';
import 'package:kkulkkulk/features/auth/view_models/log_in_view_model.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/features/profile/view_models/profile_view_model.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginForm extends ConsumerWidget {
  final _formKey = GlobalKey<FormState>();
  final logger = Logger();
  // final viewModel = MainViewModel(KakaoLogin());
  
  LoginForm({super.key});
  
  get http => null;
  // final AuthRepository _authRepository = AuthRepository();

  void _signup(BuildContext context) {
    context.go('/register');
  }

  


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logInViewModel = ref.watch(logInViewModelProvider);
    
    
    void logIn() async {
      print('로그인 시작');
      try {
        bool flag = await logInViewModel.login(context, ref);
        if (flag) {
          final token = ref.watch(jwtTokenProvider);

          String? username = '';

          if (token != null && token.isNotEmpty) {
            try {
              // 토큰을 디코딩하여 username 추출
              final decodedToken = JwtDecoder.decode(token);
              print('decodedToken: $decodedToken');
              username = decodedToken['username'];
            } catch (e) {
              // 토큰 디코딩 실패시 처리
              username = null;
            }
          }

          ref.invalidate(profileProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('환영합니다 $username 님')),
          );
          logInViewModel.emailController.clear();
          logInViewModel.passwordController.clear();
          context.go('/calendar');
        } else if (!flag) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('로그인 실패')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 에러 발생')),
        );
      }
    }

    
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset('assets/rock/rockrock.gif'),
          TextForm(
            'Email',
            logInViewModel.emailController,
          ),
          const SizedBox(height: 15),
          TextForm(
            'Password',
            logInViewModel.passwordController,
            isPassword: true,
          ),
          const SizedBox(height: 15),
          TextButtonForm(
            '로그인',
            logIn,
          ),
          const SizedBox(height: 15),
          const Text(
            '계정이 없으신가요?',
            style: TextStyle(
              color: Color(0xFF2C3540),
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButtonForm(
            '회원가입',
            () => _signup(context),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                logger.i("카카오 로그인 시작");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => KakaoLoginScreen()),
                );


              //   try {
              //   OAuthToken result = await UserApi.instance.loginWithKakaoAccount();
            
              //   // 타입 확인 후, 적절한 처리
              //   if (result is OAuthToken) {
              //     final token = result;
              //     logger.i("카카오계정으로 로그인 성공 ${token.accessToken}");
                  
              //     final accessToken = token.accessToken;  
              //     logger.i("Access Token: $accessToken");
                  
              //     ref.read(accessTokenProvider.notifier).state = accessToken;
                  
              //     if (accessToken.isEmpty) {
              //       logger.i("Access Token이 없습니다.");
              //     } else {
              //       logger.i("Access Token이 있습니다.");
              //     }
                  
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => const OauthRegisterScreen(),
              //       ),
              //     );
              //   } else {
              //     logger.e("예상치 못한 반환값: $result");
              //   }
              // } catch (e) {
              //   logger.e("카카오 로그인 실패: $e");
              // }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFEE00),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/oauth/kakao_logo.png',
                    width: 24,
                    height: 24,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0), // 이미지와 텍스트 간격 조정
                    child: Text(
                      '카카오 로그인',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
