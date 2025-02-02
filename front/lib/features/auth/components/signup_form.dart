import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kkulkkulk/features/auth/components/text_button_form.dart';
import 'package:kkulkkulk/features/auth/components/text_form.dart';
import 'package:kkulkkulk/features/auth/view_models/sign_up_view_model.dart';

class SignupForm extends ConsumerWidget {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signUpViewModel = ref.watch(signUpViewModelProvider);

    // 이메일 중복 확인 처리
    void duplicatedEmail() async {
      // 이메일 유효성 검사
      final emailValidationMessage = signUpViewModel.validateEmail(signUpViewModel.emailController.text);

      if (emailValidationMessage == null) {
        // 이메일 형식이 유효한 경우, 중복 체크 진행
        try {
          bool flag = await signUpViewModel.duplicatedEmail();
          if (flag) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(signUpViewModel.successMessage)),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(signUpViewModel.errorMessage)),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('이메일 중복 확인 실패')),
          );
        }
      } else {
        // 이메일 유효성 검사 실패 시, 해당 메시지를 SnackBar에 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(emailValidationMessage)),
        );
      }
    }


    // 닉네임 중복 확인 처리
    void duplicatedNickname() async {
      // 닉네임 유효성 검사
      final nicknameValidationMessage = signUpViewModel.validateNickname(signUpViewModel.nicknameController.text);

      if (nicknameValidationMessage == null) {
        // 닉네임 형식이 유효한 경우, 중복 체크 진행
        try {
          bool flag = await signUpViewModel.duplicatedNickname();
          if (flag) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(signUpViewModel.successMessage)),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(signUpViewModel.errorMessage)),
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
      if (signUpViewModel.validateInputs()) {
        try {
          await signUpViewModel.signUp();
          // 회원가입 성공 처리
          // 예: 회원가입 완료 후 다른 화면으로 이동
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('회원가입 성공')),
          );
          // 회원가입 후 로그인 페이지로 이동
          context.go('/login');
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
                      duplicatedEmail,
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
          ),
        ],
      ),
    );
  }
  
}