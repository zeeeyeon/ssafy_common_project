import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';  // Riverpod 임포트
import 'package:http/http.dart' as http;
import 'package:kkulkkulk/features/auth/screens/oauth_register_screen.dart';
import 'package:logger/logger.dart';
import 'package:kkulkkulk/common/jwt/jwt_token_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class KakaoLoginScreen extends ConsumerStatefulWidget {  // ConsumerStatefulWidget으로 변경
  @override
  _KakaoLoginScreenState createState() => _KakaoLoginScreenState();
}

class _KakaoLoginScreenState extends ConsumerState<KakaoLoginScreen> {
  final logger = Logger();
  late WebViewController _controller;

  // 카카오 로그인 후 토큰을 처리하는 함수
  Future<void> handleLoginResponse(String url) async {
    final String clientId = dotenv.get('KAKAO_REST_API_KEY');
    final String redirectUri = dotenv.get('REDIRECT_URI');
    
    // 인증 코드가 포함된 URL이 리디렉션되면 이를 처리
    if (url.contains('code=')) {
      final code = Uri.parse(url).queryParameters['code'];
      logger.i("code 는 $code");
      logger.i("clientId 는 $clientId");
      logger.i("redirectUri 는 $redirectUri");

      if (code == null) {
        logger.e('Error: Authorization code is null.');
        return;
      }

      // 토큰 요청
      final tokenUrl = Uri.parse('https://kauth.kakao.com/oauth/token');
      
      // 요청 본문을 application/x-www-form-urlencoded 형식으로 변환
      final body = {
        'grant_type': 'authorization_code',
        'client_id': clientId,
        'redirect_uri': redirectUri,
        'code': code,
      };

      // URL-encoded 변환
      final encodedBody = body.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await http.post(
        tokenUrl,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8',
        },
        body: encodedBody,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        logger.i('카카오 로그인 성공');
        logger.i('data: $data');
        final accessToken = data['access_token'];
        final refreshToken = data['refresh_token'];

        // AccessToken을 Riverpod provider에 저장
        if (accessToken != null) {
          logger.i('카카오 로그인 성공: $accessToken');
          // 상태 관리 provider에 accessToken 값 저장
          ref.read(accessTokenProvider.notifier).state = accessToken; // 이 부분이 추가된 코드
          // 여기서 토큰을 사용하여 API 호출하거나 추가 처리 가능
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const OauthRegisterScreen(),
            ),
          );
        }
      } else {
        logger.e('카카오 로그인 실패: ${response.body}');
      }
    } else {
      logger.e('인증 코드가 URL에 포함되어 있지 않음');
    }
  }

  // 카카오 로그인 URL을 웹뷰에 로드하는 함수
  void _loadKakaoLoginUrl() {
    final String clientId = dotenv.get('KAKAO_REST_API_KEY');
    final String redirectUri = dotenv.get('REDIRECT_URI');
    final kakaoLoginUrl = Uri.parse(
        'https://kauth.kakao.com/oauth/authorize?client_id=$clientId&redirect_uri=$redirectUri&response_type=code');
    
    _controller.loadRequest(Uri.parse(kakaoLoginUrl.toString())); // loadRequest()로 수정
  }

  @override
  void initState() {
    super.initState();
    WebViewController webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.contains('code=')) {
            handleLoginResponse(request.url);
            Navigator.pop(context);  // 로그인 완료 후 화면 닫기
            return NavigationDecision.prevent;  // 리디렉션된 URL 처리 후 더 이상 웹뷰에서 로딩하지 않음
          }
          return NavigationDecision.navigate;
        },
      ));
    _controller = webViewController;

    _loadKakaoLoginUrl();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('카카오 로그인'),
      ),
      body: WebViewWidget(controller: _controller),  // WebViewWidget 사용
    );
  }
}
