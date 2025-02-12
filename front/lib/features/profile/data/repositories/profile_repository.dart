import 'package:dio/dio.dart';
import 'package:kkulkkulk/common/network/dio_client.dart';
import 'package:kkulkkulk/features/profile/data/models/profile_model.dart';
import 'package:flutter/foundation.dart'; // debugPrint 사용

class ProfileRepository {
  final DioClient _dioClient;

  ProfileRepository(this._dioClient);

  /// ✅ 사용자 프로필 데이터 가져오기
  Future<UserProfile> fetchUserProfile() async {
    debugPrint('📡 [ProfileRepository] API 요청 시작: /api/user/profile');
    try {
      final response = await _dioClient.dio.get(
        '/api/user/profile',
        options: Options(headers: _authHeaders),
      );

      debugPrint('✅ [ProfileRepository] API 응답 받음: ${response.data}');

      final status = response.data['status'];
      if (status != null && status['code'] == 200) {
        return UserProfile.fromJson(response.data);
      } else {
        throw Exception('API 응답 오류: ${status?['message'] ?? '알 수 없는 오류'}');
      }
    } catch (e) {
      debugPrint('❌ [ProfileRepository] API 요청 실패: $e');
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  /// ✅ 프로필 정보 수정 (PUT 요청)
  Future<void> updateUserProfile(UserProfile updatedProfile) async {
    debugPrint('📡 [ProfileRepository] API 요청 시작: /api/user/profile (PUT)');
    try {
      final response = await _dioClient.dio.put(
        '/api/user/profile',
        data: updatedProfile.toJson(),
        options: Options(headers: _authHeaders),
      );

      debugPrint('✅ [ProfileRepository] 프로필 업데이트 완료: ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ [ProfileRepository] 프로필 업데이트 실패: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  /// ✅ 공통 인증 헤더 (Bearer Token)
  Map<String, String> get _authHeaders => {
        'Authorization':
            'Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ0ZXN0MDFAbmF2ZXIuY29tIiwiaWF0IjoxNzM4ODkyODYzLCJleHAiOjE3Mzk0OTc2NjMsImlkIjoxLCJ1c2VybmFtZSI6InNvbmdEb25nSHllb24iLCJyb2xlIjoiVVNFUiJ9.ix-8keezfIvYp9rfSTfpnViStBKxPho4C3EDHViUfU9-17F9Y2SkHRsi9lj-10auwKmCuTTp2jM4WUtfQWz6Ig',
      };
}
