import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'package:kkulkkulk/common/network/dio_client.dart';

class ProfileImageRepository {
  final DioClient _dioClient;

  ProfileImageRepository(this._dioClient);

  /// 🔹 **프로필 이미지 업로드 API**
  Future<void> uploadProfileImage(File imageFile) async {
    try {
      // ✅ 사용자가 선택한 파일의 원본 이름 가져오기
      String fileName = path.basename(imageFile.path);
      String? mimeType;
      String? extension = path.extension(imageFile.path).toLowerCase();

      // ✅ 파일이 존재하는지 확인 (디버깅용)
      if (!imageFile.existsSync()) {
        debugPrint("❌ 선택한 파일이 존재하지 않습니다: ${imageFile.path}");
        return;
      }

      if (extension == '.jpg' || extension == '.jpeg') {
        mimeType = 'image/jpeg';
      } else if (extension == '.png') {
        mimeType = 'image/png';
      } else {
        debugPrint('❌ 지원하지 않는 파일 형식: $extension');
        return;
      }

      // 파일을 MultipartFile로 변환
      final fileData = await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
        contentType:
            DioMediaType('image', mimeType.split('/')[1]), // 동적 MIME 타입 설정
      );
      debugPrint("✅ MultipartFile 변환 성공");

      // ✅ FormData 생성 (서버 요구사항에 맞게 'file' 키 사용)
      FormData formData = FormData.fromMap({
        "file": fileData, // 🔥 서버에서 요구하는 key 값이 `file`인지 확인 필요!
      });

      // ✅ 디버깅용 로그 추가
      debugPrint("📤 업로드할 파일 이름: $fileName");
      debugPrint("📤 업로드할 파일 경로: ${imageFile.path}");
      debugPrint("📤 최종 formData files: ${formData.files}");

      // ✅ API 요청 보내기
      final response = await _dioClient.dio.put(
        "https://i12e206.p.ssafy.io/api/user/image",
        data: formData,
        options: Options(
          contentType: "multipart/form-data", // ✅ Content-Type 명확히 지정
        ),
      );

      // ✅ 응답 처리
      if (response.statusCode == 200) {
        debugPrint("✅ 프로필 이미지 업로드 성공: ${response.data}");
      } else {
        debugPrint(
            "❌ 프로필 이미지 업로드 실패: ${response.statusCode} - ${response.statusMessage}");
      }
    } catch (e) {
      debugPrint("❌ 프로필 이미지 업로드 에러: $e");
    }
  }
}
