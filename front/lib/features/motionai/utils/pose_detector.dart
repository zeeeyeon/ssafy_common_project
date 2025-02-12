import 'dart:io';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class CustomPoseDetector {
  final poseDetector = PoseDetector(
    options: PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
      model: PoseDetectionModel.base,
    ),
  );

  static Future<CustomPoseDetector> create() async {
    return CustomPoseDetector();
  }

  Future<List<Pose>> processImage(CameraImage image,
      {int? sensorOrientation}) async {
    try {
      final inputImage = _convertCameraImage(image, sensorOrientation);
      if (inputImage == null) {
        logger.e('Failed to convert camera image');
        return [];
      }

      logger.d(
          'Image format: ${image.format.raw}, planes: ${image.planes.length}');
      return await poseDetector.processImage(inputImage);
    } catch (e) {
      logger.e('Error processing image: $e');
      return [];
    }
  }

  InputImage? _convertCameraImage(CameraImage image, int? sensorOrientation) {
    if (!Platform.isAndroid) return null;

    // 1) YUV420 플레인 데이터 처리
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    // =============== 2) Plane 별 메타데이터 생성 ===============
    final planeData = image.planes.map((Plane plane) {
      return InputImagePlaneMetadata(
        bytesPerRow: plane.bytesPerRow,
        // height와 width가 라이브러리 버전에 따라 없을 수 있음
      );
    }).toList();

    // 3) 이미지 포맷 확인
    const format = InputImageFormat.yuv420;

    // 4) 회전 각도 계산
    final rotation = sensorOrientation != null
        ? _rotationIntToRotation(sensorOrientation)
        : InputImageRotation.rotation0deg;

    logger.d('''
      Converting image:
      - Format (raw): ${image.format.raw}
      - Size: ${image.width}x${image.height}
      - Rotation: $rotation
      - Plane count: ${planeData.length}
      - bytesPerRow for each plane: ${planeData.map((p) => p.bytesPerRow).join(', ')}
    ''');

    // 5) 메타데이터 생성
    final metadata = InputImageMetadata(
      size: ui.Size(
        image.width.toDouble(),
        image.height.toDouble(),
      ),
      rotation: rotation,
      format: format,
      planeData: planeData,
    );

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: metadata,
    );
  }

  void dispose() {
    poseDetector.close();
  }

  // sensorOrientation (예: 0, 90, 180, 270)를 InputImageRotation으로 변환하는 헬퍼 함수
  InputImageRotation _rotationIntToRotation(int sensorOrientation) {
    switch (sensorOrientation) {
      case 0:
        return InputImageRotation.rotation0deg;
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }
}
