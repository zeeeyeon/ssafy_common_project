import 'dart:io';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:kkulkkulk/common/utils/color_converter.dart';
import 'package:kkulkkulk/features/camera/data/models/visit_log_model.dart';
import 'package:kkulkkulk/features/camera/view_models/visit_log_view_model.dart';
import 'package:kkulkkulk/features/camera/view_models/video_view_model.dart';
import 'package:logger/logger.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kkulkkulk/features/motionai/utils/pose_detector.dart'; // CustomPoseDetector
import 'package:kkulkkulk/features/motionai/view_models/pose_view_model.dart';
import 'package:flutter_tts/flutter_tts.dart';

final logger = Logger();

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
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

  @override
  void initState() {
    super.initState();
    _initCamera();
    _initTTS();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisitLog();
    });
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
  }

  Future<void> _initCamera() async {
    await _requestPermissions();
    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        if (_controller != null) {
          await _controller!.dispose();
        }

        _controller = CameraController(
          cameras![_isFrontCamera ? 1 : 0],
          ResolutionPreset.medium,
          enableAudio: true,
          imageFormatGroup: ImageFormatGroup.nv21,
        );

        await _controller!.initialize();
        await _initPoseDetector();

        if (mounted) {
          setState(() {});
        }

        if (_isAutoMode) {
          await _controller!.startImageStream((image) {
            if (!_isProcessingFrame) {
              _isProcessingFrame = true;
              _processFrame(image);
            }
          });
        }
      }
    } catch (e) {
      logger.e("Camera initialization error: $e");
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
        ResolutionPreset.medium,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.nv21,
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
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    final visitLogState = ref.watch(visitLogViewModelProvider);
    final holds = visitLogState.value?.holds ?? [];

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          _buildVideoWithOverlay(),

          // 상단 앱바
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.photo_library, color: Colors.white),
                      onPressed: () {
                        final location =
                            GoRouterState.of(context).uri.toString();
                        if (location.contains('/album/camera')) {
                          context.pop();
                        } else {
                          context.go('/album');
                        }
                      },
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _toggleMode(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _isAutoMode
                                      ? Icons.auto_awesome
                                      : Icons.touch_app,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _isAutoMode ? '자동' : '수동',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
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
          ),

          // 색상 선택 상태 표시
          if (_isSelectingColor &&
              _currentColorIndex >= 0 &&
              _currentColorIndex < holds.length)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _colorSelectionStarted
                        ? '원하는 색상에서 오른팔을 들어주세요\n왼팔을 들면 초기화됩니다'
                        : '색상 선택을 시작합니다',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(2.0, 2.0),
                          blurRadius: 3.0,
                          color: Colors.black,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: ColorConverter.fromString(
                          holds[_currentColorIndex].color),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${holds[_currentColorIndex].color} ${holds[_currentColorIndex].level}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(2.0, 2.0),
                          blurRadius: 3.0,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // 안내 메시지 (수동 모드에서는 표시하지 않음)
          if (_isAutoMode && !_isSelectingColor)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    selectedHold == null
                        ? '오른팔을 들어 색상을 선택해주세요'
                        : '양팔을 들어 녹화를 시작하세요',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(
                Icons.flip_camera_ios_rounded,
                color: Colors.white,
                size: 30,
              ),
              onPressed: _toggleCamera,
            ),
            _buildIOSRecordButton(),
            GestureDetector(
              onTap: _showColorPicker,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selectedHold != null
                      ? ColorConverter.fromString(selectedHold!.color)
                      : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoWithOverlay() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(
      children: [
        Positioned.fill(
          child: CameraPreview(_controller!),
        ),
        Positioned(
          top: 30,
          left: 0,
          right: 0,
          child: Center(child: _buildRecordingTimer()),
        ),
      ],
    );
  }

  Widget _buildRecordingTimer() {
    return ValueListenableBuilder<Duration>(
      valueListenable: _recordingDuration,
      builder: (context, duration, child) {
        if (!isRecording) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                _formatDuration(duration),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Widget _buildIOSRecordButton() {
    return InkWell(
      onTap: () {
        if (_isAutoMode) return;

        if (isRecording) {
          _stopRecording();
        } else {
          _startManualRecording();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isRecording ? 70 : 80,
        height: isRecording ? 70 : 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _isAutoMode ? Colors.grey : Colors.white,
            width: isRecording ? 4 : 6,
          ),
        ),
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isRecording
                    ? Colors.red
                    : (_isAutoMode ? Colors.grey : Colors.white),
                shape: BoxShape.circle,
              ),
            ),
            if (_isAutoMode)
              const Center(
                child: Icon(Icons.auto_awesome, color: Colors.white, size: 24),
              ),
          ],
        ),
      ),
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

      // 자동 모드일 때만 TTS 실행
      if (_isAutoMode) {
        await flutterTts.speak('녹화가 종료되었습니다. O 또는 X 포즈로 성공 여부를 알려주세요');
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

      // 수동 모드일 때는 항상 모달 표시, 자동 모드일 때는 포즈 인식 사용
      if (!_isAutoMode) {
        await _showManualSuccessDialog(video);
      }
    } catch (e) {
      logger.e("녹화 종료 중 오류 발생: $e");
      setState(() => isRecording = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('녹화 종료 중 오류가 발생했습니다')),
      );
    }
  }

  Future<void> _handleRecordingComplete(XFile video, bool isSuccess) async {
    try {
      logger.d('녹화 완료 처리 시작 - 성공여부: $isSuccess');

      final visitLogState = ref.read(visitLogViewModelProvider);
      if (visitLogState.value == null) {
        logger.e('방문 기록이 없습니다.');
        return;
      }

      final selectedHold = ref.read(selectedHoldProvider);
      if (selectedHold == null) {
        logger.e('선택된 홀드가 없습니다.');
        return;
      }

      logger.d(
          '비디오 업로드 시작 - userDateId: ${visitLogState.value!.userDateId}, holdId: ${selectedHold.id}');

      await ref.read(videoViewModelProvider.notifier).uploadVideo(
            videoFile: File(video.path),
            color: selectedHold.color,
            isSuccess: isSuccess,
            userDateId: visitLogState.value!.userDateId,
            holdId: selectedHold.id,
          );

      logger.d('비디오 업로드 완료');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('영상이 ${isSuccess ? '성공' : '실패'}으로 저장되었습니다')),
        );
      }
    } catch (e) {
      logger.e('녹화 완료 처리 중 오류 발생: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('영상 저장에 실패했습니다')),
        );
      }
    }
  }

  Future<void> _showManualSuccessDialog(XFile video) async {
    return showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text(
          '등반 결과',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        message: const Text(
          '이번 등반을 성공하셨나요?',
          style: TextStyle(
            fontSize: 15,
            color: Colors.black54,
          ),
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _handleRecordingComplete(video, true);
            },
            child: const Text(
              '성공',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _handleRecordingComplete(video, false);
            },
            child: const Text(
              '실패',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            '취소',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
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
    if (visitLogState is! AsyncData || visitLogState.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('클라이밍장 정보를 불러오는 중입니다.')),
      );
      return;
    }

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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: holds.length,
                  itemBuilder: (context, index) {
                    final hold = holds[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedHold = hold);
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

  // ============= 카메라 프레임 -> 포즈 인식 =============
  Future<void> _processFrame(CameraImage image) async {
    if (!mounted ||
        _controller == null ||
        !_isAutoMode ||
        _poseDetector == null) return;

    try {
      final poses = await _poseDetector!.processImage(
        image,
        _isFrontCamera,
        controller: _controller,
      );

      if (!mounted || poses.isEmpty) return;

      final pose = poses.first;
      final visitLogState = ref.read(visitLogViewModelProvider);

      if (visitLogState is AsyncData && visitLogState.value != null) {
        final holds = visitLogState.value!.holds;

        // 1. 색상 선택 모드
        if (selectedHold == null) {
          if (!_isSelectingColor) {
            // 오른팔을 들어서 색상 선택 시작
            if (ref
                .read(poseViewModelProvider.notifier)
                .checkColorSelectPose(pose)) {
              _startColorSelection();
            }
          } else {
            // 만세 자세로 현재 색상 선택
            if (ref.read(poseViewModelProvider.notifier).checkStartPose(pose)) {
              if (_currentColorIndex >= 0 &&
                  _currentColorIndex < holds.length) {
                _confirmColorSelection(holds[_currentColorIndex]);
                // 색상 선택 후 바로 녹화 시작
                await _startManualRecording();
              }
            }
          }
          return;
        }

        // 2. 녹화 중일 때 종료 포즈 체크
        if (isRecording) {
          if (ref.read(poseViewModelProvider.notifier).checkEndPose(pose)) {
            await _stopRecording();
          }
          return;
        }

        // 3. 녹화 종료 후 O/X 포즈 체크
        if (!isRecording && _lastRecordedVideo != null) {
          final poseViewModel = ref.read(poseViewModelProvider.notifier);
          if (poseViewModel.checkResultPose(pose)) {
            final leftArmAngle = poseViewModel.getLastLeftArmAngle();
            final rightArmAngle = poseViewModel.getLastRightArmAngle();

            // O 모양 판정 (70~110도)
            final isOShape = (leftArmAngle >= 70 && leftArmAngle <= 110) &&
                (rightArmAngle >= 70 && rightArmAngle <= 110);

            // 성공/실패 여부에 따른 처리
            await _handleRecordingComplete(_lastRecordedVideo!, isOShape);
            _lastRecordedVideo = null;

            // 스낵바 표시
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

  void _resetColorSelection() {
    setState(() {
      _isSelectingColor = false;
      _currentColorIndex = -1;
      _colorSelectionStarted = false;
    });
    _colorSelectionTimer?.cancel();
    if (_isAutoMode) {
      flutterTts.speak('색상 선택이 초기화되었습니다.');
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
      await flutterTts.speak('색상 선택을 시작합니다. 원하시는 색상이 나오면 왼팔을 들어 선택해주세요.');
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
      logger.d('녹화 종료 시작');
      if (!isRecording) {
        logger.d('이미 녹화가 종료된 상태입니다.');
        return;
      }

      await _controller?.stopVideoRecording().then((XFile? file) async {
        logger.d('녹화 파일 생성 완료: ${file?.path}');
        setState(() {
          isRecording = false;
          _lastRecordedVideo = file;
        });

        if (file != null) {
          logger.d('녹화 파일이 존재합니다. 업로드 프로세스 시작');
          if (_isAutoMode) {
            logger.d('자동 모드: O/X 포즈 인식 대기');
            // 자동 모드에서는 O/X 포즈 인식 후 업로드
            _startPoseDetectionAfterRecording(file);
          } else {
            logger.d('수동 모드: 성공/실패 선택 모달 표시');
            // 수동 모드에서는 모달로 선택
            _showManualSuccessDialog(file);
          }
        } else {
          logger.e('녹화 파일이 null입니다.');
        }
      });

      // 녹화 타이머 정리
      _recordingTimer?.cancel();
      _recordingTimer = null;
      _recordingDuration.value = Duration.zero;
    } catch (e) {
      logger.e('녹화 종료 중 오류 발생: $e');
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

  Future<void> _startPoseDetectionAfterRecording(XFile video) async {
    try {
      logger.d('녹화 후 포즈 인식 시작');
      await flutterTts.speak('녹화가 종료되었습니다. O 또는 X 포즈로 성공 여부를 알려주세요');

      // 이미지 스트림 재시작
      await _controller?.startImageStream((image) {
        if (!_isProcessingFrame) {
          _isProcessingFrame = true;
          _processOXPoseFrame(image, video);
        }
      });
    } catch (e) {
      logger.e('포즈 인식 시작 중 오류 발생: $e');
    }
  }

  Future<void> _processOXPoseFrame(CameraImage image, XFile video) async {
    try {
      if (_poseDetector == null || !mounted) {
        _isProcessingFrame = false;
        return;
      }

      final poses = await _poseDetector!.processImage(
        image,
        _isFrontCamera,
        controller: _controller,
      );

      if (poses.isNotEmpty) {
        final pose = poses.first;
        if (ref.read(poseViewModelProvider.notifier).checkResultPose(pose)) {
          // O/X 포즈가 감지되면
          final leftArmAngle =
              ref.read(poseViewModelProvider.notifier).getLastLeftArmAngle();
          final rightArmAngle =
              ref.read(poseViewModelProvider.notifier).getLastRightArmAngle();

          logger.d('O/X 포즈 감지됨 - 왼팔 각도: $leftArmAngle, 오른팔 각도: $rightArmAngle');

          // O 포즈 (성공)
          bool isSuccess = leftArmAngle >= 70 &&
              leftArmAngle <= 110 &&
              rightArmAngle >= 70 &&
              rightArmAngle <= 110;

          // 이미지 스트림 중지
          await _controller?.stopImageStream();

          // 녹화 파일 처리
          await _handleRecordingComplete(video, isSuccess);
        }
      }
    } catch (e) {
      logger.e('포즈 프레임 처리 중 오류 발생: $e');
    } finally {
      _isProcessingFrame = false;
    }
  }
}
