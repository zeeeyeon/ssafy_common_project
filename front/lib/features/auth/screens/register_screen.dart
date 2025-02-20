import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kkulkkulk/common/widgets/layout/custom_app_bar.dart';
import 'package:kkulkkulk/features/auth/components/signup_form.dart';
import 'package:kkulkkulk/features/auth/view_models/log_in_view_model.dart';
import 'package:kkulkkulk/features/auth/view_models/sign_up_view_model.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signUpViewModel = ref.watch(signUpViewModelProvider);
    final logInViewModel = ref.watch(logInViewModelProvider);
    return Scaffold(
      appBar: CustomAppBar(
        title: '회원가입',
        showBackButton: true,
        onBackPressed: () {
          logInViewModel.emailController.clear();
          logInViewModel.passwordController.clear();

          signUpViewModel.emailController.clear();
          signUpViewModel.passwordController.clear();
          signUpViewModel.checkPasswordController.clear();
          signUpViewModel.usernameController.clear();
          signUpViewModel.phoneController.clear();
          signUpViewModel.nicknameController.clear();
          context.go('/login');
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(
              height: 16,
            ),
            SignupForm(),
          ],
        ),
      ),
    );
  }
}
