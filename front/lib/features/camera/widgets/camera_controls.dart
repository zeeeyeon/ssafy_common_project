import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CameraControls extends ConsumerWidget {
  final VoidCallback onRecordPressed;
  final VoidCallback onStopPressed;
  final bool isRecording;

  const CameraControls({
    required this.onRecordPressed,
    required this.onStopPressed,
    required this.isRecording,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: isRecording ? onStopPressed : onRecordPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isRecording ? 70 : 80,
        height: isRecording ? 70 : 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: isRecording ? 4 : 6,
          ),
        ),
        child: Container(
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isRecording ? Colors.red : Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
} 