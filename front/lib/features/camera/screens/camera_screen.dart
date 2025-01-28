import 'package:flutter/material.dart';
import 'package:kkulkkulk/common/widgets/layout/custom_app_bar.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: '운동 촬영'),
      body: Center(
        child: Text('Camera Screen'),
      ),
    );
  }
}
