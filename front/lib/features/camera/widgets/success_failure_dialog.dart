import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:kkulkkulk/features/camera/view_models/video_view_model.dart';
import 'package:kkulkkulk/features/camera/view_models/visit_log_view_model.dart';
import 'package:kkulkkulk/features/camera/data/models/hold_model.dart';
import 'package:flutter/cupertino.dart';

class SuccessFailureDialog extends ConsumerWidget {
  final XFile video;
  final Hold selectedHold;
  final VoidCallback? onResultSelected;

  const SuccessFailureDialog({
    Key? key,
    required this.video,
    required this.selectedHold,
    this.onResultSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoActionSheet(
      title: const Text(
        '등반 결과',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      message: const Text(
        '이번 등반을 성공하셨나요?',
        style: TextStyle(
          fontSize: 15,
          color: Colors.grey,
        ),
      ),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () async {
            await _handleResult(context, ref, true);
            onResultSelected?.call();
          },
          child: const Text(
            '성공',
            style: TextStyle(color: Colors.blue),
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () async {
            await _handleResult(context, ref, false);
            onResultSelected?.call();
          },
          child: const Text(
            '실패',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('취소'),
      ),
    );
  }

  Future<void> _handleResult(
      BuildContext context, WidgetRef ref, bool isSuccess) async {
    final visitLogState = ref.read(visitLogViewModelProvider);

    if (visitLogState is! AsyncData || visitLogState.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('방문 기록을 불러올 수 없습니다.')),
      );
      return;
    }

    try {
      await ref.read(videoViewModelProvider.notifier).uploadVideo(
            videoFile: File(video.path),
            color: selectedHold.color,
            isSuccess: isSuccess,
            userDateId: visitLogState.value!.userDateId,
            holdId: selectedHold.id,
          );

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isSuccess ? '성공으로 기록되었습니다!' : '실패로 기록되었습니다.'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('업로드 실패: $e')),
        );
      }
    }
  }
}
