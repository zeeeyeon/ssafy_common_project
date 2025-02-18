import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_template.dart';
import 'package:kkulkkulk/common/notification/notification.dart';
import 'package:kkulkkulk/common/routes/app_router.dart';

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  // String kakaoNativeAppKey = dotenv.env['KAKAO_NATIVE_APP_KEY'] ?? '';
  print('kakaoNativeAppKey: ${dotenv.get('KAKAO_NATIVE_APP_KEY')}');
  KakaoSdk.init(
    nativeAppKey: dotenv.get('KAKAO_NATIVE_APP_KEY'),
  );
  await NotificationService().initialize();
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
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', ''), // 한국어
        Locale('en', ''), // 영어
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: 'Pretendard',
      ),
      builder: (context, child) {
        return Scaffold(
          body: Container(
            color: Colors.white,
            child: child,
          ),
        );
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
