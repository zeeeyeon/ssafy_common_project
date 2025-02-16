import 'package:flutter/material.dart';
import 'package:kkulkkulk/common/widgets/layout/custom_app_bar.dart';
import 'package:kkulkkulk/features/auth/components/oauth_signup_form.dart';

class OauthRegisterScreen extends StatelessWidget {
  const OauthRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: '카카오 로그인 회원 전환',
        showBackButton: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            OauthSignupForm(),
          ],
        ),
      ),
    );
  }
}
