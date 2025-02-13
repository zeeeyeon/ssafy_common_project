import 'dart:io';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/common/utils/color_converter.dart';
import 'package:kkulkkulk/features/camera/data/models/visit_log_model.dart';
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

final logger = Logger();

// TTS 메시지 상수 정의
class TTSMessages {
  static const String selectColor = "오른손으로 색 선택을 시작하세요";
  static const String startRecording = "만세 자세로 색 선택 및 녹화를 시작하세요";
  static const String recordingFinished = "녹화가 종료되었습니다";
  static const String selectGesture = "O 또는 X 동작으로 성공 여부를 선택해주세요";
}

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool isRecording = false;
  List<CameraDescription>? cameras;
  Hold? selectedHold;
  bool _isFrontCamera = false;

  Timer? _recordingTimer;
  Timer? _colorSelectionTimer;
  final _recordingDuration = ValueNotifier<Duration>(Duration.zero);
  CustomPoseDetector? _poseDetector;
  bool _isProcessingFrame = false;
  bool _isAutoMode = false;
  DateTime? _recordingStartTime;
  late FlutterTts flutterTts;

  bool _isSelectingColor = false;
  int _currentColorIndex = -1;
  List<Hold> holds = [];
  bool _colorSelectionStarted = false;
  XFile? _lastRecordedVideo;
  bool _showGestureGuide = false; // O/X 선택 안내 표시 여부

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
    _initTTS();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisitLog();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    try {
      _recordingTimer?.cancel();
      if (_controller != null) {
        final bool isStreaming = _controller!.value.isStreamingImages;
        if (isStreaming) {
          _controller!.stopImageStream();
        }
        _controller!.dispose();
      }
      _poseDetector?.dispose();
      _colorSelectionTimer?.cancel();
      flutterTts.stop();
    } catch (e) {
      logger.e("리소스 해제 중 오류 발생: $e");
    }
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
    if (_controller == null || !mounted) return;

    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      if (_controller != null) {
        await _controller!.dispose();
      }

      cameras = await availableCameras();
      if (cameras == null || cameras!.isEmpty) {
        throw Exception('카메라를 찾을 수 없습니다.');
      }

      _controller = CameraController(
        cameras![_isFrontCamera ? 1 : 0],
        ResolutionPreset.max,
        enableAudio: true,
      );

      // 카메라 초기화 완료 대기
      await _controller!.initialize();

      if (mounted) {
        setState(() {});
      }

      await _initPoseDetector();

      if (_isAutoMode) {
        await _controller!.startImageStream((image) {
          if (!_isProcessingFrame) {
            _isProcessingFrame = true;
            _processFrame(image);
          }
        });
      }
    } catch (e) {
      logger.e("카메라 초기화 오류: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('카메라 초기화 중 오류가 발생했습니다')),
        );
      }
    }
  }

  // 카메라 전환 함수 수정
  Future<void> _toggleCamera() async {
    if (cameras == null || cameras!.length < 2) return;

    try {
      // 1. 현재 카메라 상태 확인 및 리소스 해제
      if (_controller != null) {
        final bool isStreaming = _controller!.value.isStreamingImages;
        if (isStreaming) {
          await _controller!.stopImageStream();
        }
        await _controller!.dispose();
        _controller = null;
      }

      // 프레임 처리 상태 초기화
      _isProcessingFrame = false;

      // 2. 카메라 권한 재확인
      final status = await Permission.camera.status;
      if (!status.isGranted) {
        final result = await Permission.camera.request();
        if (!result.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('카메라 권한이 필요합니다')),
            );
          }
          return;
        }
      }

      // 3. 카메라 전환
      setState(() {
        _isFrontCamera = !_isFrontCamera;
      });

      // 4. 새 카메라 초기화
      _controller = CameraController(
        cameras![_isFrontCamera ? 1 : 0],
        ResolutionPreset.max,
        enableAudio: true,
      );

      // 5. 카메라 초기화 대기
      await _controller!.initialize();

      // 6. 포즈 감지기 재초기화
      await _initPoseDetector();

      if (!mounted) return;
      setState(() {});

      // 7. 자동 모드인 경우 이미지 스트림 시작
      if (_isAutoMode && mounted) {
        await Future.delayed(const Duration(milliseconds: 500)); // 안정화를 위한 대기
        await _controller!.startImageStream((image) {
          if (!_isProcessingFrame) {
            _isProcessingFrame = true;
            _processFrame(image);
          }
        });
      }
    } catch (e) {
      logger.e("카메라 전환 중 오류 발생: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('카메라 전환 중 오류가 발생했습니다')),
        );
      }
      // 오류 발생 시 카메라 재초기화 시도
      await Future.delayed(const Duration(seconds: 1));
      await _initCamera();
    }
  }

  // 카메라/마이크/저장소/GPS 권한 요청
  Future<bool> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.microphone.request();
    await Permission.storage.request();

    // GPS 서비스 활성화 확인
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        final bool? shouldOpenSettings = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('GPS 서비스 비활성화'),
            content:
                const Text('클라이밍장 위치 확인을 위해 GPS 서비스가 필요합니다.\n설정에서 활성화해주세요.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('설정으로 이동'),
              ),
            ],
          ),
        );
        if (shouldOpenSettings == true) {
          await Geolocator.openLocationSettings();
        }
      }
      return false;
    }

    // GPS 권한 확인 및 요청
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('위치 권한이 필요합니다')),
          );
        }
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        final bool? shouldOpenSettings = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('위치 권한 거부됨'),
            content:
                const Text('클라이밍장 위치 확인을 위해 위치 권한이 필요합니다.\n설정에서 권한을 허용해주세요.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('설정으로 이동'),
              ),
            ],
          ),
        );
        if (shouldOpenSettings == true) {
          await openAppSettings();
        }
      }
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: _controller != null
          ? Stack(
              children: [
                // 전체 화면 카메라 프리뷰
                AspectRatio(
                  aspectRatio: 1 / _controller!.value.aspectRatio,
                  child: CameraPreview(_controller!),
                ),
                // 상단 앱바
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.only(
                        top: 40, left: 16, right: 16, bottom: 8),
                    color: Colors.black.withOpacity(0.3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.photo_library,
                              color: Colors.white),
                          onPressed: () {
                            // 화면 전환 시 자동으로 dispose 되도록 함
                            if (mounted) {
                              context.go('/album');
                            }
                          },
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: _toggleMode,
                              child: Text(
                                _isAutoMode ? '자동' : '수동',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.help_outline,
                                  color: Colors.white),
                              onPressed: _showPoseGuide,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // 하단 컨트롤바
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
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
                          isRecording: isRecording,
                          onRecordPressed: _startManualRecording,
                          onStopPressed: _stopRecording,
                        ),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            color: selectedHold != null
                                ? ColorConverter.fromString(selectedHold!.color)
                                : Colors.transparent,
                          ),
                          child: IconButton(
                            icon:
                                const Icon(Icons.palette, color: Colors.white),
                            onPressed: _showColorPicker,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 상단 녹화 시간
                if (isRecording)
                  Positioned(
                    top: 30,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: RecordingIndicator(
                        duration: _recordingDuration.value,
                      ),
                    ),
                  ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  // ============= 수동 녹화 로직 =============
  Future<void> _startManualRecording() async {
    if (isRecording || _controller == null) return;

    // 색상이 선택되지 않은 경우 녹화 시작 불가
    if (selectedHold == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('색상을 먼저 선택해주세요')),
      );
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
      setState(() => isRecording = true);
      _recordingTimer?.cancel();
      _recordingDuration.value = Duration.zero;
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        _recordingDuration.value += const Duration(seconds: 1);
        // 20초 후 자동 종료
        if (_recordingDuration.value.inSeconds >= 20) {
          _stopManualRecording();
        }
      });

      await flutterTts.speak('녹화가 시작되었습니다');
      logger.i("녹화가 시작되었습니다.");
    } catch (e) {
      logger.e("녹화 시작 중 오류 발생: $e");
      setState(() => isRecording = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('녹화 시작 중 오류가 발생했습니다')),
      );
    }
  }

  Future<void> _stopManualRecording() async {
    if (!isRecording || _controller == null) return;

    try {
      final XFile video = await _controller!.stopVideoRecording();
      setState(() => isRecording = false);
      _recordingTimer?.cancel();
      _recordingDuration.value = Duration.zero;

      if (!mounted) return;

      // 마지막 녹화된 비디오 저장
      _lastRecordedVideo = video;

      // 자동 모드일 때만 TTS 실행
      if (_isAutoMode) {
        await flutterTts.speak('녹화가 종료되었습니다. O 또는 X 포즈로 성공 여부를 알려주세요');
        setState(() {
          _showGestureGuide = true; // O/X 선택 안내 표시
        });
      } else {
        // 수동 모드일 때는 바로 다이얼로그 표시
        _showManualSuccessDialog(true, video);
      }

      // 녹화 종료 후 자동 모드였다면 이미지 스트림 재시작
      if (_isAutoMode) {
        await _controller!.startImageStream((image) {
          if (!_isProcessingFrame) {
            _isProcessingFrame = true;
            _processFrame(image);
          }
        });
      }
    } catch (e) {
      logger.e("녹화 종료 중 오류 발생: $e");
      setState(() => isRecording = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('녹화 종료 중 오류가 발생했습니다')),
      );
    }
  }

  void _showManualSuccessDialog(bool isSuccess, XFile video) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => SuccessFailureDialog(video: video),
    );
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
        // 이미 스트리밍 중이면 중지
        if (isCurrentlyStreaming) {
          await _controller!.stopImageStream();
        }
        await Future.delayed(const Duration(milliseconds: 100));
        await _controller!.startImageStream((image) {
          if (!_isProcessingFrame) {
            _isProcessingFrame = true;
            _processFrame(image);
          }
        });
      } else {
        logger.d('수동 모드로 전환');
        // 스트리밍 중일 때만 중지
        if (isCurrentlyStreaming) {
          await _controller!.stopImageStream();
        }
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
        builder: (context) {
          return Container(
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
                          ref.read(selectedHoldProvider.notifier).state = hold;
                          setState(() {});
                          Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: ColorConverter.fromString(hold.color),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      );
    }
  }

  // ============= 카메라 프레임 -> 포즈 인식 =============
  Future<void> _processFrame(CameraImage image) async {
    try {
      if (_poseDetector == null) return;

      final poses = await _poseDetector!.processImage(
        image,
        _isFrontCamera,
        controller: _controller,
      );

      if (poses.isEmpty) {
        _isProcessingFrame = false;
        return;
      }

      final pose = poses.first;
      final poseViewModel = ref.read(poseViewModelProvider.notifier);

      // 녹화가 끝난 후 자동 모드에서만 O/X 제스처 감지
      if (!isRecording &&
          _lastRecordedVideo != null &&
          _isAutoMode &&
          _showGestureGuide) {
        if (poseViewModel.checkResultPose(pose)) {
          _handleOGesture();
          _lastRecordedVideo = null; // 처리 후 초기화
        } else if (poseViewModel.checkResultPose(pose)) {
          _handleXGesture();
          _lastRecordedVideo = null; // 처리 후 초기화
        }
      }

      // 기존의 다른 포즈 감지 로직...
    } catch (e) {
      logger.e('프레임 처리 중 오류 발생: $e');
    } finally {
      _isProcessingFrame = false;
    }
  }

  Future<void> _announceCurrentColor() async {
    try {
      final visitLogState = ref.read(visitLogViewModelProvider);

      // 상태가 로딩 중이거나 에러인 경우 처리
      if (visitLogState is AsyncLoading) {
        logger.d('방문 기록 로딩 중...');
        return;
      }

      if (visitLogState is AsyncError) {
        logger.e('방문 기록 에러: ${visitLogState.error}');
        return;
      }

      // 값이 없거나 holds가 비어있는 경우 처리
      if (visitLogState.value == null || visitLogState.value!.holds.isEmpty) {
        logger.d('사용 가능한 홀드가 없습니다.');
        return;
      }

      // 인덱스가 범위를 벗어난 경우 처리
      if (_currentColorIndex < 0) {
        _currentColorIndex = 0;
      } else if (_currentColorIndex >= visitLogState.value!.holds.length) {
        _currentColorIndex = visitLogState.value!.holds.length - 1;
      }

      final currentHold = visitLogState.value!.holds[_currentColorIndex];

      // TTS 실행 전 이전 음성 중지
      await flutterTts.stop();

      // 색상과 레벨 안내
      await flutterTts.speak('${currentHold.color} ${currentHold.level}');
      logger.d('현재 색상 안내: ${currentHold.color} ${currentHold.level}');
    } catch (e) {
      logger.e('음성 안내 중 오류 발생: $e');
      // 오류 발생 시 색상 선택 모드 초기화
      setState(() {
        _isSelectingColor = false;
        _currentColorIndex = -1;
        _colorSelectionStarted = false;
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
      await flutterTts.speak(TTSMessages.selectColor);
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
    });
    await flutterTts.speak(
        '${selectedColor.color} ${selectedColor.level} 선택되었습니다. 녹화를 시작하려면 양팔을 들어주세요.');
    logger.d('색상 선택 완료: ${selectedColor.color} ${selectedColor.level}');
  }

  Future<void> _stopRecording() async {
    try {
      if (!isRecording || _controller == null) return;

      // 녹화 중지 먼저 실행
      final XFile video = await _controller!.stopVideoRecording();

      // 녹화 상태 업데이트
      setState(() {
        isRecording = false;
      });

      // 타이머 정지
      _recordingTimer?.cancel();
      _recordingTimer = null;
      _recordingDuration.value = Duration.zero;

      // 성공/실패 선택 다이얼로그 표시
      _showSuccessFailureDialog(video);

      // 카메라 프리뷰 재시작
      if (_controller != null) {
        await _controller!.resumePreview();
      }
    } catch (e) {
      logger.e("녹화 종료 중 오류 발생: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('녹화 종료 중 오류가 발생했습니다')),
        );
      }
    }
  }

  void _showSuccessFailureDialog(XFile video) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => SuccessFailureDialog(video: video),
    );
  }

  // TTS 메시지 출력을 위한 헬퍼 함수
  Future<void> _speakMessage(String message) async {
    try {
      if (!mounted) return;

      // 이전 TTS가 실행 중이면 중지
      await flutterTts.stop();

      // 새로운 메시지 출력
      await flutterTts.speak(message);
      logger.d('TTS 메시지 출력: $message');
    } catch (e) {
      logger.e('TTS 에러: $e');
    }
  }

  // O/X 제스처 감지 시 처리
  void _handleOGesture() {
    setState(() {
      _showGestureGuide = false;
    });
    if (_lastRecordedVideo != null && mounted) {
      _showManualSuccessDialog(true, _lastRecordedVideo!);
    }
  }

  void _handleXGesture() {
    setState(() {
      _showGestureGuide = false;
    });
    if (_lastRecordedVideo != null && mounted) {
      _showManualSuccessDialog(false, _lastRecordedVideo!);
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
              '녹화 시작',
              '양손을 어깨 위로 들어올리세요 (만세 자세)',
              Icons.front_hand,
            ),
            const SizedBox(height: 20),
            _buildPoseGuideItem(
              '녹화 종료',
              '다시 양손을 어깨 위로 들어올리세요 (만세 자세)',
              Icons.front_hand,
            ),
            const SizedBox(height: 20),
            _buildPoseGuideItem(
              '성공 표시',
              '양팔로 O 모양을 만드세요',
              Icons.circle_outlined,
            ),
            const SizedBox(height: 20),
            _buildPoseGuideItem(
              '실패 표시',
              '양팔로 X 모양을 만드세요',
              Icons.close,
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
    return Row(
      children: [
        Icon(icon, size: 40),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(description, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _restartCameraController() async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }
    await _initCamera();
  }

  Widget _buildGestureGuideIcon({
    required IconData icon,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 40),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
