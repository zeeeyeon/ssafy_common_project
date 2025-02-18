import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:logger/logger.dart';
import '../utils/angle_calculator.dart';
import 'dart:math' as math;

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
  int _consecutiveOXPoseFrames = 0;
  int _consecutiveColorSelectFrames = 0;
  int _consecutiveConfirmFrames = 0;
  bool? _lastDetectedResult; // true: O(성공), false: X(실패)
  static const int requiredConsecutiveFrames = 10;
  static int consecutiveClapFrames = 0; // 연속 박수 프레임 카운트

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

  bool checkClapPose(Pose pose) {
    try {
      final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
      final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];

      if (leftWrist == null || rightWrist == null) {
        logger.d('손목 랜드마크 누락');
        consecutiveClapFrames = 0;
        return false;
      }

      // 양손이 서로 가까이 있는지 확인 (정규화된 좌표 기준 15% 이내)
      final handsClose = (rightWrist.x - leftWrist.x).abs() < 0.15 && // 15% 이내
          (rightWrist.y - leftWrist.y).abs() < 0.15; // 15% 이내

      logger.d(
          '손 간격 (정규화된 값) - X: ${(rightWrist.x - leftWrist.x).abs()}, Y: ${(rightWrist.y - leftWrist.y).abs()}');

      if (handsClose) {
        consecutiveClapFrames++;
        logger.d('박수 포즈 감지! 연속 프레임: $consecutiveClapFrames');
        if (consecutiveClapFrames >= 1) {
          // 1프레임으로 유지 (즉각 반응)
          logger.d('박수 인식 성공!');
          consecutiveClapFrames = 0;
          return true;
        }
      } else {
        consecutiveClapFrames = 0;
      }

      return false;
    } catch (e) {
      logger.e('박수 포즈 체크 중 오류 발생: $e');
      return false;
    }
  }

  bool checkRaisedHandsPose(Pose pose) {
    try {
      final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
      final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];
      final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
      final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
      final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
      final rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];

      if ([
        leftWrist,
        rightWrist,
        leftShoulder,
        rightShoulder,
        leftElbow,
        rightElbow
      ].any((point) => point == null)) {
        return false;
      }

      // 양팔이 위로 올라가 있는지 확인 (만세 자세)
      final leftArmAngle =
          AngleCalculator.calculateAngle(leftShoulder!, leftElbow!, leftWrist!);
      final rightArmAngle = AngleCalculator.calculateAngle(
          rightShoulder!, rightElbow!, rightWrist!);

      // 양손이 어깨보다 충분히 위에 있고, 팔이 펴져있는지 확인
      final handsAboveShoulders =
          leftWrist.y < leftShoulder.y - 0.2 && // 어깨보다 20% 이상 위에
              rightWrist.y < rightShoulder.y - 0.2;
      final armsExtended =
          leftArmAngle > 150 && rightArmAngle > 150; // 팔이 거의 펴져있음

      logger.d('만세 포즈 체크 - 왼팔각도: $leftArmAngle, 오른팔각도: $rightArmAngle');
      logger.d('손 위치 - 왼손: ${leftWrist.y}, 오른손: ${rightWrist.y}');

      return handsAboveShoulders && armsExtended;
    } catch (e) {
      logger.e('만세 포즈 체크 중 오류: $e');
      return false;
    }
  }

  bool checkOXPose(Pose pose) {
    try {
      final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
      final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
      final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];
      final rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
      final head = pose.landmarks[PoseLandmarkType.nose];
      final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
      final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];

      if ([
        leftWrist,
        leftElbow,
        rightWrist,
        rightElbow,
        head,
        leftShoulder,
        rightShoulder
      ].any((point) => point == null)) {
        logger.d('필요한 랜드마크가 누락되었습니다.');
        return false;
      }

      // O 포즈 조건
      final handsAboveHead =
          leftWrist!.y < head!.y - 0.1 && rightWrist!.y < head.y - 0.1;
      final handsClose = (leftWrist.x - rightWrist!.x).abs() < 0.25 &&
          (leftWrist.y - rightWrist.y).abs() < 0.25;
      final isOPose = handsAboveHead && handsClose;

      // X 포즈 조건
      final leftArmVector = {
        'x': leftWrist.x - leftElbow!.x,
        'y': leftWrist.y - leftElbow.y
      };
      final rightArmVector = {
        'x': rightWrist.x - rightElbow!.x,
        'y': rightWrist.y - rightElbow.y
      };
      final dotProduct = leftArmVector['x']! * rightArmVector['x']! +
          leftArmVector['y']! * rightArmVector['y']!;
      final leftMagnitude = math.sqrt(
          math.pow(leftArmVector['x']!, 2) + math.pow(leftArmVector['y']!, 2));
      final rightMagnitude = math.sqrt(math.pow(rightArmVector['x']!, 2) +
          math.pow(rightArmVector['y']!, 2));
      final angle = math.acos(dotProduct / (leftMagnitude * rightMagnitude));
      final armsCrossing = (leftWrist.x - rightWrist.x).abs() < 0.35 &&
          (leftWrist.y - rightWrist.y).abs() < 0.35;
      const xPoseAngleThreshold = 0.5;
      final isXPose =
          (angle - 1.57).abs() < xPoseAngleThreshold && armsCrossing;

      if (isOPose) {
        _consecutiveOXPoseFrames++;
        _lastDetectedResult = true;
        logger.d('O 포즈 감지 - 연속 프레임: $_consecutiveOXPoseFrames');
      } else if (isXPose) {
        _consecutiveOXPoseFrames++;
        _lastDetectedResult = false;
        logger.d('X 포즈 감지 - 연속 프레임: $_consecutiveOXPoseFrames');
      } else {
        _consecutiveOXPoseFrames = 0;
        _lastDetectedResult = null;
      }

      return _consecutiveOXPoseFrames >= 3;
    } catch (e) {
      logger.e('O/X 포즈 체크 중 오류 발생: $e');
      return false;
    }
  }

  // 마지막으로 감지된 O/X 결과 반환
  bool? getLastDetectedResult() {
    return _lastDetectedResult;
  }

  @override
  void resetState() {
    state = false;
    _consecutiveStartPoseFrames = 0;
    _consecutiveOXPoseFrames = 0;
    _consecutiveColorSelectFrames = 0;
    _consecutiveConfirmFrames = 0;
    _lastDetectedResult = null;
  }
}
