import 'package:flutter/material.dart';

class AlbumScreen extends StatelessWidget {
  const AlbumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('앨범 화면'),
      ),
      body: const Center(
        child: Text('여기는 앨범에서 사진을 선택하는 기능이 구현될 화면입니다.'),
      ),
    );
  }
}
