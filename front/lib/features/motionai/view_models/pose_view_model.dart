import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:logger/logger.dart';
import '../utils/angle_calculator.dart';

final logger = Logger();

final poseViewModelProvider = StateNotifierProvider<PoseViewModel, bool>((ref) {
  return PoseViewModel();
});

class PoseViewModel extends StateNotifier<bool> {
  PoseViewModel() : super(false);

  bool checkStartPose(Pose pose) {
    // 오른팔 들기 자세 체크
    final shoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final elbow = pose.landmarks[PoseLandmarkType.rightElbow];
    final wrist = pose.landmarks[PoseLandmarkType.rightWrist];

    if (shoulder == null || elbow == null || wrist == null) {
      logger
          .d('오른쪽 포즈 랜드마크 누락: shoulder=$shoulder, elbow=$elbow, wrist=$wrist');
      return false;
    }

    final armAngle = AngleCalculator.calculateAngle(shoulder, elbow, wrist);
    final isWristAboveShoulder = wrist.y < shoulder.y;

    logger.d('오른팔 각도: $armAngle, 손목 위치: ${isWristAboveShoulder ? '위' : '아래'}');
    return armAngle >= 130 && armAngle <= 180 && isWristAboveShoulder;
  }

  bool checkResultPose(Pose pose) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];

    if (leftShoulder == null ||
        leftElbow == null ||
        leftWrist == null ||
        rightShoulder == null ||
        rightElbow == null ||
        rightWrist == null) {
      logger.d('결과 포즈 랜드마크 누락');
      return false;
    }

    final leftArmAngle =
        AngleCalculator.calculateAngle(leftShoulder, leftElbow, leftWrist);
    final rightArmAngle =
        AngleCalculator.calculateAngle(rightShoulder, rightElbow, rightWrist);

    final isLeftArmRaised = leftArmAngle >= 130 &&
        leftArmAngle <= 180 &&
        leftWrist.y < leftShoulder.y;
    final isRightArmRaised = rightArmAngle >= 130 &&
        rightArmAngle <= 180 &&
        rightWrist.y < rightShoulder.y;

    logger.d('왼팔 각도: $leftArmAngle, 오른팔 각도: $rightArmAngle');

    if (isLeftArmRaised) {
      logger.i('성공 포즈 감지 (왼팔)');
      state = true;
      return true;
    } else if (isRightArmRaised) {
      logger.i('실패 포즈 감지 (오른팔)');
      state = false;
      return true;
    }

    return false;
  }

  void markAttemptResult(bool isSuccess) {
    state = isSuccess;
  }
}
