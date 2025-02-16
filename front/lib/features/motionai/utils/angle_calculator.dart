import 'dart:math' as math;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class AngleCalculator {
  static double calculateAngle(
    PoseLandmark first,
    PoseLandmark middle,
    PoseLandmark last,
  ) {
    // 라디안을 각도로 변환하는 함수
    double radianToDegrees(double radian) {
      return radian * 180 / math.pi;
    }

    final angle = radianToDegrees(math.atan2(
          last.y - middle.y,
          last.x - middle.x,
        ) -
        math.atan2(
          first.y - middle.y,
          first.x - middle.x,
        ));

    // 각도를 0~180 범위로 정규화
    return ((angle + 360) % 360).abs();
  }
}
