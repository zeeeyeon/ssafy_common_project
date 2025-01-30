import 'package:dio/dio.dart';

class DioClient {
  static Dio? _instance;
  static const String baseUrl = 'YOUR_BASE_URL';

  static Dio getInstance() {
    if (_instance == null) {
      _instance = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 3),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (const bool.fromEnvironment('dart.vm.product') == false) {
        _instance!.interceptors.add(LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
        ));
      }
    }

    return _instance!;
  }
}
