import 'package:flutter/material.dart';
import 'package:kkulkkulk/common/widgets/layout/custom_app_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: '프로필'),
      body: Center(
        child: Text('Profile Screen'),
      ),
    );
  }
}
