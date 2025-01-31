import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kkulkkulk/features/auth/components/text_button_form.dart';
import 'package:kkulkkulk/features/auth/components/text_form.dart';
import 'package:kkulkkulk/features/auth/data/models/user_login_model.dart';
import 'package:kkulkkulk/features/auth/view_models/auth_view_model.dart';
import 'package:sign_button/sign_button.dart';
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