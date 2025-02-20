import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:kkulkkulk/common/jwt/jwt_token_provider.dart';
import 'package:kkulkkulk/features/auth/components/text_button_form.dart';
import 'package:kkulkkulk/features/auth/components/text_form.dart';
import 'package:kkulkkulk/features/auth/view_models/oauth_sign_up_view_model.dart';
import 'package:kkulkkulk/features/auth/view_models/sign_up_view_model.dart';

class OauthSignupForm extends ConsumerWidget {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final oauthSignUpViewModel = ref.watch(OauthSignUpViewModelProvider);

// 닉네임 중복 확인 처리
    void duplicatedNickname() async {
      print('시작');
      // 닉네임 유효성 검사
      final nicknameValidationMessage = oauthSignUpViewModel
          .validateNickname(oauthSignUpViewModel.nicknameController.text);
      print(oauthSignUpViewModel.nicknameController.text);
      if (nicknameValidationMessage == null) {
        // 닉네임 형식이 유효한 경우, 중복 체크 진행
        try {
          bool flag = await oauthSignUpViewModel.duplicatedNickname();
          if (flag) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(oauthSignUpViewModel.successMessage)),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              // SnackBar(content: Text(oauthSignUpViewModel.errorMessage)),
              SnackBar(content: Text('닉네임 중복')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('닉네임 중복 확인 실패')),
          );
        }
      } else {
        // 닉네임 유효성 검사 실패 시, 해당 메시지를 SnackBar에 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(nicknameValidationMessage)),
        );
      }
    }

    // 회원가입 처리
    void signUp() async {
      print('카카오 로그인 회원 전환');
      try {
        bool flag = await oauthSignUpViewModel.login(context, ref);
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('환영합니다 $username 님')),
            );
            oauthSignUpViewModel.passwordController.clear();
            oauthSignUpViewModel.checkPasswordController.clear();
            oauthSignUpViewModel.phoneController.clear();
            oauthSignUpViewModel.nicknameController.clear();
            oauthSignUpViewModel.usernameController.clear();
            context.go('/calendar');
          } else if (!flag) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('로그인 실패')),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 에러 발생')),
        );
      }
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              TextForm(
                'Password',
                oauthSignUpViewModel.passwordController,
                validator: oauthSignUpViewModel.validatePassword,
                isPassword: true,
              ),
              SizedBox(height: 16),
              TextForm(
                'Password 다시',
                oauthSignUpViewModel.checkPasswordController,
                validator: oauthSignUpViewModel.validateCheckPassword,
                isPassword: true,
              ),
              SizedBox(height: 16),
              TextForm(
                '이름',
                oauthSignUpViewModel.usernameController,
                validator: oauthSignUpViewModel.validateUsername,
              ),
              SizedBox(height: 16),
              TextForm(
                '전화번호',
                oauthSignUpViewModel.phoneController,
                validator: oauthSignUpViewModel.validatePhone,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Flexible(
                    flex: 8,
                    child: TextForm(
                      '닉네임',
                      oauthSignUpViewModel.nicknameController,
                      validator: oauthSignUpViewModel.validateUsername,
                    ),
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    flex: 2, // 9:1 비율로 크기 조정
                    child: TextButtonForm(
                      '중복확인',
                      duplicatedNickname,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextButtonForm(
                '회원가입',
                signUp,
              )
            ],
          )
        ],
      ),
    );
  }
}
