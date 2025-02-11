import 'package:dio/dio.dart';
import 'package:kkulkkulk/common/network/dio_client.dart';
import 'package:kkulkkulk/features/profile/data/models/profile_model.dart';

class ProfileRepository {
  final DioClient _dioClient;

  ProfileRepository(this._dioClient);

  Future<UserProfile> fetchUserProfile() async {
    print('🔥 fetchUserProfile 실행됨');
    try {
      print('📡 API 요청 시작: /api/user/profile'); // 요청이 시작되는지 확인

      final response = await _dioClient.dio.get(
        '/api/user/profile',
        options: Options(
          headers: {
            'Authorization':
                'Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ0ZXN0MDFAbmF2ZXIuY29tIiwiaWF0IjoxNzM4ODkyODYzLCJleHAiOjE3Mzk0OTc2NjMsImlkIjoxLCJ1c2VybmFtZSI6InNvbmdEb25nSHllb24iLCJyb2xlIjoiVVNFUiJ9.ix-8keezfIvYp9rfSTfpnViStBKxPho4C3EDHViUfU9-17F9Y2SkHRsi9lj-10auwKmCuTTp2jM4WUtfQWz6Ig',
          },
        ),
      );

      print('✅ API 응답 데이터: ${response.data}'); // API 응답 확인
      return UserProfile.fromJson(response.data['content']);
    } catch (e) {
      print('❌ API 요청 실패: $e');
      throw Exception('Failed to load profile data: $e');
    }
  }
}
