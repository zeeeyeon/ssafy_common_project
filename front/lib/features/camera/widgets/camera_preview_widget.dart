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
    return Stack(
      children: [
        CameraPreview(controller),
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