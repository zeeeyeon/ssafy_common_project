import 'package:flutter/material.dart';
import 'package:kkulkkulk/features/auth/components/text_button_form.dart';
import 'package:kkulkkulk/features/auth/components/text_form.dart';

class SignupForm extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _checkPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _telController = TextEditingController();
  final TextEditingController _authCodeController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();

  void _duplicatedEmail() {
    String email = _emailController.text;
    print('이메일 중복 확인 버튼 클릭');
    print('email: $email');
  }

  void _submitCode() {
    String tel = _telController.text;
    print('전송 버튼 클릭');
    print('tel: $tel');
  }

  void _checkTelCode() {
    String authCode = _authCodeController.text;
    print('전화번호 인증 코드 버튼 클릭');
  }

  void _duplicatedNickname() {
    String nickname = _nicknameController.text;
    print('닉네임 중복 확인 버튼 클릭');
    print('nickname: $nickname');
  }

  void _signup() {
    String email = _emailController.text;
    String password = _passwordController.text;
    String name = _nameController.text;
    String tel = _telController.text;
    String nickname = _nicknameController.text;
    print('email : $email / password: $password / name: $name / tel: $tel / nickname: $nickname');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Row(
                children: [
                  Flexible(
                    flex: 8,  // 9:1 비율로 크기 조정
                    child: TextForm(
                      'Email',
                      _emailController,
                    ),
                  ),
                  SizedBox(width: 10),  // 간격을 두기 위해 SizedBox 추가
                  Flexible(
                    flex: 2,  // 9:1 비율로 크기 조정
                    child: TextButtonForm(
                      '중복확인',
                      _duplicatedEmail,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextForm(
                'Password',
                _passwordController
              ),
              SizedBox(height: 16),
              TextForm(
                'Password 다시',
                _checkPasswordController
              ),
              SizedBox(height: 16),
              TextForm(
                '이름',
                _nameController
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Flexible(
                    flex: 8,  // 9:1 비율로 크기 조정
                    child: TextForm(
                      '전화번호',
                      _telController,
                    ),
                  ),
                  SizedBox(width: 10),  // 간격을 두기 위해 SizedBox 추가
                  Flexible(
                    flex: 2,  // 9:1 비율로 크기 조정
                    child: TextButtonForm(
                      '전송',
                      _submitCode,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Flexible(
                    flex: 8,  // 9:1 비율로 크기 조정
                    child: TextForm(
                      '해당 전화번호로 발송된 코드',
                      _authCodeController,
                    ),
                  ),
                  SizedBox(width: 10),  // 간격을 두기 위해 SizedBox 추가
                  Flexible(
                    flex: 2,  // 9:1 비율로 크기 조정
                    child: TextButtonForm(
                      '확인',
                      _checkTelCode,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Flexible(
                    flex: 8,  // 9:1 비율로 크기 조정
                    child: TextForm(
                      '닉네임',
                      _nicknameController,
                    ),
                  ),
                  SizedBox(width: 10),  // 간격을 두기 위해 SizedBox 추가
                  Flexible(
                    flex: 2,  // 9:1 비율로 크기 조정
                    child: TextButtonForm(
                      '중복확인',
                      _duplicatedNickname,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextButtonForm(
                '회원가입',
                _signup
              )
            ],
          ),
        ],
      ),
    );
  }
  
}