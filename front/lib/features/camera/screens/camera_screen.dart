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
  static const String selectColor = "오른손으로 색 선택을 시작하세요";
  static const String colorSelecting = "박수를 쳐서 현재 색상을 선택하세요";
  static const String startRecording = "만세 자세로 녹화를 시작하세요";
  static const String recordingFinished = "녹화가 종료되었습니다";
  static const String selectGesture = "엄지를 위로 올리면 성공, 아래로 내리면 실패입니다";
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
  final bool _showGestureGuide = false;

  // 색상 선택 관련 변수
  bool _isSelectingColor = false;
  int _currentColorIndex = -1;
  String? _currentColor;
  Timer? _colorSelectionTimer;
  bool _colorSelectionStarted = false;

  // TTS 관련 변수
  late FlutterTts flutterTts;

  List<CameraDescription>? cameras;
  Hold? selectedHold;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    _initTTS();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisitLog();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopRecording();
    _controller?.dispose();
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
      // 사용 가능한 카메라 목록 가져오기
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('사용 가능한 카메라가 없습니다.')),
          );
        }
        return;
      }

      // 후면 카메라를 기본으로 설정
      _cameraIndex = cameras.indexWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
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
      ResolutionPreset.low,
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
                    fit: BoxFit.cover,
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
                if (_isRecording)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 16,
                    left: 0,
                    right: 0,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
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
                          isRecording: _isRecording,
                          onRecordPressed: _startRecording,
                          onStopPressed: _stopRecording,
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

  void _speakGestureGuide() async {
    if (_isRecording) {
      await flutterTts.speak('엄지를 위로 올리면 성공, 아래로 내리면 실패입니다');
    } else {
      if (_isSelectingColor) {
        await flutterTts.speak('양손을 들어 올려 선택을 확인하세요');
      } else {
        await flutterTts.speak('오른손을 들어 색상을 선택하세요');
      }
    }
  }

  String _getGuideText() {
    if (_isWaitingForResult) {
      return _isAutoMode ? "성공은 O 모양, 실패는 X 모양을 취해주세요" : "성공 또는 실패를 선택해주세요";
    }
    if (_isAutoMode) {
      return _isRecording ? "녹화를 종료하려면 양손을 들어주세요" : "녹화를 시작하려면 양손을 들어주세요";
    }
    return "화면을 터치하여 녹화를 시작/종료할 수 있습니다";
  }

  // ============= 수동 녹화 로직 =============
  Future<void> _startRecording() async {
    if (_isRecording || _isWaitingForResult) return; // 결과 선택 대기 중에는 녹화 불가

    final selectedHold = ref.read(selectedHoldProvider);
    if (selectedHold == null && !_isAutoMode) {
      // 자동 모드가 아닐 때만 체크
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('색상을 먼저 선택해주세요'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      // 수동 모드일 때만 색상 선택 모달 표시
      if (!_isAutoMode) {
        _showColorPicker();
      }
      return;
    }

    final visitLogState = ref.read(visitLogViewModelProvider);
    if (visitLogState is! AsyncData || visitLogState.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('클라이밍장 정보를 불러오는 중입니다.')),
      );
      return;
    }

    try {
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
        // 설정된 시간 후 자동 종료
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('녹화 시작 중 오류가 발생했습니다')),
      );
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    try {
      final video = await _controller?.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _lastRecordedVideo = video;
        _isWaitingForResult = true; // 성공/실패 선택 대기 상태로 변경
      });

      // 자동 모드일 때 이미지 스트림 재시작
      if (_isAutoMode && _controller != null) {
        await _controller!.startImageStream((image) {
          if (!_isProcessingFrame) {
            _isProcessingFrame = true;
            _processFrame(image);
          }
        });
      }

      if (_isAutoMode) {
        // 자동 모드일 때는 TTS로 안내
        await flutterTts.speak("성공 또는 실패 포즈를 취해주세요");
      } else {
        // 수동 모드일 때는 다이얼로그 표시
        if (mounted && selectedHold != null) {
          await showDialog(
            context: context,
            barrierDismissible: false, // 바깥 영역 터치로 닫기 방지
            builder: (context) => SuccessFailureDialog(
              video: video!,
              selectedHold: selectedHold!,
              onResultSelected: () {
                setState(() {
                  _isWaitingForResult = false;
                });
              },
            ),
          );
        }
      }
    } catch (e) {
      logger.e('녹화 종료 중 오류 발생: $e');
    }
  }

  // ============= 자동/수동 모드 전환 =============
  void _toggleMode() async {
    if (_controller == null) return;

    try {
      final bool isCurrentlyStreaming = _controller!.value.isStreamingImages;

      setState(() {
        _isAutoMode = !_isAutoMode;
        // 수동 모드로 전환 시 색상 선택 상태 초기화
        if (!_isAutoMode) {
          _isSelectingColor = false;
          _currentColorIndex = -1;
          _colorSelectionStarted = false;
          _colorSelectionTimer?.cancel();
        }
      });

      if (_isAutoMode) {
        logger.d('자동 모드로 전환');
        if (isCurrentlyStreaming) {
          await _controller!.stopImageStream();
        }

        // 포즈 감지기 재초기화
        await _initPoseDetector();

        await Future.delayed(const Duration(milliseconds: 100));
        await _controller!.startImageStream((image) {
          if (!_isProcessingFrame) {
            _isProcessingFrame = true;
            _processFrame(image);
          }
        });

        // 자동 모드 시작 안내
        await flutterTts.speak('포즈 인식 모드가 시작되었습니다');
      } else {
        logger.d('수동 모드로 전환');
        if (isCurrentlyStreaming) {
          logger.d('이미지 스트림 중지');
          await _controller!.stopImageStream();
        }
        await flutterTts.speak('수동 모드로 전환되었습니다');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isAutoMode ? '포즈 인식 모드' : '수동 모드'),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      logger.e("모드 전환 중 오류 발생: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모드 전환 중 오류가 발생했습니다')),
      );
    }
  }

  // ============= 색상 선택 (홀드) =============
  void _showColorPicker() {
    final visitLogState = ref.read(visitLogViewModelProvider);
    if (visitLogState is AsyncData && visitLogState.value != null) {
      final holds = visitLogState.value!.holds;
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "색상 선택",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 120,
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                      ),
                      itemCount: holds.length,
                      itemBuilder: (context, index) {
                        final hold = holds[index];
                        return GestureDetector(
                          onTap: () {
                            ref.read(selectedHoldProvider.notifier).state =
                                hold;
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
                              if (ref.watch(selectedHoldProvider)?.id ==
                                  hold.id)
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
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  // ============= 카메라 프레임 -> 포즈 인식 =============
  Future<void> _processFrame(CameraImage image) async {
    if (!mounted ||
        _controller == null ||
        !_isAutoMode ||
        _poseDetector == null) {
      return;
    }

    try {
      final poses = await _poseDetector!.processImage(
        image,
        _isFrontCamera,
        controller: _controller,
      );

      if (!mounted || poses.isEmpty) return;

      final pose = poses.first;
      final poseViewModel = ref.read(poseViewModelProvider.notifier);
      final visitLogState = ref.read(visitLogViewModelProvider);

      if (visitLogState is AsyncData && visitLogState.value != null) {
        final holds = visitLogState.value!.holds;

        // 1. 색상 선택 모드
        if (selectedHold == null) {
          if (!_isSelectingColor) {
            // 오른팔을 들어서 색상 선택 시작
            if (poseViewModel.checkColorSelectPose(pose)) {
              _startColorSelection();
            }
          } else {
            // 박수 포즈로 현재 색상 선택
            if (poseViewModel.checkClapPose(pose)) {
              if (_currentColorIndex >= 0 &&
                  _currentColorIndex < holds.length) {
                _confirmColorSelection(holds[_currentColorIndex]);
              }
            }
          }
          return;
        }

        // 2. 녹화 시작/종료 포즈 체크 (만세 자세)
        if (!_isRecording) {
          if (poseViewModel.checkStartPose(pose)) {
            await _startRecording();
          }
        }

        // 3. 녹화 종료 후 O/X 포즈 체크
        if (!_isRecording && _lastRecordedVideo != null) {
          if (poseViewModel.checkResultPose(pose)) {
            final leftArmAngle = poseViewModel.getLastLeftArmAngle();
            final rightArmAngle = poseViewModel.getLastRightArmAngle();

            // O 모양 판정 (70~110도)
            final isOShape = (leftArmAngle >= 70 && leftArmAngle <= 110) &&
                (rightArmAngle >= 70 && rightArmAngle <= 110);

            await _handleRecordingComplete(_lastRecordedVideo!, isOShape);
            _lastRecordedVideo = null;

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isOShape ? '성공으로 기록되었습니다!' : '실패로 기록되었습니다.'),
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      logger.e('프레임 처리 중 오류 발생: $e');
    } finally {
      _isProcessingFrame = false;
    }
  }

  Future<void> _announceCurrentColor() async {
    try {
      final visitLogState = ref.read(visitLogViewModelProvider);

      if (visitLogState is AsyncLoading) {
        logger.d('방문 기록 로딩 중...');
        return;
      }

      if (visitLogState is AsyncError) {
        logger.e('방문 기록 에러: ${visitLogState.error}');
        return;
      }

      if (visitLogState.value == null || visitLogState.value!.holds.isEmpty) {
        logger.d('사용 가능한 홀드가 없습니다.');
        return;
      }

      if (_currentColorIndex < 0) {
        _currentColorIndex = 0;
      } else if (_currentColorIndex >= visitLogState.value!.holds.length) {
        _currentColorIndex = visitLogState.value!.holds.length - 1;
      }

      final currentHold = visitLogState.value!.holds[_currentColorIndex];

      // 현재 색상 상태 업데이트
      setState(() {
        _currentColor = currentHold.color;
      });

      // TTS 실행 전 이전 음성 중지
      await flutterTts.stop();

      // 색상과 레벨 안내
      await flutterTts.speak('${currentHold.color} ${currentHold.level}');
      logger.d('현재 색상 안내: ${currentHold.color} ${currentHold.level}');
    } catch (e) {
      logger.e('음성 안내 중 오류 발생: $e');
      setState(() {
        _isSelectingColor = false;
        _currentColorIndex = -1;
        _colorSelectionStarted = false;
        _currentColor = null;
      });
      _colorSelectionTimer?.cancel();
    }
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
      _colorSelectionStarted = true;
    });

    try {
      await flutterTts.stop(); // 이전 음성 중지
      await flutterTts.speak(TTSMessages.colorSelecting);
      await _announceCurrentColor();

      // 타이머 시작 전 기존 타이머 취소
      _colorSelectionTimer?.cancel();

      // 2초마다 다음 색상으로 순환
      _colorSelectionTimer =
          Timer.periodic(const Duration(seconds: 2), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        final visitLogState = ref.read(visitLogViewModelProvider);
        if (visitLogState.value == null ||
            !_isSelectingColor ||
            visitLogState.value!.holds.isEmpty) {
          timer.cancel();
          return;
        }

        setState(() {
          _currentColorIndex =
              (_currentColorIndex + 1) % visitLogState.value!.holds.length;
        });

        _announceCurrentColor();
      });
    } catch (e) {
      logger.e('색상 선택 시작 중 오류 발생: $e');
      setState(() {
        _isSelectingColor = false;
        _currentColorIndex = -1;
        _colorSelectionStarted = false;
      });
    }
  }

  void _confirmColorSelection(Hold selectedColor) async {
    _colorSelectionTimer?.cancel();
    setState(() {
      selectedHold = selectedColor;
      _isSelectingColor = false;
      _colorSelectionStarted = false;
      _currentColor = selectedColor.color;
    });
    ref.read(selectedHoldProvider.notifier).state = selectedColor;
    await flutterTts.speak(
        '${selectedColor.color} ${selectedColor.level} 선택되었습니다. 녹화를 시작하려면 양팔을 들어주세요.');
    logger.d('색상 선택 완료: ${selectedColor.color} ${selectedColor.level}');
  }

  Future<void> _handleRecordingComplete(XFile video, bool isSuccess) async {
    final visitLogState = ref.read(visitLogViewModelProvider);
    final selectedHold = ref.read(selectedHoldProvider);

    if (visitLogState is AsyncData &&
        visitLogState.value != null &&
        selectedHold != null) {
      try {
        await ref.read(videoViewModelProvider.notifier).uploadVideo(
              videoFile: File(video.path),
              color: selectedHold.color,
              isSuccess: isSuccess,
              userDateId: visitLogState.value!.userDateId,
              holdId: selectedHold.id,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('영상이 업로드되었습니다')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('영상 업로드 실패: $e')),
          );
        }
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
    if (!_isInitialized) return;

    try {
      // 현재 이미지 스트림 중지
      if (_controller?.value.isStreamingImages ?? false) {
        await _controller?.stopImageStream();
      }

      final cameras = await availableCameras();
      if (cameras.length < 2) return;

      // 현재 카메라 dispose
      await _controller?.dispose();

      setState(() {
        _cameraIndex = (_cameraIndex + 1) % cameras.length;
        _controller = null; // 컨트롤러 초기화
      });

      // 새로운 카메라로 초기화
      await _initializeCameraController(cameras[_cameraIndex]);

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
}
