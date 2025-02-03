import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kkulkkulk/common/jwt/jwt_token_provider.dart';
import 'package:kkulkkulk/features/auth/components/text_button_form.dart';
import 'package:kkulkkulk/features/auth/components/text_form.dart';
import 'package:kkulkkulk/features/auth/data/models/user_login_model.dart';
import 'package:kkulkkulk/features/auth/view_models/auth_view_model.dart';
import 'package:kkulkkulk/features/auth/view_models/log_in_view_model.dart';
import 'package:sign_button/sign_button.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class LoginForm extends ConsumerWidget{
  final _formKey = GlobalKey<FormState>();

  void _signup(BuildContext context) {
    context.go('/register');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logInViewModel = ref.watch(logInViewModelProvider);

    void logIn() async {
      try {
        bool flag = await logInViewModel.login(context, ref);
        if(flag) {
          final token = ref.watch(jwtTokenProvider);

          String? username = '';

          if (token != null && token.isNotEmpty) {
            try {
              // 토큰을 디코딩하여 username 추출
              final decodedToken = JwtDecoder.decode(token);
              username = decodedToken['username'];
            } catch (e) {
              // 토큰 디코딩 실패시 처리
              username = null;
            }
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('환영합니다 $username 님')),
          );
          context.go('/calendar');
        }else if(!flag) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('로그인 실패')),
          );
        }
        
      } catch(e) {
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
          TextForm(
            'Email',
            logInViewModel.emailController,
          ),
          SizedBox(height: 15),
          TextForm(
            'Password',
            logInViewModel.passwordController,
          ),
          SizedBox(height: 15),
          TextButtonForm(
            '로그인',
            logIn,
          ),
          SizedBox(height: 15),
          Text(
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
          SizedBox(height: 30),
          SignInButton(
            buttonType: ButtonType.google,
            buttonSize: ButtonSize.large,
            width: double.infinity,
            onPressed: () {
              print('click');
          }),
        ],
      ),
    );
  }
}