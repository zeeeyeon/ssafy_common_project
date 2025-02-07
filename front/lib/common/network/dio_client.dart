// import 'package:dio/dio.dart';

// class DioClient {
//   static final DioClient _instance = DioClient._internal();
//   late final Dio dio;

//   factory DioClient() {
//     return _instance;
//   }

//   DioClient._internal() {
//     dio = Dio(
//       BaseOptions(
//         baseUrl: 'https://i12e206.p.ssafy.io/', // API 서버 URL
//         connectTimeout: const Duration(seconds: 5),
//         receiveTimeout: const Duration(seconds: 3),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       ),
//     );

//     // 인터셉터 설정
//     dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) {
//           // 요청 전 처리
//           return handler.next(options);
//         },
//         onResponse: (response, handler) {
//           // 응답 처리
//           return handler.next(response);
//         },
//         onError: (error, handler) {
//           // 에러 처리
//           return handler.next(error);
//         },
//       ),
//     );
//   }
// }

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
        baseUrl: 'https://i12e206.p.ssafy.io', // API 기본 URL
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }
}
