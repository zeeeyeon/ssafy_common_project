import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DioClient {
  final Dio dio;

  DioClient({required String baseUrl, required String? token})
      : dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 3),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
          ),
        ) {
    // 인터셉터 설정
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );
  }
}

// 🔥 Riverpod Provider 추가 ✅
final dioClientProvider = Provider<DioClient>((ref) {
  final token = ref.watch(authTokenProvider); // 토큰 상태 감시
  return DioClient(
    baseUrl: 'https://i12e206.p.ssafy.io/api',
    token: token,
  );
});

// 🔥 토큰 상태 관리 Provider ✅
final authTokenProvider = StateProvider<String?>((ref) => null);
