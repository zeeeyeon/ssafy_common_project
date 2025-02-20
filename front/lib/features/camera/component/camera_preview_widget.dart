import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'recording_indicator.dart';

class CameraPreviewWidget extends ConsumerWidget {
  final CameraController controller;
  final bool isRecording;
  final Duration recordingDuration;

  const CameraPreviewWidget({
    required this.controller,
    required this.isRecording,
    required this.recordingDuration,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 만약 front 카메라라면 미러링 적용
    Widget preview = CameraPreview(controller);
    if (controller.description.lensDirection == CameraLensDirection.front) {
      preview = Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(pi).scaled(-1.0, 1.0, 1.0),
        child: preview,
      );
    }

    return Stack(
      children: [
        preview,
        if (isRecording)
          Positioned(
            top: 16,
            right: 16,
            child: RecordingIndicator(duration: recordingDuration),
          ),
      ],
    );
  }
}
