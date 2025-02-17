import 'dart:io';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:kkulkkulk/features/camera/providers/camera_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/common/utils/color_converter.dart';
import 'package:kkulkkulk/features/camera/view_models/visit_log_view_model.dart';
import 'package:logger/logger.dart';
import 'package:go_router/go_router.dart';
import 'package:kkulkkulk/features/motionai/utils/pose_detector.dart'; // CustomPoseDetector
import 'package:kkulkkulk/features/motionai/view_models/pose_view_model.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../component/camera_controls.dart';
import '../component/success_failure_dialog.dart';
import 'package:kkulkkulk/features/camera/data/models/hold_model.dart';
import 'package:kkulkkulk/features/camera/view_models/video_view_model.dart';
import 'dart:math' as math;

final logger = Logger();

// TTS 메시지 상수 정의
class TTSMessages {
  static const String autoModeStart = "오른손을 들어주세요. 색상 선택이 시작됩니다";
  static const String colorSelecting = "박수를 쳐서 원하는 색상을 선택해주세요";
  static const String readyToRecord = "양손을 들어 만세 자세를 취하면 녹화가 시작됩니다";
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
  CameraController? _controller;
  bool _isInitialized = false;
  int _cameraIndex = -1;
  bool _isFrontCamera = false;

  // 녹화 관련 변수
  bool _isRecording = false;
  bool _isWaitingForResult = false;
  Timer? _recordingTimer;
  final _recordingDuration = ValueNotifier<Duration>(Duration.zero);
  XFile? _lastRecordedVideo;
  int _maxRecordingSeconds = 30;
  bool _isStoppingRecording = false;

  // 포즈 인식 관련 변수
  CustomPoseDetector? _poseDetector;
  bool _isProcessingFrame = false;
  bool _isAutoMode = false;

  // 색상 선택 관련 변수
  bool _isSelectingColor = false;
  int _currentColorIndex = -1;
  String? _currentColor;
  Timer? _colorSelectionTimer;

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
    _initTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisitLog();
      // 선택된 색상 초기화
      ref.read(selectedHoldProvider.notifier).state = null;
      setState(() {
        selectedHold = null; // 로컬 변수 초기화
      });
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
    try {
      await ref.read(visitLogViewModelProvider.notifier).fetchVisitLog();

      final visitLogState = ref.read(visitLogViewModelProvider);

      // AsyncError 상태 체크 추가
      if (visitLogState is AsyncError ||
          (visitLogState is AsyncData && visitLogState.value == null)) {
        if (!mounted) return;

        // 화면 닫기
        context.pop();

        // 메시지 표시
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('방문 기록이 없습니다. 근처 클라이밍장을 먼저 방문해 주세요.'),
              duration: Duration(seconds: 2),
            ),
          );
        });
        return;
      }
    } catch (e) {
      logger.e('방문 기록 확인 중 오류 발생: $e');
      if (!mounted) return;

      // 화면 닫기
      context.pop();

      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('방문 기록을 확인하는 중 오류가 발생했습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      });
    }
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

  Future<void> _initTts() async {
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

  Future<void> _speak(String text) async {
    if (mounted) {
      await flutterTts.speak(text);
      await flutterTts.awaitSpeakCompletion(true); // TTS 완료 대기
    }
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

      // 현재 카메라의 방향을 확인
      final currentDirection = _controller?.description.lensDirection;

      if (currentDirection != null) {
        // 현재 사용 중인 카메라와 같은 방향의 카메라를 찾음
        _cameraIndex = cameras
            .indexWhere((camera) => camera.lensDirection == currentDirection);
      } else {
        // 처음 초기화하는 경우 _isFrontCamera 값에 따라 카메라 설정
        _cameraIndex = cameras.indexWhere((camera) =>
            camera.lensDirection ==
            (_isFrontCamera
                ? CameraLensDirection.front
                : CameraLensDirection.back));
      }

      // 유효한 카메라 인덱스를 찾지 못한 경우 기본값 설정
      if (_cameraIndex == -1) {
        _cameraIndex = 0;
        _isFrontCamera = cameras[0].lensDirection == CameraLensDirection.front;
      }

      logger.d('카메라 초기화 - 방향: ${_isFrontCamera ? "전면" : "후면"}');

      // 선택한 카메라로 컨트롤러 초기화 진행
      await _initializeCameraController(cameras[_cameraIndex]);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      logger.e('카메라 컨트롤러 초기화 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('카메라 컨트롤러 초기화 실패: $e')),
        );
      }
      rethrow;
    }
  }

  Future<void> _initializeCameraController(CameraDescription camera) async {
    try {
      if (_controller != null) {
        final wasStreaming = _controller!.value.isStreamingImages;
        if (wasStreaming) {
          await _controller!.stopImageStream();
        }
        await _controller!.dispose();
        _controller = null;
      }

      await Future.delayed(const Duration(milliseconds: 300));

      _controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.nv21,
      );

      await _controller!.initialize();
      logger.d('카메라 초기화 완료');

      await Future.wait([
        _controller!.setFocusMode(FocusMode.auto),
        _controller!.setExposureMode(ExposureMode.auto),
        _controller!.setFlashMode(FlashMode.off),
      ]);

      // 자동모드라면 이미지 스트림 시작
      if (_isAutoMode && mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        logger.d(
            '자동모드 점검 - isAutoMode: $_isAutoMode, isStreaming: ${_controller!.value.isStreamingImages}');
        if (!_controller!.value.isStreamingImages) {
          logger.d('이미지 스트림 시작');
          await _controller!.startImageStream((image) {
            if (!_isProcessingFrame && mounted) {
              _isProcessingFrame = true;
              _processFrame(image).then((_) {
                if (mounted) {
                  setState(() {
                    _isProcessingFrame = false;
                  });
                }
              }).catchError((error) {
                logger.e('프레임 처리 중 오류: $error');
                _isProcessingFrame = false;
              });
            }
          });
        } else {
          logger.d('이미지 스트림 이미 진행중');
        }
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      logger.e('카메라 컨트롤러 초기화 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('카메라 컨트롤러 초기화 실패: $e')),
        );
      }
      rethrow;
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
                  top: MediaQuery.of(context).padding.top + 200,
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
    final selectedHold = ref.watch(selectedHoldProvider);

    if (_isWaitingForResult) {
      return "성공은 O 모양, 실패는 X 모양을 취해주세요";
    }
    if (_isAutoMode) {
      if (_isSelectingColor) {
        return "박수를 쳐서 색상을 선택하세요";
      } else if (selectedHold == null) {
        return "오른손을 들어주세요. 색상 선택이 시작됩니다";
      } else {
        return "만세 자세를 취하면 녹화가 시작됩니다";
      }
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

      await _speak("녹화가 시작되었습니다");
      logger.i("녹화가 시작되었습니다.");
    } catch (e) {
      logger.e("녹화 시작 중 오류 발생: $e");
      setState(() => _isRecording = false);
    }
  }

  // 녹화 시작 버튼이 눌렸을 때 호출되는 함수
  void _onRecordPressed() async {
    final hold = ref.read(selectedHoldProvider);
    if (hold == null) {
      // 색상이 선택되지 않았으면 녹화 시작하지 않고 안내 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('녹화를 시작하려면 색상을 선택해주세요.')),
      );
      return;
    }
    await _startRecording();
  }

  Future<void> _stopRecording() async {
    if (!_isRecording || _isStoppingRecording) return;

    try {
      _isStoppingRecording = true;

      final video = await _controller?.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _lastRecordedVideo = video;
        _isWaitingForResult = true;
        _isSelectingColor = false;
        _isProcessingFrame = false;
      });

      // 녹화 타이머 정리
      _recordingTimer?.cancel();
      _recordingDuration.value = Duration.zero;

      // 포즈 관련 상태 초기화
      ref.read(poseViewModelProvider.notifier).resetState();

      // 자동 모드일 때 O/X 포즈 인식 시작
      if (_isAutoMode) {
        // TTS 메시지 재생
        await _speak(TTSMessages.selectResult);

        // 충분한 준비 시간 제공
        await Future.delayed(const Duration(seconds: 1));

        if (_controller != null &&
            _controller!.value.isInitialized &&
            !_controller!.value.isRecordingVideo) {
          logger.d('O/X 포즈 인식을 위한 이미지 스트림 시작');

          // 기존 스트림 중지 후 새로 시작
          if (_controller!.value.isStreamingImages) {
            await _controller!.stopImageStream();
          }

          await Future.delayed(const Duration(milliseconds: 500));

          await _controller!.startImageStream((CameraImage image) {
            if (!_isProcessingFrame && mounted && _isWaitingForResult) {
              _isProcessingFrame = true;
              _processFrame(image).then((_) {
                if (mounted) {
                  setState(() {
                    _isProcessingFrame = false;
                  });
                }
              }).catchError((error) {
                logger.e('O/X 포즈 프레임 처리 중 오류: $error');
                _isProcessingFrame = false;
              });
            }
          });
        }
      } else {
        // 수동 모드: 성공/실패 선택 다이얼로그를 통해 업로드 실행
        final hold = ref.read(selectedHoldProvider);
        if (mounted && hold != null && _lastRecordedVideo != null) {
          await showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (context) => SuccessFailureDialog(
              video: _lastRecordedVideo!,
              selectedHold: hold,
              onResultSelected: (bool isSuccess) async {
                await _handleRecordingComplete(_lastRecordedVideo!, isSuccess);
                setState(() {
                  _lastRecordedVideo = null;
                  _isWaitingForResult = false;
                });
              },
            ),
          );
        }
      }
    } catch (e) {
      logger.e("녹화 종료 중 오류 발생: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('녹화 종료 중 오류가 발생했습니다')),
        );
      }
    } finally {
      _isStoppingRecording = false;
    }
  }

  Future<void> _handleRecordingComplete(XFile video, bool isSuccess) async {
    try {
      // 이미지 스트림 중지
      if (_controller?.value.isStreamingImages ?? false) {
        await _controller?.stopImageStream();
      }

      final selectedHold = ref.read(selectedHoldProvider);
      if (selectedHold == null) {
        throw Exception('선택된 홀드 정보가 없습니다.');
      }

      final visitLogState = ref.read(visitLogViewModelProvider);
      if (visitLogState is! AsyncData || visitLogState.value == null) {
        throw Exception('방문 기록을 불러올 수 없습니다.');
      }

      final result =
          await ref.read(videoViewModelProvider.notifier).uploadVideo(
                videoFile: File(video.path),
                color: selectedHold.color,
                isSuccess: isSuccess,
                userDateId: visitLogState.value!.userDateId,
                holdId: selectedHold.id,
              );

      if (result) {
        await _speak(isSuccess ? '성공으로 기록되었습니다.' : '실패로 기록되었습니다.');
      } else {
        await _speak('업로드에 실패했습니다. 다시 시도해주세요.');
      }

      // 상태 초기화 및 카메라 재시작
      await _resetCaptureState(shouldRestartCamera: true);
    } catch (e) {
      logger.e('비디오 업로드 중 오류 발생: $e');
      await _speak('업로드에 실패했습니다. 다시 시도해주세요.');
    }
  }

  Future<void> _resetCaptureState({bool shouldRestartCamera = false}) async {
    if (!mounted) return;

    try {
      // 이미지 스트림 중지
      if (_controller?.value.isStreamingImages ?? false) {
        await _controller?.stopImageStream();
      }

      // 기존 카메라 컨트롤러 해제
      if (_controller != null) {
        await _controller!.dispose();
        _controller = null;
      }

      setState(() {
        _isRecording = false;
        _isWaitingForResult = false;
        _lastRecordedVideo = null;
        _isProcessingFrame = false;
        selectedHold = null;
        _isSelectingColor = false;
        _currentColorIndex = -1;
        _currentColor = null;
      });

      // Provider 상태 초기화
      ref.read(selectedHoldProvider.notifier).state = null;
      ref.read(poseViewModelProvider.notifier).resetState();
      ref.read(videoViewModelProvider.notifier).resetState();

      // 타이머 취소
      _colorSelectionTimer?.cancel();

      // 카메라 재시작이 필요한 경우에만 실행
      if (shouldRestartCamera && mounted) {
        await Future.delayed(const Duration(seconds: 1));
        await _initializeCamera();
        logger.d('카메라 및 이미지 스트림 재초기화 완료');
      }

      if (_isAutoMode && mounted) {
        await _speak(TTSMessages.autoModeStart);
      }
    } catch (e) {
      logger.e('상태 초기화 중 오류 발생: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('상태 초기화 중 오류가 발생했습니다: $e')),
        );
      }
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

      // 컨트롤러가 초기화되어 있는지 확인
      if (_controller == null || !_controller!.value.isInitialized) {
        logger.e('카메라가 초기화되지 않았습니다.');
        return;
      }

      if (_isAutoMode) {
        logger.d('자동 모드 시작: 이미지 스트림 시작');
        // 현재 스트리밍 중이면 중지
        if (_controller!.value.isStreamingImages) {
          await _controller!.stopImageStream();
        }

        // 카메라 설정 초기화
        await _controller!.setFocusMode(FocusMode.auto);
        await _controller!.setExposureMode(ExposureMode.auto);

        // 약간의 딜레이 후 스트림 시작
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted && _controller != null) {
          await _controller!.startImageStream((image) {
            if (!_isProcessingFrame && mounted) {
              _isProcessingFrame = true;
              _processFrame(image).then((_) {
                if (mounted) {
                  setState(() {
                    _isProcessingFrame = false;
                  });
                }
              }).catchError((error) {
                logger.e('프레임 처리 중 오류: $error');
                _isProcessingFrame = false;
              });
            }
          });
          logger.d('이미지 스트림 시작됨');
          await _speak(TTSMessages.autoModeStart);
        }
      } else {
        logger.d('수동 모드로 전환: 이미지 스트림 중지');
        if (_controller!.value.isStreamingImages) {
          await _controller!.stopImageStream();
          logger.d('이미지 스트림 중지됨');
        }
      }
    } catch (e) {
      logger.e('모드 전환 중 오류 발생: $e');
      // 오류 발생 시 이전 모드로 복구
      setState(() {
        _isAutoMode = !_isAutoMode;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('모드 전환 중 오류가 발생했습니다.')),
        );
      }
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
      _currentColor = hold.color;
    });
    logger.d(
        '색상 선택 완료: color=${hold.color}, holdId=${hold.id}, level=${hold.level}');
  }

  // ============= 카메라 프레임 -> 포즈 인식 =============
  Future<void> _processFrame(CameraImage image) async {
    if (!mounted || _poseDetector == null || !_isAutoMode) return;

    try {
      final poses = await _poseDetector!.processImage(
        image,
        _isFrontCamera, // 현재 카메라 방향 전달
        controller: _controller,
      );

      if (poses.isEmpty) {
        // 포즈가 감지되지 않을 때 상태 초기화
        ref.read(poseViewModelProvider.notifier).resetState();
        return;
      }

      final poseViewModel = ref.read(poseViewModelProvider.notifier);
      final pose = poses.first;

      // 현재 상태에 따른 포즈 인식 처리
      if (_isWaitingForResult && _lastRecordedVideo != null) {
        await _processOXPose(pose, poseViewModel);
      } else if (_isSelectingColor && !_isRecording) {
        await _processColorSelectionPose(pose, poseViewModel);
      } else if (!_isRecording && !_isSelectingColor) {
        await _processNormalPose(pose, poseViewModel);
      }
    } catch (e) {
      logger.e('프레임 처리 중 오류 발생: $e');
      // 에러 발생 시에도 상태 초기화
      ref.read(poseViewModelProvider.notifier).resetState();
    }
  }

  // 포즈 처리를 위한 헬퍼 메서드들
  Future<void> _processOXPose(Pose pose, PoseViewModel poseViewModel) async {
    final isOXPose = poseViewModel.checkOXPose(pose);
    logger.d('O/X 포즈 감지 시도 - 결과: $isOXPose');

    if (isOXPose) {
      final result = poseViewModel.getLastDetectedResult();
      logger.d('감지된 O/X 결과: $result');

      if (result != null) {
        await _handleOXPoseDetected(result);
      }
    }
  }

  Future<void> _processColorSelectionPose(
      Pose pose, PoseViewModel poseViewModel) async {
    if (poseViewModel.checkClapPose(pose)) {
      logger.d('박수 감지됨: 색상 선택 시도');
      if (_currentColorIndex >= 0 && _currentColor != null) {
        _handleColorConfirm();
      }
    }
  }

  Future<void> _processNormalPose(
      Pose pose, PoseViewModel poseViewModel) async {
    final selectedHold = ref.read(selectedHoldProvider);

    if (selectedHold != null) {
      if (poseViewModel.checkRaisedHandsPose(pose)) {
        logger.d('만세 자세 감지: 녹화 시작 시도');
        if (mounted) {
          await _startRecording();
        }
      }
    } else {
      if (poseViewModel.checkColorSelectPose(pose)) {
        logger.d('오른손 들기 감지: 색상 선택 시작');
        if (mounted && !_isSelectingColor) {
          await _speak(TTSMessages.colorSelecting);
          _startColorSelection(); // 색상 선택 로직 시작
        }
      }
    }
  }

  Future<void> _handleOXPoseDetected(bool isSuccess) async {
    // 이미지 스트림 중지
    if (_controller?.value.isStreamingImages ?? false) {
      await _controller?.stopImageStream();
    }

    await _handleRecordingComplete(_lastRecordedVideo!, isSuccess);
    if (mounted) {
      setState(() {
        _isWaitingForResult = false;
        _lastRecordedVideo = null;
        _isProcessingFrame = false;
      });
    }
    logger.d('녹화 재시작');
  }

  Future<void> _startColorSelection() async {
    if (_isSelectingColor) return;

    final visitLogState = ref.read(visitLogViewModelProvider);
    if (visitLogState.value == null || visitLogState.value!.holds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('선택 가능한 색상이 없습니다.')),
      );
      return;
    }

    // 이전 타이머 취소
    _colorSelectionTimer?.cancel();

    if (mounted) {
      // 색상 선택 모드 시작 및 첫 번째 색상 설정
      setState(() {
        _isSelectingColor = true;
        _currentColorIndex = 0;
        _currentColor = visitLogState.value!.holds[0].color;
      });

      // 현재 선택된 색상 안내
      await _announceCurrentColor();
    }

    // 이미지 스트림 시작
    if (_controller != null &&
        !_controller!.value.isStreamingImages &&
        mounted) {
      await _controller!.startImageStream((image) {
        if (!_isProcessingFrame && mounted) {
          _isProcessingFrame = true;
          _processFrame(image).then((_) {
            if (mounted) {
              setState(() {
                _isProcessingFrame = false;
              });
            }
          }).catchError((error) {
            logger.e('프레임 처리 중 오류: $error');
            _isProcessingFrame = false;
          });
        }
      });
    }

    // 색상 순환 타이머 시작
    _colorSelectionTimer =
        Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (!mounted || !_isSelectingColor) {
        timer.cancel();
        return;
      }

      final currentVisitLogState = ref.read(visitLogViewModelProvider);
      if (currentVisitLogState.value == null ||
          currentVisitLogState.value!.holds.isEmpty) {
        timer.cancel();
        return;
      }

      // 현재 진행 중인 TTS가 완료될 때까지 대기
      await flutterTts.awaitSpeakCompletion(true);

      if (mounted && _isSelectingColor) {
        final nextIndex =
            (_currentColorIndex + 1) % currentVisitLogState.value!.holds.length;

        setState(() {
          _currentColorIndex = nextIndex;
          _currentColor = currentVisitLogState.value!.holds[nextIndex].color;
        });

        logger.d('색상 변경: $_currentColor, 인덱스: $_currentColorIndex');
        await _announceCurrentColor();
      }
    });
  }

  Future<void> _announceCurrentColor() async {
    if (!mounted || !_isSelectingColor) return;

    final visitLogState = ref.read(visitLogViewModelProvider);
    if (visitLogState.value?.holds.isEmpty ?? true) return;

    final currentHold = visitLogState.value!.holds[_currentColorIndex];

    // 현재 색상 정보 업데이트
    if (mounted) {
      setState(() {
        ref.read(selectedHoldProvider.notifier).state = currentHold;
        _currentColor = currentHold.color;
      });
    }

    // 색상 안내
    await _speak('${currentHold.color} ${currentHold.level}');
    logger.d('현재 선택된 홀드: color=${currentHold.color}, holdId=${currentHold.id}');
  }

  void _handleColorConfirm() async {
    if (!_isSelectingColor || _currentColorIndex < 0) return;

    final visitLogState = ref.read(visitLogViewModelProvider);
    if (visitLogState.value?.holds.isEmpty ?? true) return;

    // 현재 선택된 색상 정보 저장
    final selectedHold = visitLogState.value!.holds[_currentColorIndex];
    logger.d('색상 선택 확정: ${selectedHold.color} (holdId: ${selectedHold.id})');

    // 타이머 취소 및 선택 모드 종료
    _colorSelectionTimer?.cancel();

    // 이전 TTS 중지
    await flutterTts.stop();

    // 상태 업데이트
    if (mounted) {
      setState(() {
        _isSelectingColor = false;
        ref.read(selectedHoldProvider.notifier).state = selectedHold;
        _currentColor = selectedHold.color;
      });
    }

    // 선택 완료 안내 및 다음 단계 안내
    await _speak('${selectedHold.color} ${selectedHold.level} 선택되었습니다');
    await Future.delayed(const Duration(milliseconds: 500));
    await _speak(TTSMessages.readyToRecord);
  }

  // 녹화 시간 설정 다이얼로그
  void _showRecordingSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        // 다이얼로그 상태로 사용할 임시 변수를 부모 상태의 _maxRecordingSeconds 값으로 초기화.
        int tempMaxRecordingSeconds = _maxRecordingSeconds;
        // 초 값을 분과 초로 변환하는 헬퍼 함수
        String formatTime(int seconds) {
          final minutes = seconds ~/ 60;
          final remainSeconds = seconds % 60;
          if (minutes > 0) {
            return '$minutes분 $remainSeconds초';
          }
          return '$seconds초';
        }

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('녹화 시간 설정'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: tempMaxRecordingSeconds <= 10
                            ? null
                            : () {
                                setStateDialog(() {
                                  tempMaxRecordingSeconds = math.max(
                                      10, tempMaxRecordingSeconds - 10);
                                });
                              },
                      ),
                      Text(
                        formatTime(tempMaxRecordingSeconds),
                        style: const TextStyle(fontSize: 20),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setStateDialog(() {
                            tempMaxRecordingSeconds += 10;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // 다이얼로그에서 확인을 누르면 부모 상태에도 반영.
                    setState(() {
                      _maxRecordingSeconds = tempMaxRecordingSeconds;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('확인'),
                ),
              ],
            );
          },
        );
      },
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

  Future<void> _toggleCamera() async {
    try {
      if (_controller != null) {
        await _controller!.dispose();
        _controller = null;
      }

      final cameras = await availableCameras();
      // 현재 방향의 반대 방향 카메라 찾기
      final newDirection =
          _isFrontCamera ? CameraLensDirection.back : CameraLensDirection.front;

      _cameraIndex =
          cameras.indexWhere((camera) => camera.lensDirection == newDirection);

      if (_cameraIndex == -1) {
        _cameraIndex = 0;
      }

      // _isFrontCamera 값 업데이트
      _isFrontCamera =
          cameras[_cameraIndex].lensDirection == CameraLensDirection.front;

      logger.d('카메라 전환 - 새로운 방향: ${_isFrontCamera ? "전면" : "후면"}');

      // 새로운 컨트롤러 생성 전 300ms 대기
      await Future.delayed(const Duration(milliseconds: 300));
      await _initializeCameraController(cameras[_cameraIndex]);
    } catch (e) {
      logger.e('카메라 전환 중 오류 발생: $e');
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
              '녹화 시작',
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
}
