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
      final leftThumb = pose.landmarks[PoseLandmarkType.leftThumb];
      final leftPinky = pose.landmarks[PoseLandmarkType.leftPinky];
      final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
      final rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
      final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];
      final rightThumb = pose.landmarks[PoseLandmarkType.rightThumb];
      final rightPinky = pose.landmarks[PoseLandmarkType.rightPinky];

      if (leftShoulder == null ||
          leftElbow == null ||
          leftWrist == null ||
          leftThumb == null ||
          leftPinky == null ||
          rightShoulder == null ||
          rightElbow == null ||
          rightWrist == null ||
          rightThumb == null ||
          rightPinky == null) {
        _consecutiveResultPoseFrames = 0;
        return false;
      }

      // 양손이 가슴 앞에 있는지 확인
      final isHandsInFront =
          leftWrist.y > leftShoulder.y - 50 && // 손이 어깨보다 약간 위에
              leftWrist.y < leftShoulder.y + 150 && // 손이 허리보다 위에
              rightWrist.y > rightShoulder.y - 50 &&
              rightWrist.y < rightShoulder.y + 150;

      // 엄지와 새끼손가락의 Y좌표 차이로 엄지 방향 판단
      final leftThumbDirection = leftPinky.y - leftThumb.y;
      final rightThumbDirection = rightPinky.y - rightThumb.y;

      // 디버깅 로그 추가
      logger.d('왼쪽 엄지-새끼 차이: $leftThumbDirection');
      logger.d('오른쪽 엄지-새끼 차이: $rightThumbDirection');
      logger.d(
          '손 위치 - 왼쪽: ${leftWrist.y - leftShoulder.y}, 오른쪽: ${rightWrist.y - rightShoulder.y}');

      // 엄지가 위로 향하는 경우 (성공)
      final isThumbsUp = leftThumbDirection > 30 && rightThumbDirection > 30;
      // 엄지가 아래로 향하는 경우 (실패)
      final isThumbsDown =
          leftThumbDirection < -30 && rightThumbDirection < -30;

      if (isHandsInFront && (isThumbsUp || isThumbsDown)) {
        _consecutiveResultPoseFrames++;
        logger.d(
            '포즈 감지: ${isThumbsUp ? "성공" : "실패"} ($_consecutiveResultPoseFrames/5)');

        if (_consecutiveResultPoseFrames >= 5) {
          _lastLeftArmAngle = isThumbsUp ? 1.0 : 0.0;
          state = false;
          return true;
        }
      } else {
        if (_consecutiveResultPoseFrames > 0) {
          logger.d('포즈 실패 - 손 위치 부적절 또는 엄지 방향 불명확');
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

  bool checkClapPose(Pose pose) {
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
        _consecutiveConfirmFrames = 0;
        return false;
      }

      // 양손이 가운데에서 만나는지 확인
      final leftWristX = leftWrist.x;
      final rightWristX = rightWrist.x;
      final centerX = (leftShoulder.x + rightShoulder.x) / 2;

      // 양손이 어깨 높이 정도에 있는지 확인
      final shoulderY = (leftShoulder.y + rightShoulder.y) / 2;
      final wristY = (leftWrist.y + rightWrist.y) / 2;

      // 박수 포즈 조건:
      // 1. 양손이 중앙에서 만남 (손목 X좌표가 서로 가까움)
      // 2. 손이 어깨 높이 근처에 있음
      final handsClose = (rightWristX - leftWristX).abs() < 50; // 50픽셀 이내
      final handsAtShoulderHeight =
          (wristY - shoulderY).abs() < 100; // 어깨 높이 ±100픽셀
      final handsNearCenter =
          ((leftWristX + rightWristX) / 2 - centerX).abs() < 100; // 중앙 ±100픽셀

      final isClapPose = handsClose && handsAtShoulderHeight && handsNearCenter;

      if (isClapPose) {
        _consecutiveConfirmFrames++;
        logger.d('연속 프레임 수 (박수): $_consecutiveConfirmFrames');
        if (_consecutiveConfirmFrames >= 3) {
          // 3프레임 연속 감지
          return true;
        }
      } else {
        _consecutiveConfirmFrames = 0;
      }

      return false;
    } catch (e) {
      logger.e('박수 포즈 체크 중 오류 발생: $e');
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

  // 성공/실패 판정을 위한 헬퍼 메소드
  bool wasSuccessfulPose() {
    return _lastLeftArmAngle > 0.5; // 1.0이면 성공, 0.0이면 실패
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
