import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  final Function(String imagePath) onImageCaptured; // 이미지 경로 콜백

  const CameraScreen({super.key, required this.onImageCaptured});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  /// 🔥 카메라 초기화
  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras!.isNotEmpty) {
      _controller = CameraController(_cameras![0], ResolutionPreset.medium);
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    }
  }

  /// 🔥 사진 촬영
  Future<void> _captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final image = await _controller!.takePicture();
      widget.onImageCaptured(image.path); // ✅ 이미지 경로 콜백 전달
      Navigator.pop(context); // 촬영 후 화면 닫기
    } catch (e) {
      debugPrint("❌ 사진 촬영 실패: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isCameraInitialized
          ? Stack(
              children: [
                CameraPreview(_controller!), // 카메라 프리뷰
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FloatingActionButton(
                      onPressed: _captureImage,
                      child: const Icon(Icons.camera),
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()), // 로딩 상태
    );
  }
}
