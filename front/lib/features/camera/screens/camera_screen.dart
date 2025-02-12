import 'dart:io';
import 'dart:async';
import 'dart:typed_data'; // <-- 추가
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/common/utils/color_converter.dart';
import 'package:kkulkkulk/features/camera/data/models/visit_log_model.dart';
import 'package:kkulkkulk/features/camera/view_models/visit_log_view_model.dart';
import 'package:kkulkkulk/features/camera/view_models/video_view_model.dart';
import 'package:logger/logger.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kkulkkulk/features/motionai/utils/pose_detector.dart'; // CustomPoseDetector
import 'package:kkulkkulk/features/motionai/view_models/pose_view_model.dart';

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

  Timer? _recordingTimer;
  final _recordingDuration = ValueNotifier<Duration>(Duration.zero);
  late final CustomPoseDetector _poseDetector;
  bool _isProcessingFrame = false;
  bool _isAutoMode = false; // 기본값: 수동 모드
  DateTime? _recordingStartTime;
  static const _minRecordingTime = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _initCamera();
    _initPoseDetector();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisitLog();
    });
  }

  Future<void> _checkVisitLog() async {
    // 방문 로그(클라이밍장 정보) 불러오기
    await ref.read(visitLogViewModelProvider.notifier).fetchVisitLog();
  }

  Future<void> _initPoseDetector() async {
    _poseDetector = await CustomPoseDetector.create();
  }

  Future<void> _initCamera() async {
    await _requestPermissions();
    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        _controller = CameraController(
          cameras![0],
          ResolutionPreset.medium,
          enableAudio: true,
          imageFormatGroup: ImageFormatGroup.yuv420, // Android에서 주로 사용
        );
        await _controller!.initialize();
        setState(() {});

        // 자동 모드일 때만 이미지 스트림 처리
        await _controller!.startImageStream((image) {
          if (_isAutoMode && !_isProcessingFrame) {
            _isProcessingFrame = true;
            _processFrame(image);
          }
        });
      }
    } catch (e) {
      logger.e("Camera initialization error: $e");
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
    _recordingTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _buildVideoWithOverlay(),
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
              icon: const Icon(Icons.photo_library,
                  color: Colors.white, size: 30),
              onPressed: () {
                final location = GoRouterState.of(context).uri.toString();
                if (location.contains('/album/camera')) {
                  context.pop();
                } else {
                  context.go('/album');
                }
              },
            ),
            _buildIOSRecordButton(),
            _buildModeToggleButton(),
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
    return GestureDetector(
      onTapDown: (_) => _isAutoMode ? null : _startManualRecording(),
      onTapUp: (_) => _isAutoMode ? null : _stopManualRecording(),
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
    if (isRecording) return;
    if (_controller == null) return;

    final visitLogState = ref.read(visitLogViewModelProvider);
    if (visitLogState is! AsyncData || visitLogState.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('클라이밍장 정보를 불러오는 중입니다.')),
      );
      return;
    }

    if (selectedHold == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('먼저 색상을 선택해주세요')),
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
      });
    } catch (e) {
      logger.e("Recording start error: $e");
      setState(() => isRecording = false);
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

      final bool? isSuccess = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('클라이밍 성공 여부'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('성공 😎'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, false),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('실패 😢'),
              ),
            ],
          ),
        ),
      );

      // 비디오 업로드
      if (isSuccess != null && selectedHold != null) {
        final visitLogState = ref.read(visitLogViewModelProvider);
        if (visitLogState is AsyncData && visitLogState.value != null) {
          try {
            await ref.read(videoViewModelProvider.notifier).uploadVideo(
                  videoFile: File(video.path),
                  color: selectedHold!.color,
                  isSuccess: isSuccess,
                  userDateId: visitLogState.value!.userDateId,
                  holdId: selectedHold!.id,
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
    } catch (e) {
      logger.e("Recording stop error: $e");
      setState(() => isRecording = false);
    }
  }

  // ============= 자동/수동 모드 전환 =============
  Widget _buildModeToggleButton() {
    return IconButton(
      icon: Icon(_isAutoMode ? Icons.auto_awesome : Icons.touch_app,
          color: Colors.white),
      onPressed: () {
        setState(() {
          _isAutoMode = !_isAutoMode;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isAutoMode ? '포즈 인식 모드' : '수동 모드'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
    );
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
    try {
      final sensorOrientation = _controller?.description.sensorOrientation;
      logger.d('Processing frame with sensor orientation: $sensorOrientation');

      final poses = await _poseDetector.processImage(
        image,
        sensorOrientation: sensorOrientation,
      );

      if (poses.isEmpty) {
        logger.d('포즈 감지되지 않음');
        return;
      }

      final pose = poses.first;
      logger.d('포즈 감지됨: ${pose.landmarks.length}개의 랜드마크');
      logger.d(
          '랜드마크 위치들: ${pose.landmarks.entries.map((e) => '${e.key}: (${e.value.x}, ${e.value.y})').join(', ')}');

      if (!isRecording) {
        // 시작 포즈 감지
        final isPoseValid =
            ref.read(poseViewModelProvider.notifier).checkStartPose(pose);
        if (isPoseValid) {
          logger.i('시작 포즈 감지 - 녹화 시작');
          await _startManualRecording();
          _recordingStartTime = DateTime.now();
        }
      } else {
        // 결과 포즈 감지
        final hasResult =
            ref.read(poseViewModelProvider.notifier).checkResultPose(pose);
        if (hasResult) {
          logger.i('결과 포즈 감지 - 녹화 종료');
          await _stopManualRecording();
          _showPoseResultDialog(ref.read(poseViewModelProvider));
        }
      }
    } catch (e, stackTrace) {
      logger.e('Frame processing error', error: e, stackTrace: stackTrace);
    } finally {
      _isProcessingFrame = false;
    }
  }

  void _showPoseResultDialog(bool isSuccess) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(isSuccess ? '성공! 🎉' : '실패... 😢'),
        content: Text(
          isSuccess ? '왼팔을 들어 성공으로 표시했습니다!' : '오른팔을 들어 실패로 표시했습니다.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
