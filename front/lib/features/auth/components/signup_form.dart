import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/features/auth/components/text_button_form.dart';
import 'package:kkulkkulk/features/auth/components/text_form.dart';
import 'package:kkulkkulk/features/auth/view_models/sign_up_view_model.dart';

class SignupForm extends ConsumerWidget {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();

  void _duplicatedEmail() {
    String email = _emailController.text;
    print('이메일 중복 확인 버튼 클릭');
    print('email: $email');
  }

  void _duplicatedNickname() {
    String nickname = _nicknameController.text;
    print('닉네임 중복 확인 버튼 클릭');
    print('nickname: $nickname');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signUpViewModel = ref.watch(signUpViewModelProvider);
    final isLoading = signUpViewModel.isLoading;
    final errorMessage = signUpViewModel.errorMessage;

    // 회원가입 처리
    void signUp() async {
      print('회원가입 시작');
      if (signUpViewModel.validateInputs()) {
        try {
          await signUpViewModel.signUp();
          // 회원가입 성공 처리
          // 예: 회원가입 완료 후 다른 화면으로 이동
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('회원가입 성공')),
          );
        } catch (e) {
          // 실패 시 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('회원가입 실패')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('입력값을 확인해주세요')),
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
              Row(
                children: [
                  Flexible(
                    flex: 8, 
                    child: TextForm(
                      'Email',
                      signUpViewModel.emailController,
                      validator: signUpViewModel.validateEmail,
                    ),
                  ),
                  SizedBox(width: 10),  // 간격을 두기 위해 SizedBox 추가
                  Flexible(
                    flex: 2, 
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
                signUpViewModel.passwordController,
                validator: signUpViewModel.validatePassword,
                isPassword: true,
              ),
              SizedBox(height: 16),
              TextForm(
                'Password 다시',
                signUpViewModel.checkPasswordController,
                validator: signUpViewModel.validateCheckPassword,
                isPassword: true,
              ),
              SizedBox(height: 16),
              TextForm(
                '이름',
                signUpViewModel.usernameController,
                validator: signUpViewModel.validateUsername,
              ),
              SizedBox(height: 16),
              TextForm(
                '전화번호',
                signUpViewModel.phoneController,
                validator: signUpViewModel.validatePhone,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Flexible(
                    flex: 8,  
                    child: TextForm(
                      '닉네임',
                      signUpViewModel.nicknameController,
                      validator: signUpViewModel.validateUsername,
                    ),
                  ),
                  SizedBox(width: 10),
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
                signUp,
              )
            ],
          ),
        ],
      ),
    );
  }
  
}