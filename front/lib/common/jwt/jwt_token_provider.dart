import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

// 토큰을 관리할 Provider
final jwtTokenProvider = StateProvider<String?>((ref) => null);

// 토큰 만료 여부 확인하는 Provider
final isTokenExpiredProvider = Provider<bool>((ref) {
  final token = ref.watch(jwtTokenProvider);
  if (token == null) return true;
  return false;  // 토큰 만료 여부 확인 로직 추가 가능
});

// 토큰 디코딩 하는 Provider
final decodedTokenProvider = Provider<Map<String, dynamic>?>((ref) {
  final token = ref.watch(jwtTokenProvider);
  if (token == null) return null;

  try {
    final decodedToken = JwtDecoder.decode(token);
    return decodedToken;
  } catch (e) {
    return null;
  }
});
