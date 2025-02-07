import 'package:dio/dio.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;

  // 🔥 Postman에서 받은 Access Token 직접 입력!
  final String accessToken =
      "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ0ZXN0MDFAbmF2ZXIuY29tIiwiaWF0IjoxNzM4ODkyODYzLCJleHAiOjE3Mzk0OTc2NjMsImlkIjoxLCJ1c2VybmFtZSI6InNvbmdEb25nSHllb24iLCJyb2xlIjoiVVNFUiJ9.ix-8keezfIvYp9rfSTfpnViStBKxPho4C3EDHViUfU9-17F9Y2SkHRsi9lj-10auwKmCuTTp2jM4WUtfQWz6Ig"; // 여기 직접 입력!

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://i12e206.p.ssafy.io', // API 서버 URL
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 인터셉터 설정
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // 요청 전 처리
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // 응답 처리
          return handler.next(response);
        },
        onError: (error, handler) {
          // 에러 처리
          return handler.next(error);
        },
      ),
    );
  }
}
