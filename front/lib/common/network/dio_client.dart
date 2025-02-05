import 'package:dio/dio.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://192.168.30.158:8080', // API 서버 URL
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
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
