import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:logger/logger.dart';
import '../utils/angle_calculator.dart';

final logger = Logger();

// 포즈 타입 정의
enum PoseType {
  none,
  colorSelect, // 오른손 들기 (색상 선택)
  recordToggle, // 양손 들기 (녹화 시작/종료)
  oShape, // O 모양 (성공)
  xShape, // X 모양 (실패)
}

// 현재 선택된 색상 인덱스를 관리하는 Provider
final selectedColorIndexProvider = StateProvider<int>((ref) => -1);

// 포즈 감지 결과를 관리하는 Provider
final poseViewModelProvider = StateNotifierProvider<PoseViewModel, bool>((ref) {
  return PoseViewModel();
});

class PoseViewModel extends StateNotifier<bool> {
  PoseViewModel() : super(false);
  int _consecutiveStartPoseFrames = 0;
  int _consecutiveResultPoseFrames = 0;
  int _consecutiveColorSelectFrames = 0;
  int _consecutiveResetFrames = 0;
  int _consecutiveConfirmFrames = 0;
  static const int requiredConsecutiveFrames = 10;

  // 마지막으로 감지된 O/X 포즈의 각도를 저장
  double _lastLeftArmAngle = 0;
  double _lastRightArmAngle = 0;

  bool checkStartPose(Pose pose) {
    try {
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
        _consecutiveStartPoseFrames = 0;
        return false;
      }

      // 양손을 들어올리는 포즈 체크 (녹화 시작)
      final leftArmAngle =
          AngleCalculator.calculateAngle(leftShoulder, leftElbow, leftWrist);
      final rightArmAngle =
          AngleCalculator.calculateAngle(rightShoulder, rightElbow, rightWrist);

      // 디버깅을 위한 로그 추가
      logger.d('왼쪽 팔 각도: $leftArmAngle');
      logger.d('오른쪽 팔 각도: $rightArmAngle');
      logger.d('왼쪽 손목 Y: ${leftWrist.y}, 왼쪽 어깨 Y: ${leftShoulder.y}');
      logger.d('오른쪽 손목 Y: ${rightWrist.y}, 오른쪽 어깨 Y: ${rightShoulder.y}');

      // 조건 완화: 각도를 130도로 낮추고, 연속 프레임 수를 5로 줄임
      final isStartPose = leftArmAngle >= 130 &&
          rightArmAngle >= 130 &&
          leftWrist.y < leftShoulder.y &&
          rightWrist.y < rightShoulder.y;

      if (isStartPose) {
        _consecutiveStartPoseFrames++;
        logger.d('연속 프레임 수: $_consecutiveStartPoseFrames');
        if (_consecutiveStartPoseFrames >= 5) {
          // 10에서 5로 줄임
          state = true;
          return true;
        }
      } else {
        _consecutiveStartPoseFrames = 0;
      }

      return false;
    } catch (e) {
      logger.e('시작 포즈 체크 중 오류 발생: $e');
      return false;
    }
  }

  bool checkResultPose(Pose pose) {
    try {
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
        _consecutiveResultPoseFrames = 0;
        return false;
      }

      // O 모양 또는 X 모양 포즈 체크
      final leftArmAngle =
          AngleCalculator.calculateAngle(leftShoulder, leftElbow, leftWrist);
      final rightArmAngle =
          AngleCalculator.calculateAngle(rightShoulder, rightElbow, rightWrist);

      // 각도 저장
      _lastLeftArmAngle = leftArmAngle;
      _lastRightArmAngle = rightArmAngle;

      // 손목과 어깨의 Y좌표 차이 계산
      final leftWristShoulderDiff = leftShoulder.y - leftWrist.y;
      final rightWristShoulderDiff = rightShoulder.y - rightWrist.y;

      // 포즈 체크 로그
      logger.d('포즈 체크 - 각도 정보');
      logger.d(
          '왼팔: ${leftArmAngle.toStringAsFixed(1)}°, 오른팔: ${rightArmAngle.toStringAsFixed(1)}°');
      logger.d('손목-어깨 높이차 (양수=손목이 위)');
      logger.d(
          '왼쪽: ${leftWristShoulderDiff.toStringAsFixed(1)}, 오른쪽: ${rightWristShoulderDiff.toStringAsFixed(1)}');

      // O 모양: 양팔을 둥글게 만드는 자세 (80~100도)
      final isOShape = (leftArmAngle >= 80 && leftArmAngle <= 100) &&
          (rightArmAngle >= 80 && rightArmAngle <= 100) &&
          leftWristShoulderDiff > 50 && // 손목이 어깨보다 최소 50픽셀 위에 있어야 함
          rightWristShoulderDiff > 50;

      // X 모양: 양팔을 X자로 교차하는 자세 (35~55도)
      final isXShape = (leftArmAngle >= 35 && leftArmAngle <= 55) &&
          (rightArmAngle >= 35 && rightArmAngle <= 55) &&
          leftWristShoulderDiff > 50 && // 손목이 어깨보다 최소 50픽셀 위에 있어야 함
          rightWristShoulderDiff > 50;

      if (isOShape || isXShape) {
        _consecutiveResultPoseFrames++;
        logger.d(
            '포즈 감지: ${isOShape ? "O" : "X"} 모양 ($_consecutiveResultPoseFrames/5)');

        if (_consecutiveResultPoseFrames >= 5) {
          logger.i('포즈 인식 완료: ${isOShape ? "O" : "X"} 모양');
          state = false;
          return true;
        }
      } else {
        if (_consecutiveResultPoseFrames > 0) {
          logger.d('포즈 실패 - 각도 범위 이탈');
          logger.d('O 모양 조건: 80~100°');
          logger.d('X 모양 조건: 35~55°');
        }
        _consecutiveResultPoseFrames = 0;
      }

      return false;
    } catch (e) {
      logger.e('결과 포즈 체크 중 오류 발생: $e');
      return false;
    }
  }

  bool checkEndPose(Pose pose) {
    try {
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
        _consecutiveResultPoseFrames = 0;
        return false;
      }

      // 양손을 들어올리는 포즈 체크 (녹화 종료)
      final leftArmAngle =
          AngleCalculator.calculateAngle(leftShoulder, leftElbow, leftWrist);
      final rightArmAngle =
          AngleCalculator.calculateAngle(rightShoulder, rightElbow, rightWrist);

      final isEndPose = leftArmAngle >= 150 &&
          rightArmAngle >= 150 &&
          leftWrist.y < leftShoulder.y &&
          rightWrist.y < rightShoulder.y;

      if (isEndPose) {
        _consecutiveResultPoseFrames++;
        if (_consecutiveResultPoseFrames >= requiredConsecutiveFrames) {
          state = false;
          return true;
        }
      } else {
        _consecutiveResultPoseFrames = 0;
      }

      return false;
    } catch (e) {
      logger.e('종료 포즈 체크 중 오류 발생: $e');
      return false;
    }
  }

  bool checkColorSelectPose(Pose pose) {
    try {
      final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
      final rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
      final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];

      if (rightShoulder == null || rightElbow == null || rightWrist == null) {
        _consecutiveColorSelectFrames = 0;
        return false;
      }

      // 오른팔을 들어올리는 포즈 체크 (색상 선택 시작)
      final rightArmAngle =
          AngleCalculator.calculateAngle(rightShoulder, rightElbow, rightWrist);

      // 디버깅을 위한 로그 추가
      logger.d('오른쪽 팔 각도: $rightArmAngle');
      logger.d('오른쪽 손목 Y: ${rightWrist.y}, 오른쪽 어깨 Y: ${rightShoulder.y}');

      // 오른팔을 130도 이상 들어올린 자세
      final isColorSelectPose =
          rightArmAngle >= 130 && rightWrist.y < rightShoulder.y;

      if (isColorSelectPose) {
        _consecutiveColorSelectFrames++;
        logger.d('연속 프레임 수 (색상 선택): $_consecutiveColorSelectFrames');
        if (_consecutiveColorSelectFrames >= 5) {
          return true;
        }
      } else {
        _consecutiveColorSelectFrames = 0;
      }

      return false;
    } catch (e) {
      logger.e('색상 선택 포즈 체크 중 오류 발생: $e');
      return false;
    }
  }

  bool checkConfirmPose(Pose pose) {
    try {
      final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
      final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
      final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];

      if (leftShoulder == null || leftElbow == null || leftWrist == null) {
        _consecutiveConfirmFrames = 0;
        return false;
      }

      // 왼팔을 들어올리는 포즈 체크 (색상 선택 확정)
      final leftArmAngle =
          AngleCalculator.calculateAngle(leftShoulder, leftElbow, leftWrist);

      // 디버깅을 위한 로그 추가
      logger.d('왼쪽 팔 각도: $leftArmAngle');
      logger.d('왼쪽 손목 Y: ${leftWrist.y}, 왼쪽 어깨 Y: ${leftShoulder.y}');

      // 왼팔을 130도 이상 들어올린 자세
      final isConfirmPose = leftArmAngle >= 130 && leftWrist.y < leftShoulder.y;

      if (isConfirmPose) {
        _consecutiveConfirmFrames++;
        logger.d('연속 프레임 수 (확정): $_consecutiveConfirmFrames');
        if (_consecutiveConfirmFrames >= 5) {
          return true;
        }
      } else {
        _consecutiveConfirmFrames = 0;
      }

      return false;
    } catch (e) {
      logger.e('확정 포즈 체크 중 오류 발생: $e');
      return false;
    }
  }

  bool checkResetPose(Pose pose) {
    try {
      final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
      final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
      final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];

      if (leftShoulder == null || leftElbow == null || leftWrist == null) {
        _consecutiveResetFrames = 0;
        return false;
      }

      // 왼팔을 들어올리는 포즈 체크 (색상 선택 초기화)
      final leftArmAngle =
          AngleCalculator.calculateAngle(leftShoulder, leftElbow, leftWrist);

      // 디버깅을 위한 로그 추가
      logger.d('왼쪽 팔 각도: $leftArmAngle');
      logger.d('왼쪽 손목 Y: ${leftWrist.y}, 왼쪽 어깨 Y: ${leftShoulder.y}');

      // 왼팔을 130도 이상 들어올린 자세
      final isResetPose = leftArmAngle >= 130 && leftWrist.y < leftShoulder.y;

      if (isResetPose) {
        _consecutiveResetFrames++;
        logger.d('연속 프레임 수 (초기화): $_consecutiveResetFrames');
        if (_consecutiveResetFrames >= 5) {
          return true;
        }
      } else {
        _consecutiveResetFrames = 0;
      }

      return false;
    } catch (e) {
      logger.e('초기화 포즈 체크 중 오류 발생: $e');
      return false;
    }
  }

  // 마지막으로 감지된 왼팔 각도 반환
  double getLastLeftArmAngle() {
    return _lastLeftArmAngle;
  }

  // 마지막으로 감지된 오른팔 각도 반환
  double getLastRightArmAngle() {
    return _lastRightArmAngle;
  }

  @override
  void resetState() {
    state = false;
    _consecutiveStartPoseFrames = 0;
    _consecutiveResultPoseFrames = 0;
    _consecutiveColorSelectFrames = 0;
    _consecutiveResetFrames = 0;
    _consecutiveConfirmFrames = 0;
    _lastLeftArmAngle = 0;
    _lastRightArmAngle = 0;
  }
}
