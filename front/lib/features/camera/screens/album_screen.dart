import 'package:flutter/material.dart';
import 'package:kkulkkulk/common/widgets/layout/custom_app_bar.dart';
import 'package:go_router/go_router.dart';

class AlbumScreen extends StatelessWidget {
  const AlbumScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // CustomAppBar를 이용해 다른 화면과 동일한 네비게이션바를 출력
      appBar: CustomAppBar(
        title: '앨범',
        showBackButton: true, // 뒤로가기 버튼 표시 여부 (필요에 따라 설정)
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt_rounded),
            iconSize: 30,
            onPressed: () {
              context.go('/camera');
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          '앨범 화면 내용',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
    );
  }
}
