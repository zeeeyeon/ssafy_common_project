import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

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
        baseUrl: 'https://i12e206.p.ssafy.io',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization':
              'Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ0ZXN0MDFAbmF2ZXIuY29tIiwiaWF0IjoxNzM5Mjc5MDk0LCJleHAiOjE3Mzk4ODM4OTQsImlkIjoxLCJ1c2VybmFtZSI6IuyGoeuPme2YhCJ9.dJMmkMnmXZrordCAkg8gcQDBk8jRkY-xIMDrZq7kmGla6uVgE-AcwCJE8d5Gef-BVW_KzePY9rlIyvLF2U-pHA',
        },
      ),
    );

    // 인터셉터 설정
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 요청 전에 토큰을 가져와서 헤더에 추가
          String? token = await _getToken();

          if (token != null) {
            options.headers['Authorization'] = token; // Bearer 토큰 추가
          }
          logger.d('API 요청', {
            'url': '${options.baseUrl}${options.path}',
            'method': options.method,
            'headers': options.headers,
            'data': options.data,
          });
          return handler.next(options);
        },
        onResponse: (response, handler) {
          logger.d('API 응답', {
            'statusCode': response.statusCode,
            'data': response.data,
          });
          return handler.next(response);
        },
        onError: (error, handler) {
          logger.e('API 에러', error.message, error.stackTrace);
          return handler.next(error);
        },
      ),
    );
  }

  // 토큰을 가져오는 함수 (Riverpod 사용)
  Future<String?> _getToken() async {
    // 여기서 Riverpod 상태를 읽어서 토큰을 가져옵니다.
    return Future.value(
        DioClient._instance.dio.options.headers['Authorization']);
  }
}

// Provider 정의
final dioClientProvider = Provider<DioClient>((ref) => DioClient());
