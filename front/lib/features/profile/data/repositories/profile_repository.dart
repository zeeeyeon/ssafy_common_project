import 'package:dio/dio.dart';
import 'package:kkulkkulk/common/network/dio_client.dart';
import 'package:kkulkkulk/features/profile/data/models/profile_model.dart';
import 'package:flutter/foundation.dart'; // debugPrint 사용

class ProfileRepository {
  final DioClient _dioClient;

  ProfileRepository(this._dioClient);

  /// ✅ 사용자 프로필 데이터 가져오기
  Future<UserProfile> fetchUserProfile() async {
    debugPrint('📡 API 요청 시작: /api/user/profile');
    try {
      final response = await _dioClient.dio.get(
        '/api/user/profile',
        options: Options(
          headers: {
            'Authorization':
                'Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ0ZXN0MDFAbmF2ZXIuY29tIiwiaWF0IjoxNzM4ODkyODYzLCJleHAiOjE3Mzk0OTc2NjMsImlkIjoxLCJ1c2VybmFtZSI6InNvbmdEb25nSHllb24iLCJyb2xlIjoiVVNFUiJ9.ix-8keezfIvYp9rfSTfpnViStBKxPho4C3EDHViUfU9-17F9Y2SkHRsi9lj-10auwKmCuTTp2jM4WUtfQWz6Ig',
          },
        ),
      );

      debugPrint('✅ API 응답 받음: ${response.data}');

      if (response.data['status']['code'] == 200) {
        return UserProfile.fromJson(response.data);
      } else {
        throw Exception('API 응답 오류: ${response.data['status']['message']}');
      }
    } catch (e) {
      debugPrint('❌ API 요청 실패: $e');
      throw Exception('Failed to fetch user profile: $e');
    }
  }
}
