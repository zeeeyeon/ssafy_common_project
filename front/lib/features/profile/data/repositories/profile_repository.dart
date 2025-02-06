import 'package:dio/dio.dart';
import 'package:kkulkkulk/common/network/dio_client.dart';
import 'package:kkulkkulk/features/profile/data/models/profile_model.dart';

class ProfileRepository {
  final DioClient _dioClient = DioClient();

  // 🔹 1. 프로필 조회 (GET)
  Future<ProfileModel> fetchUserProfile() async {
    try {
      print("🔍 [API 요청] GET /api/user/info");
      final response = await _dioClient.dio.get('/api/user/info');
      print("✅ [API 응답] ${response.data}");

      return ProfileModel.fromJson(response.data);
    } on DioException catch (e) {
      print("❌ [API 오류] 프로필 조회 실패: ${e.response?.data ?? e.message}");
      throw Exception('❌ 프로필 조회 실패: ${e.response?.data ?? e.message}');
    }
  }

  // 🔹 2. 프로필 업데이트 (닉네임, 키, 팔길이, 클라이밍 시작일을 한 번에 업데이트)
  Future<void> updateProfile({
    required String nickname,
    required double height,
    required double armSpan,
    required DateTime? climbingStartDate,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'nickname': nickname,
        'height': height,
        'arm_span': armSpan,
        'climbing_start_date': climbingStartDate?.toIso8601String(),
      };

      print("🔍 [API 요청] PUT /api/user/info, 데이터: $data");
      final response = await _dioClient.dio.put('/api/user/info', data: data);
      print("✅ [API 응답] ${response.data}");
    } on DioException catch (e) {
      print("❌ [API 오류] 프로필 수정 실패: ${e.response?.data ?? e.message}");
      throw Exception('❌ 프로필 수정 실패: ${e.response?.data ?? e.message}');
    }
  }

  // 🔹 3. 프로필 이미지 변경 (이미지 업로드)
  // Future<void> updateProfileImage(String imagePath) async {
  //   try {
  //     final formData = FormData.fromMap({
  //       'profile_image': await MultipartFile.fromFile(imagePath),
  //     });

  //     await _dioClient.dio.put('/api/v1/my/', data: formData);
  //   } on DioException catch (e) {
  //     throw Exception('❌ 프로필 이미지 수정 실패: ${e.response?.data ?? e.message}');
  //   }
  // }
}
