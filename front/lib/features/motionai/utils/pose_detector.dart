import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class CustomPoseDetector {
  final PoseDetector _poseDetector;
  bool _isBusy = false;
  final Map<DeviceOrientation, int> _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  CustomPoseDetector._(this._poseDetector);

  static Future<CustomPoseDetector> create() async {
    try {
      final detector = PoseDetector(
        options: PoseDetectorOptions(
          mode: PoseDetectionMode.stream,
          model: PoseDetectionModel.accurate,
        ),
      );
      return CustomPoseDetector._(detector);
    } catch (e) {
      logger.e('PoseDetector 생성 실패: $e');
      rethrow;
    }
  }

  Future<List<Pose>> processImage(
    CameraImage image,
    bool isFrontCamera, {
    CameraController? controller,
  }) async {
    if (_isBusy) return [];
    _isBusy = true;

    try {
      final inputImage = _convertCameraImageToInputImage(
        image,
        isFrontCamera,
        controller,
      );

      if (inputImage == null) {
        logger.e('이미지 변환 실패');
        return [];
      }

      return await _poseDetector.processImage(inputImage);
    } catch (e) {
      logger.e('포즈 감지 중 오류 발생: $e');
      return [];
    } finally {
      _isBusy = false;
    }
  }

  InputImage? _convertCameraImageToInputImage(
      CameraImage image, bool isFrontCamera, CameraController? controller) {
    final sensorOrientation = controller?.description.sensorOrientation ?? 0;
    var rotationCompensation =
        _orientations[controller?.value.deviceOrientation] ?? 0;

    if (isFrontCamera) {
      rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
    } else {
      rotationCompensation =
          (sensorOrientation - rotationCompensation + 360) % 360;
    }

    final InputImageRotation rotation =
        InputImageRotationValue.fromRawValue(rotationCompensation) ??
            InputImageRotation.rotation0deg;

    if (image.format.group != ImageFormatGroup.nv21) {
      logger.e('지원하지 않는 이미지 포맷: ${image.format.group}');
      return null;
    }

    if (image.planes.length != 1) {
      logger.e('잘못된 이미지 플레인 수: ${image.planes.length}');
      return null;
    }

    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  void dispose() {
    _poseDetector.close();
  }
}
