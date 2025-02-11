import 'package:dio/dio.dart';

import '../storage/storage.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://i12e206.p.ssafy.io', // API 서버 URL
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
        onRequest: (options, handler) async {
          // 요청 전에 토큰을 가져와서 헤더에 추가
          String? token = await Storage.getToken();
          
          if (token != null) {
            options.headers['Authorization'] = token;  // Bearer 토큰 추가
          }
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
  // 토큰을 가져오는 함수 (Riverpod 사용)
  // Future<String?> _getToken() async {
  //   // 여기서 Riverpod 상태를 읽어서 토큰을 가져옵니다.
  //   return Future.value(DioClient._instance.dio.options.headers['Authorization']);
  // }
}
