import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:kkulkkulk/common/storage/storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 위젯 빌드가 끝난 뒤에 화면 전환 로직 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateAfterDelay();
    });
  }

  /// 3초 후 토큰 검사 -> 로그인 or 메인화면
  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 3));
    final token = await Storage.getToken();
    if (!mounted) return;
    if (token == null) {
      context.push('/login');
    } else {
      final decodedToken = JwtDecoder.decode(token.replaceAll("Bearer", ""));
      context.push('/calendar');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('환영합니다 ${decodedToken['username']} 님')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // GIF 파일을 화면 너비의 95% 및 높이의 50% 크기로 크게 표시
              SizedBox(
                width: 390,
                height: 390,
                child: Image.asset(
                  'assets/splash/splashMain-unscreen.gif',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 0),
              // "끌락"과 "끌락"을 따로 애니메이션을 적용하여 Row로 배치
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  BouncyText(
                    text: '끌락',
                    delay: Duration(milliseconds: 0),
                  ),
                  SizedBox(width: 8),
                  BouncyText(
                    text: '끌락',
                    delay: Duration(milliseconds: 300),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Color.fromARGB(255, 248, 139, 5)),
                strokeWidth: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BouncyText extends StatefulWidget {
  final String text;
  final Duration delay;
  const BouncyText({super.key, required this.text, this.delay = Duration.zero});

  @override
  State<BouncyText> createState() => _BouncyTextState();
}

class _BouncyTextState extends State<BouncyText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_controller);
    // delay를 준 후 애니메이션 반복 시작
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Text(
        widget.text,
        style: const TextStyle(
          fontSize: 42,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 248, 139, 5),
        ),
      ),
    );
  }
}
