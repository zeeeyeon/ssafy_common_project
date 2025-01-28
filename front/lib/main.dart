import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/common/routes/app_router.dart';

void main() {
  // Flutter 바인딩 초기화 추가
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '끌락끌락',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: 'Pretendard',
      ),
      routerConfig: router,
      // 스플래시 화면 전에 보여질 화면 설정
      builder: (context, child) {
        return Scaffold(
          body: Container(
            color: Colors.white, // 흰색 배경으로 설정
            child: child,
          ),
        );
      },
    );
  }
}
