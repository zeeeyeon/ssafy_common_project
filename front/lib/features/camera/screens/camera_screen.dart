import 'dart:io';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:kkulkkulk/features/camera/providers/camera_providers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/common/utils/color_converter.dart';
import 'package:kkulkkulk/features/camera/view_models/visit_log_view_model.dart';
import 'package:logger/logger.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kkulkkulk/features/motionai/utils/pose_detector.dart'; // CustomPoseDetector
import 'package:kkulkkulk/features/motionai/view_models/pose_view_model.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../widgets/camera_controls.dart';
import '../widgets/recording_indicator.dart';
import '../widgets/success_failure_dialog.dart';
import 'package:kkulkkulk/features/camera/data/models/hold_model.dart';
import 'package:kkulkkulk/features/camera/view_models/video_view_model.dart';
import 'dart:math' as math;

final logger = Logger();

// TTS 메시지 상수 정의
class TTSMessages {
  static const String autoModeStart = "오른손을 들어주세요. 색상 선택이 시작됩니다";
  static const String colorSelecting = "박수를 쳐서 원하는 색상을 선택해주세요";
  static const String readyToRecord = "만세 자세를 취하면 녹화가 시작됩니다";
  static const String recordingFinished = "녹화가 종료되었습니다";
  static const String selectResult = "O 모양은 성공, X 모양은 실패입니다";
}

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with WidgetsBindingObserver {
  // 카메라 관련 변수
  CameraController? _controller;
  bool _isInitialized = false;
  int _cameraIndex = -1;
  final bool _isFrontCamera = false;

  // 녹화 관련 변수
  bool _isRecording = false;
  final bool _isProcessingVideo = false;
  bool _isWaitingForResult = false; // 성공/실패 선택 대기 상태
  Timer? _recordingTimer;
  final _recordingDuration = ValueNotifier<Duration>(Duration.zero);
  XFile? _lastRecordedVideo;
  int _maxRecordingSeconds = 30; // 기본 녹화 시간 30초

  // 포즈 인식 관련 변수
  CustomPoseDetector? _poseDetector;
  bool _isProcessingFrame = false;
  bool _isAutoMode = false;
  bool _showGestureGuide = false;

  // 색상 선택 관련 변수
  bool _isSelectingColor = false;
  int _currentColorIndex = -1;
  String? _currentColor;
  Timer? _colorSelectionTimer;
  final bool _colorSelectionStarted = false;

  // TTS 관련 변수
  late FlutterTts flutterTts;

  List<CameraDescription>? cameras;
  Hold? selectedHold;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initPoseDetector();
    _initializeCamera();
    _initTTS();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisitLog();
    });
  }

  @override
  void dispose() {
    // 이미지 스트림과 카메라 컨트롤러를 순차적으로 정리
    Future.microtask(() async {
      try {
        if (_controller?.value.isStreamingImages ?? false) {
          await _controller?.stopImageStream();
        }
        await _controller?.dispose();
      } catch (e) {
        logger.e('카메라 리소스 해제 중 오류: $e');
      }
    });

    WidgetsBinding.instance.removeObserver(this);
    _poseDetector?.dispose();
    _recordingTimer?.cancel();
    _colorSelectionTimer?.cancel();
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _checkVisitLog() async {
    // 방문 로그(클라이밍장 정보) 불러오기
    await ref.read(visitLogViewModelProvider.notifier).fetchVisitLog();
  }

  Future<void> _initPoseDetector() async {
    try {
      // 기존 포즈 감지기가 있다면 dispose
      _poseDetector?.dispose();
      _poseDetector = await CustomPoseDetector.create();
    } catch (e) {
      logger.e("포즈 감지기 초기화 오류: $e");
      rethrow;
    }
  }

  Future<void> _initTTS() async {
    flutterTts = FlutterTts();
    await flutterTts.setLanguage('ko-KR');
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    // TTS 완료 이벤트 리스너 추가
    flutterTts.setCompletionHandler(() {
      logger.d("TTS 완료");
    });

    // TTS 에러 이벤트 리스너 추가
    flutterTts.setErrorHandler((msg) {
      logger.e("TTS 에러: $msg");
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      // 초광각 카메라 찾기
      _cameraIndex = cameras.indexWhere(
        (camera) =>
            camera.lensDirection == CameraLensDirection.back &&
            camera.sensorOrientation == 270, // 초광각 카메라는 보통 270도
      );
      if (_cameraIndex == -1) _cameraIndex = 0;

      // 카메라 컨트롤러 초기화
      await _initializeCameraController(cameras[_cameraIndex]);

      // 포즈 감지기 초기화
      _poseDetector = await CustomPoseDetector.create();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('카메라 초기화 실패: $e')),
        );
      }
    }
  }

  Future<void> _initializeCameraController(CameraDescription camera) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: true,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    try {
      await _controller!.initialize();

      // 줌 레벨 설정 전에 최소/최대 줌 레벨 확인
      final minZoom = await _controller!.getMinZoomLevel();
      final maxZoom = await _controller!.getMaxZoomLevel();
      logger.d('카메라 줌 레벨 범위: $minZoom ~ $maxZoom');

      // 카메라 방향에 따른 줌 레벨 설정 (안전한 범위 내에서)
      double targetZoom =
          camera.lensDirection == CameraLensDirection.front ? 1.0 : 1.0;
      // 줌 레벨이 범위 내에 있는지 확인
      targetZoom = targetZoom.clamp(minZoom, maxZoom);

      await _controller!.setZoomLevel(targetZoom);
      logger.d('줌 레벨 설정 완료: $targetZoom');

      // 자동 모드일 때만 이미지 스트림 시작
      if (_isAutoMode) {
        logger.d('이미지 스트림 시작');
        await _controller!.startImageStream((image) {
          if (!_isProcessingFrame) {
            _isProcessingFrame = true;
            _processFrame(image);
          }
        });
      }
    } catch (e) {
      logger.e('카메라 컨트롤러 초기화 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('카메라 컨트롤러 초기화 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedHold = ref.watch(selectedHoldProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: _controller != null
          ? Stack(
              children: [
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: SizedBox(
                      width: _controller!.value.previewSize?.width ?? 0,
                      height: _controller!.value.previewSize?.height ?? 0,
                      child: CameraPreview(_controller!),
                    ),
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      _buildTopControls(),
                    ],
                  ),
                ),
                if (!_isRecording && (_isAutoMode || _isWaitingForResult))
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 60,
                    left: 0,
                    right: 0,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getGuideText(),
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 40, top: 20),
                    color: Colors.black.withOpacity(0.3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.flip_camera_ios,
                              color: Colors.white),
                          onPressed: _toggleCamera,
                        ),
                        CameraControls(
                          onRecordPressed: _onRecordPressed,
                          onStopPressed: _stopRecording,
                          isRecording: _isRecording,
                        ),
                        GestureDetector(
                          onTap: _showColorPicker,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                              color: selectedHold != null
                                  ? ColorConverter.fromString(
                                      selectedHold.color)
                                  : Colors.transparent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 120,
                  left: 0,
                  right: 0,
                  child: _buildColorDisplay(),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildTopControls() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.photo_library),
                color: Colors.white,
                onPressed: () => context.go('/album'),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(_isAutoMode
                        ? Icons.motion_photos_auto
                        : Icons.touch_app),
                    color: Colors.white,
                    onPressed: _toggleMode,
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    color: Colors.white,
                    onPressed: _showPoseGuide,
                  ),
                  IconButton(
                    icon: const Icon(Icons.timer),
                    color: Colors.white,
                    onPressed: _showRecordingSettingsDialog,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_isRecording)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.fiber_manual_record,
                  color: Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                ValueListenableBuilder<Duration>(
                  valueListenable: _recordingDuration,
                  builder: (context, duration, child) {
                    return Text(
                      '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.white),
                    );
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _getGuideText() {
    if (_isWaitingForResult) {
      return "성공은 O 모양, 실패는 X 모양을 취해주세요";
    }
    if (_isAutoMode) {
      if (_isSelectingColor) {
        return "박수를 쳐서 색상을 선택하세요";
      } else if (selectedHold == null) {
        return "오른손을 들어주세요. 색상 선택이 시작됩니다";
      }
      if (_isRecording) {
        return ""; // 녹화 중에는 가이드 텍스트 표시하지 않음
      }
      return "만세 자세로 녹화를 시작하세요";
    }
    return "화면을 터치하여 녹화를 시작/종료할 수 있습니다";
  }

  // ============= 수동 녹화 로직 =============
  Future<bool> _canStartRecording() async {
    final selectedHold = ref.read(selectedHoldProvider);
    logger.d(
        '녹화 시작 전 선택된 홀드: ${selectedHold?.color}, holdId: ${selectedHold?.id}');
    if (selectedHold == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('녹화를 시작하려면 색상을 선택해주세요'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _startRecording() async {
    if (!await _canStartRecording()) return;

    try {
      // 녹화 시작 전 이미지 스트림 중지
      if (_controller!.value.isStreamingImages) {
        await _controller!.stopImageStream();
      }

      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _recordingDuration.value = Duration.zero;
      });

      _recordingTimer?.cancel();
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          _recordingDuration.value += const Duration(seconds: 1);
        });
        // 설정된 시간(_maxRecordingSeconds) 초가 지나면 자동 종료
        if (_recordingDuration.value.inSeconds >= _maxRecordingSeconds) {
          _stopRecording();
          timer.cancel();
        }
      });

      await flutterTts.speak('녹화가 시작되었습니다');
      logger.i("녹화가 시작되었습니다.");
    } catch (e) {
      logger.e("녹화 시작 중 오류 발생: $e");
      setState(() => _isRecording = false);
    }
  }

  // 녹화 시작 버튼이 눌렸을 때 호출되는 함수
  void _onRecordPressed() async {
    if (selectedHold == null) {
      // 색상이 선택되지 않았으면 녹화 시작하지 않고 안내 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('녹화를 시작하려면 색상을 선택해주세요.')),
      );
      return;
    }
    await _startRecording();
  }

  Future<void> _stopRecording() async {
    if (!_isRecording || _controller == null) return;

    try {
      logger.d('녹화 종료 시작');
      final XFile video = await _controller!.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _recordingDuration.value = Duration.zero;
      });
      _recordingTimer?.cancel();
      logger.d('비디오 파일 생성됨: ${video.path}');

      if (!_isAutoMode) {
        logger.d('수동 모드에서 다이얼로그 표시 시도');
        if (mounted && selectedHold != null) {
          await showDialog<void>(
            context: context,
            barrierDismissible: false, // 바깥 영역 터치로 닫히지 않도록 설정
            builder: (context) => SuccessFailureDialog(
              video: video,
              selectedHold: selectedHold!,
              onResultSelected: () {
                setState(() {
                  _lastRecordedVideo = null;
                  _isWaitingForResult = false;
                });
              },
            ),
          );
          logger.d('다이얼로그 표시 완료');
        }
      } else {
        setState(() {
          _lastRecordedVideo = video;
          _isWaitingForResult = true;
        });
        await flutterTts.speak(TTSMessages.selectResult);
        if (_isAutoMode && !_controller!.value.isStreamingImages) {
          await _controller!.startImageStream((image) {
            if (!_isProcessingFrame) {
              _isProcessingFrame = true;
              _processFrame(image);
            }
          });
        }
      }
    } catch (e) {
      logger.e('녹화 종료 중 오류 발생: $e');
      setState(() => _isRecording = false);
    }
  }

  // ============= 자동/수동 모드 전환 =============
  Future<void> _toggleMode() async {
    try {
      setState(() {
        _isAutoMode = !_isAutoMode;
        if (_isAutoMode) {
          _isSelectingColor = false;
          selectedHold = null;
          ref.read(selectedHoldProvider.notifier).state = null;
        }
      });

      if (_isAutoMode) {
        logger.d('자동 모드 시작: 이미지 스트림 시작');
        if (!_controller!.value.isStreamingImages) {
          await _controller!.startImageStream((image) {
            if (!_isProcessingFrame) {
              _isProcessingFrame = true;
              _processFrame(image);
            }
          });
          logger.d('이미지 스트림 시작됨');
        }
        await flutterTts.speak(TTSMessages.autoModeStart);
      } else {
        logger.d('수동 모드로 전환: 이미지 스트림 중지');
        if (_controller!.value.isStreamingImages) {
          await _controller!.stopImageStream();
          logger.d('이미지 스트림 중지됨');
        }
      }
    } catch (e) {
      logger.e('모드 전환 중 오류 발생: $e');
    }
  }

  // ============= 색상 선택 (홀드) =============
  void _showColorPicker() async {
    final visitLogState = ref.read(visitLogViewModelProvider);
    if (visitLogState.value == null || visitLogState.value!.holds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('선택 가능한 색상이 없습니다.')),
      );
      return;
    }

    final holds = visitLogState.value!.holds;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: GridView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: holds.length,
          itemBuilder: (context, index) {
            final hold = holds[index];
            return GestureDetector(
              onTap: () {
                _updateSelectedColor(hold);
                Navigator.pop(context);
              },
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: ColorConverter.fromString(hold.color),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                  ),
                  if (ref.watch(selectedHoldProvider)?.id == hold.id)
                    const Positioned.fill(
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // 색상 선택 상태 업데이트를 위한 헬퍼 메서드
  void _updateSelectedColor(Hold hold) {
    ref.read(selectedHoldProvider.notifier).state = hold;
    setState(() {
      selectedHold = hold;
      _currentColor = hold.color;
    });
    logger.d(
        '색상 선택 완료: color=${hold.color}, holdId=${hold.id}, level=${hold.level}');
  }

  // ============= 카메라 프레임 -> 포즈 인식 =============
  Future<void> _processFrame(CameraImage image) async {
    if (!mounted || _poseDetector == null) return;

    try {
      final poses = await _poseDetector!.processImage(
        image,
        _isFrontCamera,
        controller: _controller,
      );

      if (poses.isEmpty) {
        _isProcessingFrame = false;
        return;
      }

      final poseViewModel = ref.read(poseViewModelProvider.notifier);
      final pose = poses.first;

      // 녹화 종료 후 O/X 선택 대기 중일 때는 다른 포즈 감지 중지
      if (_isWaitingForResult) {
        logger.d('O/X 포즈 감지 시도 중...');
        final isOXPose = poseViewModel.checkOXPose(pose);
        logger.d('O/X 포즈 감지 여부: $isOXPose');

        if (isOXPose) {
          logger.d('O/X 포즈 감지됨!');
          final result = poseViewModel.getLastDetectedResult();
          logger.d('감지된 포즈 결과: $result');

          if (result != null && _lastRecordedVideo != null) {
            await _handleRecordingComplete(_lastRecordedVideo!, result);
            setState(() {
              _isWaitingForResult = false;
              _lastRecordedVideo = null;
            });
          }
        }
        _isProcessingFrame = false;
        return;
      }

      // 색상 선택 중일 때 박수 감지
      if (_isAutoMode && _isSelectingColor) {
        logger.d('박수 감지 시도 중...');
        if (poseViewModel.checkClapPose(pose)) {
          logger.d('박수 감지됨: 색상 선택 시도');
          _handleColorConfirm();
        }
        _isProcessingFrame = false;
        return;
      }

      // 색상 선택 시작을 위한 오른손 들기 감지
      if (_isAutoMode &&
          !_isSelectingColor &&
          selectedHold == null &&
          poseViewModel.checkColorSelectPose(pose)) {
        logger.d('오른손 들기 감지: 색상 선택 시작');
        _startColorSelection();
        _isProcessingFrame = false;
        return;
      }

      // 녹화 시작을 위한 만세 포즈 감지 (색상이 선택된 후에만)
      if (!_isSelectingColor &&
          !_isWaitingForResult &&
          selectedHold != null &&
          poseViewModel.checkRaisedHandsPose(pose)) {
        if (!_isRecording) {
          _startRecording();
        }
        return;
      }
    } catch (e) {
      logger.e('프레임 처리 중 오류 발생: $e');
    } finally {
      _isProcessingFrame = false;
    }
  }

  Future<void> _announceCurrentColor() async {
    final visitLogState = ref.read(visitLogViewModelProvider);
    if (visitLogState.value == null || visitLogState.value!.holds.isEmpty)
      return;

    final currentHold = visitLogState.value!.holds[_currentColorIndex];
    setState(() {
      _currentColor = currentHold.color;
      ref.read(selectedHoldProvider.notifier).state = currentHold;
      selectedHold = currentHold; // 로컬 상태도 업데이트
    });

    await flutterTts.speak('${currentHold.color} ${currentHold.level}');
    logger.d('선택된 홀드: ${currentHold.color}, holdId: ${currentHold.id}');
  }

  void _startColorSelection() async {
    if (_isSelectingColor) return;

    final visitLogState = ref.read(visitLogViewModelProvider);
    if (visitLogState.value == null || visitLogState.value!.holds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('선택 가능한 색상이 없습니다.')),
      );
      return;
    }

    setState(() {
      _isSelectingColor = true;
      _currentColorIndex = 0;
      _currentColor = visitLogState.value!.holds[0].color;
    });

    logger.d('색상 선택 모드 시작: _isSelectingColor=$_isSelectingColor');
    await _announceCurrentColor();
    await flutterTts.speak(TTSMessages.colorSelecting);

    // 타이머 시작 전 기존 타이머 취소
    _colorSelectionTimer?.cancel();

    // 색상 순환 타이머 시작
    _colorSelectionTimer =
        Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (!mounted || !_isSelectingColor) {
        timer.cancel();
        return;
      }

      final visitLogState = ref.read(visitLogViewModelProvider);
      if (visitLogState.value == null || visitLogState.value!.holds.isEmpty) {
        timer.cancel();
        return;
      }

      setState(() {
        _currentColorIndex =
            (_currentColorIndex + 1) % visitLogState.value!.holds.length;
        _currentColor = visitLogState.value!.holds[_currentColorIndex].color;
      });

      logger.d('색상 변경: $_currentColor, 인덱스: $_currentColorIndex');
      await _announceCurrentColor();
    });
  }

  Future<void> _handleRecordingComplete(XFile video, bool isSuccess) async {
    logger.d('비디오 업로드 시작: isSuccess=$isSuccess');
    final visitLogState = ref.read(visitLogViewModelProvider);
    final selectedHold = ref.read(selectedHoldProvider);

    if (visitLogState is! AsyncData || visitLogState.value == null) {
      logger.e('방문 기록 상태가 유효하지 않음');
      return;
    }

    if (selectedHold == null) {
      logger.e('선택된 홀드가 없음');
      return;
    }

    try {
      logger.d(
          '비디오 업로드 시도: color=${selectedHold.color}, holdId=${selectedHold.id}');
      await ref.read(videoViewModelProvider.notifier).uploadVideo(
            videoFile: File(video.path),
            color: selectedHold.color,
            isSuccess: isSuccess,
            userDateId: visitLogState.value!.userDateId,
            holdId: selectedHold.id,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(isSuccess ? '성공 영상이 업로드되었습니다' : '실패 영상이 업로드되었습니다')),
        );
      }
      logger.d('비디오 업로드 성공');
    } catch (e) {
      logger.e('비디오 업로드 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('영상 업로드 실패: $e')),
        );
      }
    }
  }

  // 녹화 시간 설정 다이얼로그
  void _showRecordingSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('녹화 시간 설정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _maxRecordingSeconds <= 10
                      ? null
                      : () {
                          setState(() {
                            _maxRecordingSeconds =
                                math.max(10, _maxRecordingSeconds - 10);
                          });
                        },
                ),
                Text(
                  '$_maxRecordingSeconds초',
                  style: const TextStyle(fontSize: 20),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _maxRecordingSeconds >= 120
                      ? null
                      : () {
                          setState(() {
                            _maxRecordingSeconds =
                                math.min(120, _maxRecordingSeconds + 10);
                          });
                        },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  // 색상 안내 위젯
  Widget _buildColorDisplay() {
    if (!_isAutoMode || !_isSelectingColor || _currentColor == null) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: ColorConverter.fromString(_currentColor!),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _currentColor!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGestureGuide() {
    return Positioned(
      bottom: 120, // 하단 여백 조정
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              _isAutoMode ? '자동 모드 가이드' : '수동 모드 가이드',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getGuideText(),
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleCamera() async {
    try {
      // 현재 녹화 중이면 중지
      if (_isRecording) {
        await _stopRecording();
      }

      // 현재 이미지 스트림 중지
      final isStreaming = _controller?.value.isStreamingImages ?? false;
      if (isStreaming) {
        await _controller?.stopImageStream();
      }

      // 현재 카메라 세션 완전히 종료
      if (_controller != null) {
        await _controller?.dispose();
      }

      final cameras = await availableCameras();
      if (cameras.length < 2) return;

      setState(() {
        _cameraIndex = (_cameraIndex + 1) % cameras.length;
        _controller = null; // 컨트롤러 초기화
      });

      // 새로운 카메라 초기화 전 약간의 딜레이
      await Future.delayed(const Duration(milliseconds: 500));

      // 새로운 카메라로 초기화
      await _initializeCameraController(cameras[_cameraIndex]);

      // 자동 모드일 경우 이미지 스트림 재시작
      if (_isAutoMode && mounted && _controller != null) {
        await _controller?.startImageStream((image) {
          if (!_isProcessingFrame) {
            _isProcessingFrame = true;
            _processFrame(image);
          }
        });
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      logger.e('카메라 전환 중 오류 발생: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('카메라 전환 중 오류가 발생했습니다')),
        );
      }
    }
  }

  void _showPoseGuide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('포즈 가이드'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPoseGuideItem(
              '색상 선택',
              '오른손을 어깨 위로 들어올리세요',
              Icons.front_hand,
            ),
            const SizedBox(height: 16),
            _buildPoseGuideItem(
              '색상 선택 확인',
              '박수를 쳐서 현재 색상을 선택하세요',
              Icons.back_hand,
            ),
            const SizedBox(height: 16),
            _buildPoseGuideItem(
              '녹화 시작/종료',
              '양손을 어깨 위로 들어올리세요',
              Icons.front_hand,
            ),
            const SizedBox(height: 16),
            _buildPoseGuideItem(
              '성공/실패 표시',
              'O 모양은 성공, X 모양은 실패입니다',
              Icons.gesture,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Widget _buildPoseGuideItem(String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleOGesture() {
    setState(() {
      _showGestureGuide = false;
    });
    if (_lastRecordedVideo != null && selectedHold != null) {
      _handleRecordingComplete(_lastRecordedVideo!, true);
    }
  }

  void _handleXGesture() {
    setState(() {
      _showGestureGuide = false;
    });
    if (_lastRecordedVideo != null && selectedHold != null) {
      _handleRecordingComplete(_lastRecordedVideo!, false);
    }
  }

  void _handleColorConfirm() async {
    if (_currentColorIndex >= 0) {
      final visitLogState = ref.read(visitLogViewModelProvider);
      if (visitLogState.value != null &&
          visitLogState.value!.holds.isNotEmpty) {
        final currentHold = visitLogState.value!.holds[_currentColorIndex];
        logger.d('색상 선택 시도: ${currentHold.color}');

        setState(() {
          selectedHold = currentHold;
          _isSelectingColor = false;
          _colorSelectionTimer?.cancel();
        });

        // 상태 업데이트 후 Provider 업데이트
        ref.read(selectedHoldProvider.notifier).state = currentHold;

        logger.d('색상 선택 완료: ${currentHold.color}, holdId: ${currentHold.id}');
        await flutterTts.speak(TTSMessages.readyToRecord);
      }
    }
  }
}
