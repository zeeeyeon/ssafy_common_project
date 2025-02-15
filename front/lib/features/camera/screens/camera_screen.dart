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
  final bool _isFrontCamera = false;

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
      // _isFrontCamera 플래그 기준으로 카메라 선택
      if (_isFrontCamera) {
        _cameraIndex = cameras.indexWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front);
        if (_cameraIndex == -1) _cameraIndex = 0;
      } else {
        _cameraIndex = cameras.indexWhere((camera) =>
                camera.lensDirection == CameraLensDirection.back &&
                camera.sensorOrientation == 270 // 후면 카메라 조건 (필요에 따라 수정)
            );
        if (_cameraIndex == -1) {
          _cameraIndex = cameras.indexWhere(
              (camera) => camera.lensDirection == CameraLensDirection.back);
        }
      }

      // 선택한 카메라로 컨트롤러 초기화 진행
      await _initializeCameraController(cameras[_cameraIndex]);
      logger.d('카메라 초기화 완료 (모드: ${_isFrontCamera ? "전면" : "후면"})');

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

      await _speak("녹화가 시작되었습니다");
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
    } catch (e) {
      logger.e('비디오 업로드 중 오류 발생: $e');
      await _speak('업로드에 실패했습니다. 다시 시도해주세요.');
    }
  }

  // ============= 자동/수동 모드 전환 =============
  Future<void> _toggleMode() async {
    try {
      // 현재 상태 저장
      final wasAutoMode = _isAutoMode;

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
        _isFrontCamera,
        controller: _controller,
      );

      if (poses.isEmpty) {
        return;
      }

      final poseViewModel = ref.read(poseViewModelProvider.notifier);
      final pose = poses.first;

      // O/X 포즈 인식 중일 때 (녹화 종료 후)
      if (_isWaitingForResult && _lastRecordedVideo != null) {
        final isOXPose = poseViewModel.checkOXPose(pose);
        logger.d('O/X 포즈 감지 시도 - 결과: $isOXPose');
        logger.d('현재 포즈 상태: ${pose.landmarks}'); // 포즈 데이터 로깅 추가

        if (isOXPose) {
          final result = poseViewModel.getLastDetectedResult();
          logger.d('감지된 O/X 결과: $result'); // 결과 로깅 추가

          if (result != null) {
            // 이미지 스트림 중지
            if (_controller?.value.isStreamingImages ?? false) {
              await _controller?.stopImageStream();
            }

            await _handleRecordingComplete(_lastRecordedVideo!, result);
            if (mounted) {
              setState(() {
                _isWaitingForResult = false;
                _lastRecordedVideo = null;
                _isProcessingFrame = false;
              });
              _resetCaptureState();
            }
            logger.d('녹화 재시작');
            _initializeCamera();
          }
        }
        return; // O/X 인식 중에는 다른 포즈 인식하지 않음
      }

      // 색상 선택 모드일 때
      if (_isSelectingColor && !_isRecording) {
        if (poseViewModel.checkClapPose(pose)) {
          logger.d('박수 감지됨: 색상 선택 시도');
          if (_currentColorIndex >= 0 && _currentColor != null) {
            logger.d('현재 선택된 색상: $_currentColor, 인덱스: $_currentColorIndex');
            _handleColorConfirm();
          } else {
            logger.e('색상 선택 실패: 유효하지 않은 색상 정보');
          }
        }
        return; // 색상 선택 모드에서는 다른 포즈 인식하지 않음
      }

      // 일반 자동 모드일 때 (녹화 중이 아니고, 색상 선택 모드가 아닐 때)
      if (!_isRecording && !_isSelectingColor) {
        final selectedHold = ref.read(selectedHoldProvider);

        if (selectedHold != null) {
          // 색상이 선택된 상태에서는 만세 자세만 인식
          if (poseViewModel.checkRaisedHandsPose(pose)) {
            logger.d('만세 자세 감지: 녹화 시작 시도');
            if (mounted) {
              await _startRecording();
            }
          }
        } else {
          // 색상이 선택되지 않은 상태에서만 오른손 들기 인식
          if (poseViewModel.checkColorSelectPose(pose)) {
            logger.d('오른손 들기 감지: 색상 선택 모드 시작');
            if (mounted) {
              _startColorSelection();
            }
          }
        }
      }
    } catch (e) {
      logger.e('프레임 처리 중 오류 발생: $e');
    }
  }

  Future<void> _announceCurrentColor() async {
    final visitLogState = ref.read(visitLogViewModelProvider);
    if (visitLogState.value?.holds.isEmpty ?? true) return;

    final currentHold = visitLogState.value!.holds[_currentColorIndex];
    ref.read(selectedHoldProvider.notifier).state = currentHold;
    setState(() {
      _currentColor = currentHold.color;
    });

    await _speak('${currentHold.color} ${currentHold.level}');
    logger.d('선택된 홀드: color=${currentHold.color}, holdId=${currentHold.id}');
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

    // 이미지 스트림이 멈춰있다면 재시작
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

    setState(() {
      _isSelectingColor = true;
      _currentColorIndex = 0;
      _currentColor = visitLogState.value!.holds[0].color;
    });

    logger.d('색상 선택 모드 시작: _isSelectingColor=$_isSelectingColor');
    await _announceCurrentColor();
    await _speak(TTSMessages.colorSelecting);

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

  void _handleColorConfirm() async {
    if (!_isSelectingColor || _currentColorIndex < 0) return;

    final visitLogState = ref.read(visitLogViewModelProvider);
    if (visitLogState.value?.holds.isEmpty ?? true) return;

    final selectedHold = visitLogState.value!.holds[_currentColorIndex];
    logger.d('색상 선택 확정: ${selectedHold.color} (holdId: ${selectedHold.id})');

    // 타이머 취소
    _colorSelectionTimer?.cancel();

    // 이미지 스트림 유지 (중지하지 않음)
    setState(() {
      _isSelectingColor = false;
      ref.read(selectedHoldProvider.notifier).state = selectedHold;
      _currentColor = selectedHold.color;
    });

    // TTS 안내
    await _speak('${selectedHold.color} ${selectedHold.level} 선택되었습니다');
    await Future.delayed(const Duration(milliseconds: 500));
    await _speak(TTSMessages.readyToRecord);
  }

  void _resetCaptureState() {
    if (!mounted) return;

    setState(() {
      _lastRecordedVideo = null;
      _isWaitingForResult = false;
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

    // 타이머는 무조건 취소 (새 촬영 시 새 타이머 시작)
    _colorSelectionTimer?.cancel();

    // TTS 중지는 상황에 따라 선택적 실행
    if (!_isAutoMode) {
      // 수동 모드일 때만 TTS 중지
      flutterTts.stop();
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
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }

    final cameras = await availableCameras();
    _cameraIndex = (_cameraIndex + 1) % cameras.length;

    // 새로운 컨트롤러 생성 전 300ms 대기
    await Future.delayed(const Duration(milliseconds: 300));
    await _initializeCameraController(cameras[_cameraIndex]);
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

  Future<void> _onVideoUploadCompleted() async {
    setState(() {
      _isRecording = false;
      _isAutoMode = true;
    });

    // 5초 딜레이: 업로드 완료 후 5초 동안 대기합니다.
    await Future.delayed(const Duration(seconds: 5));

    // 5초 이후에 카메라 컨트롤러를 재초기화하여 이미지 스트림을 재시작합니다.
    _initializeCamera().then((_) {
      logger.d('비디오 업로드 후 5초 뒤 카메라 재초기화 및 이미지 스트림 재시작 완료');
    }).catchError((e) {
      logger.e('비디오 업로드 후 카메라 재초기화 오류: $e');
    });
  }
}
