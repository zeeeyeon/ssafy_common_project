import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CameraScreen extends StatefulWidget {
  final Function(String) onImageCaptured;

  const CameraScreen({super.key, required this.onImageCaptured});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isTakingPicture = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  /// 🔥 카메라 초기화
  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras!.first,
          ResolutionPreset.medium,
        );

        await _cameraController!.initialize();
        if (!mounted) return;
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("❌ [ERROR] 카메라 초기화 실패: $e");
    }
  }

  /// 📸 사진 촬영
  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      debugPrint("❌ [ERROR] 카메라가 초기화되지 않음");
      return;
    }

    if (_isTakingPicture) {
      debugPrint("⚠️ [WARNING] 이미 촬영 중...");
      return;
    }

    setState(() {
      _isTakingPicture = true;
    });

    try {
      final XFile image = await _cameraController!.takePicture();

      if (image.path.isEmpty) {
        debugPrint("❌ [ERROR] 촬영된 이미지의 경로가 비어 있음");
        return;
      }

      // 📂 저장할 경로 설정
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath =
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // 📂 파일 이동 (rename 사용)
      final File savedImage = File(image.path);
      final File newImage = await savedImage.rename(filePath);

      // ✅ 파일이 정상적으로 저장되었는지 확인
      if (newImage.existsSync()) {
        debugPrint(
            "✅ [CHECK] 파일 저장 완료: $filePath (${newImage.lengthSync()} bytes)");
      } else {
        debugPrint("❌ [ERROR] 파일 저장 실패: $filePath");
      }

      // 📤 콜백 함수로 이미지 경로 전달 후 화면 닫기
      widget.onImageCaptured(filePath);
      Navigator.pop(context);
    } catch (e) {
      debugPrint("❌ [ERROR] 사진 촬영 실패: $e");
    }

    setState(() {
      _isTakingPicture = false;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isCameraInitialized
          ? Stack(
              children: [
                CameraPreview(_cameraController!),
                Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: FloatingActionButton(
                      onPressed: _takePicture,
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.camera,
                          color: Colors.black, size: 30),
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
