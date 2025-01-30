import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kkulkkulk/features/auth/components/text_button_form.dart';
import 'package:kkulkkulk/features/auth/components/text_form.dart';
import 'package:kkulkkulk/features/auth/data/models/user_login_model.dart';
import 'package:kkulkkulk/features/auth/view_models/auth_view_model.dart';

class LoginForm extends StatelessWidget{
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    String email = _emailController.text;
    String password = _passwordController.text;
    print('email: $email password: $password');

    // if(_formKey.currentState!.validate()) {
      
    // }
  }

  void _signup(BuildContext context) {
    context.go('/register');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextForm(
            'Email',
            _emailController,
          ),
          SizedBox(height: 15),
          TextForm(
            'Password',
            _passwordController,
          ),
          SizedBox(height: 15),
          TextButtonForm(
            '로그인',
            _login,
          ),
          SizedBox(height: 15),
          Text(
            '계정이 없으신가요?',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButtonForm(
            '회원가입',
            () => _signup(context),
          ),
          SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {}, 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Image.asset(
                  //   'assets/oauth/kakao_logo.png',
                  //   width: 24,
                  //   height: 24,
                  // ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0), // 이미지와 텍스트 간격 조정
                    child: Text(
                      '카카오 로그인',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFEE00),
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {}, 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Image.asset(
                  //   'assets/oauth/kakao_logo.png',
                  //   width: 24,
                  //   height: 24,
                  // ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0), // 이미지와 텍스트 간격 조정
                    child: Text(
                      '네이버 로그인',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2DB400),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {}, 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Image.asset(
                  //   'assets/oauth/kakao_logo.png',
                  //   width: 24,
                  //   height: 24,
                  // ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0), // 이미지와 텍스트 간격 조정
                    child: Text(
                      '네이버 로그인',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}