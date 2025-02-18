import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

/// 🔹 **갤러리에서 이미지 선택 (`file_picker` 사용)**
class ProfileImagePicker {
  static Future<File?> pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();

      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // 이미지 품질 조정
        maxWidth: 1200, // 최대 너비
        maxHeight: 1200, // 최대 높이
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('이미지 선택 오류: $e');
      return null;
    }
  }

  // 카메라로 직접 촬영하는 기능 추가 (필요한 경우)
  static Future<File?> takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();

      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo != null) {
        return File(photo.path);
      }
      return null;
    } catch (e) {
      debugPrint('카메라 오류: $e');
      return null;
    }
  }
}
