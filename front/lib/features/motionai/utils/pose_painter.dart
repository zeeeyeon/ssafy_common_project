import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PosePainter extends CustomPainter {
  final Pose pose;
  final Size absoluteImageSize;
  final InputImageRotation rotation;

  PosePainter(this.pose, this.absoluteImageSize,
      {this.rotation = InputImageRotation.rotation0deg});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.green;

    final leftPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.yellow;

    final rightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.blue;

    void drawPoint(PoseLandmarkType type, Paint paint) {
      final landmark = pose.landmarks[type];
      if (landmark != null) {
        canvas.drawCircle(
          Offset(
            landmark.x * size.width / absoluteImageSize.width,
            landmark.y * size.height / absoluteImageSize.height,
          ),
          1,
          paint,
        );
      }
    }

    void drawLine(
      PoseLandmarkType type1,
      PoseLandmarkType type2,
      Paint paint,
    ) {
      final landmark1 = pose.landmarks[type1];
      final landmark2 = pose.landmarks[type2];

      if (landmark1 != null && landmark2 != null) {
        canvas.drawLine(
          Offset(
            landmark1.x * size.width / absoluteImageSize.width,
            landmark1.y * size.height / absoluteImageSize.height,
          ),
          Offset(
            landmark2.x * size.width / absoluteImageSize.width,
            landmark2.y * size.height / absoluteImageSize.height,
          ),
          paint,
        );
      }
    }

    // 얼굴
    drawLine(
        PoseLandmarkType.leftEar, PoseLandmarkType.leftEyeOuter, leftPaint);
    drawLine(
        PoseLandmarkType.leftEyeOuter, PoseLandmarkType.leftEye, leftPaint);
    drawLine(
        PoseLandmarkType.leftEye, PoseLandmarkType.leftEyeInner, leftPaint);
    drawLine(PoseLandmarkType.leftEyeInner, PoseLandmarkType.nose, leftPaint);
    drawLine(PoseLandmarkType.nose, PoseLandmarkType.rightEyeInner, rightPaint);
    drawLine(
        PoseLandmarkType.rightEyeInner, PoseLandmarkType.rightEye, rightPaint);
    drawLine(
        PoseLandmarkType.rightEye, PoseLandmarkType.rightEyeOuter, rightPaint);
    drawLine(
        PoseLandmarkType.rightEyeOuter, PoseLandmarkType.rightEar, rightPaint);

    // 몸통
    drawLine(
        PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder, paint);
    drawLine(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip, paint);
    drawLine(
        PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, leftPaint);
    drawLine(
        PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, rightPaint);

    // 왼쪽 팔
    drawLine(
        PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, leftPaint);
    drawLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, leftPaint);
    drawLine(PoseLandmarkType.leftWrist, PoseLandmarkType.leftThumb, leftPaint);
    drawLine(PoseLandmarkType.leftWrist, PoseLandmarkType.leftIndex, leftPaint);
    drawLine(PoseLandmarkType.leftWrist, PoseLandmarkType.leftPinky, leftPaint);

    // 오른쪽 팔
    drawLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow,
        rightPaint);
    drawLine(
        PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, rightPaint);
    drawLine(
        PoseLandmarkType.rightWrist, PoseLandmarkType.rightThumb, rightPaint);
    drawLine(
        PoseLandmarkType.rightWrist, PoseLandmarkType.rightIndex, rightPaint);
    drawLine(
        PoseLandmarkType.rightWrist, PoseLandmarkType.rightPinky, rightPaint);

    // 왼쪽 다리
    drawLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, leftPaint);
    drawLine(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, leftPaint);
    drawLine(PoseLandmarkType.leftAnkle, PoseLandmarkType.leftHeel, leftPaint);
    drawLine(
        PoseLandmarkType.leftHeel, PoseLandmarkType.leftFootIndex, leftPaint);

    // 오른쪽 다리
    drawLine(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, rightPaint);
    drawLine(
        PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, rightPaint);
    drawLine(
        PoseLandmarkType.rightAnkle, PoseLandmarkType.rightHeel, rightPaint);
    drawLine(PoseLandmarkType.rightHeel, PoseLandmarkType.rightFootIndex,
        rightPaint);

    // 모든 포인트 그리기
    for (final type in PoseLandmarkType.values) {
      drawPoint(type, paint);
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.pose != pose;
  }
}
