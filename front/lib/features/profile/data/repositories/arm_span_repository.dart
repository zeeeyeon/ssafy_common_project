import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart'; // ✅ MIME 타입 감지를 위한 패키지 추가
import 'package:http_parser/http_parser.dart';
import 'package:kkulkkulk/common/network/dio_client.dart';
import 'package:kkulkkulk/features/profile/data/models/arm_span_model.dart';

class ArmSpanRepository {
  final DioClient _dioClient;

  ArmSpanRepository(this._dioClient);

  /// ✅ **팔길이 측정 요청**
  Future<ArmSpanResult> measureArmSpan(String imagePath, double height) async {
    try {
      debugPrint("📤 팔길이 측정 요청 시작...");
      debugPrint("📂 업로드할 파일 경로: $imagePath");
      debugPrint("📏 입력된 키 값: $height");

      String fileName = path.basename(imagePath);

      // ✅ 파일의 실제 MIME 타입을 감지
      String? mimeType = lookupMimeType(imagePath) ?? 'image/jpeg';
      MediaType mediaType;

      if (mimeType == 'image/png') {
        mediaType = MediaType('image', 'png');
      } else {
        mediaType = MediaType('image', 'jpeg'); // 기본값 JPEG
      }

      debugPrint("📂 감지된 MIME 타입: $mimeType");

      // ✅ 파일을 MultipartFile로 변환
      final fileData = await MultipartFile.fromFile(
        imagePath,
        filename: fileName,
        contentType: mediaType, // ✅ 감지된 MIME 타입 적용
      );

      debugPrint("✅ MultipartFile 변환 성공");
      debugPrint(
          "✅ [CHECK] MultipartFile 변환 완료: ${fileData.filename}, ${File(imagePath).lengthSync()} bytes");

      // ✅ FormData 생성
      FormData formData = FormData.fromMap({
        "file": fileData,
        "height": height.toString(),
      });

      debugPrint("📤 최종 formData: ${formData.fields}, ${formData.files}");
      for (var field in formData.fields) {
        debugPrint("📝 FormData 필드: ${field.key} = ${field.value}");
      }
      for (var file in formData.files) {
        debugPrint("📝 FormData 파일: ${file.key} = ${file.value.filename}");
      }

      // ✅ API 요청
      final response = await _dioClient.dio.post(
        "/fastapi/user/wingspan",
        data: formData,
        options: Options(contentType: "multipart/form-data"),
      );

      if (response.statusCode == 200) {
        debugPrint("✅ 팔길이 측정 성공: ${response.data}");
        return ArmSpanResult.fromJson(response.data);
      } else {
        debugPrint("❌ 팔길이 측정 실패: ${response.data}");
        throw Exception("팔길이 측정 실패: ${response.data}");
      }
    } catch (e) {
      debugPrint("❌ 팔길이 측정 요청 실패: $e");
      throw Exception("팔길이 측정 실패");
    }
  }
}
