class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = '네트워크 연결을 확인해주세요']);
}

class ServerException implements Exception {
  final String message;
  ServerException([this.message = '서버에 문제가 발생했습니다']);
}
