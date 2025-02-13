import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../storage/storage.dart';

final logger = Logger();

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
          logger.d("Retrieved token: $token"); // 토큰 출력
          if (token != null) {
            options.headers['Authorization'] = token; // Bearer 토큰 추가
          }

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

// Provider 정의
final dioClientProvider = Provider<DioClient>((ref) => DioClient());
