import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../providers/camera_providers.dart' as camera;
import '../view_models/video_view_model.dart';
import '../view_models/visit_log_view_model.dart';

class SuccessFailureDialog extends ConsumerWidget {
  final XFile video;

  const SuccessFailureDialog({
    required this.video,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoActionSheet(
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
      actions: [
        CupertinoActionSheetAction(
          onPressed: () => _handleResult(context, ref, true),
          child: const Text(
            '성공',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () => _handleResult(context, ref, false),
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
        onPressed: () => Navigator.pop(context),
        child: const Text(
          '취소',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _handleResult(
      BuildContext context, WidgetRef ref, bool isSuccess) async {
    Navigator.pop(context);

    final selectedHold = ref.read(camera.selectedHoldProvider.notifier).state;
    if (selectedHold == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("선택된 홀드가 없습니다.")),
        );
      }
      return;
    }

    final visitLogState = ref.read(visitLogViewModelProvider);
    if (visitLogState is AsyncData && visitLogState.value != null) {
      try {
        await ref.read(videoViewModelProvider.notifier).uploadVideo(
              videoFile: File(video.path),
              color: selectedHold.color,
              isSuccess: isSuccess,
              userDateId: visitLogState.value!.userDateId,
              holdId: selectedHold.id,
            );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('영상이 업로드되었습니다')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('영상 업로드 실패: $e')),
          );
        }
      }
    }
  }
}
