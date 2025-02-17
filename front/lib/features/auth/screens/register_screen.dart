import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kkulkkulk/common/widgets/layout/custom_app_bar.dart';
import 'package:kkulkkulk/features/auth/components/signup_form.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '회원가입',
        showBackButton: true,
        onBackPressed: () => context.go('/login'),
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
