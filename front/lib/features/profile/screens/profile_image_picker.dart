import 'dart:io';
import 'package:file_picker/file_picker.dart';

/// 🔹 **갤러리에서 이미지 선택 (`file_picker` 사용)**
class ProfileImagePicker {
  static Future<File?> pickImageFromGallery() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image, // 이미지 파일만 선택 가능
      allowMultiple: false, // 단일 선택
    );

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!); // 선택한 파일 반환
    }
    return null;
  }
}
