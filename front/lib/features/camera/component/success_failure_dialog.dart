import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:kkulkkulk/features/camera/view_models/video_view_model.dart';
import 'package:kkulkkulk/features/camera/view_models/visit_log_view_model.dart';
import 'package:kkulkkulk/features/camera/data/models/hold_model.dart';
import 'package:kkulkkulk/features/camera/providers/camera_providers.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class SuccessFailureDialog extends ConsumerWidget {
  final XFile video;
  final Hold selectedHold;
  final Future<void> Function(bool isSuccess) onResultSelected;

  const SuccessFailureDialog({
    Key? key,
    required this.video,
    required this.selectedHold,
    required this.onResultSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 300,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('assets/character/level3.png'),
                backgroundColor: Colors.transparent,
              ),
              const SizedBox(height: 16),
              const Text(
                '등반 결과',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '이번 등반을 성공하셨나요?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildDialogButton(context, ref, true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDialogButton(context, ref, false)),
                ],
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  '취소',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogButton(
      BuildContext context, WidgetRef ref, bool isSuccess) {
    final Color color = isSuccess ? Colors.green : Colors.red;
    return OutlinedButton(
      onPressed: () async {
        await _handleResult(context, ref, isSuccess);
      },
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(
        isSuccess ? '성공' : '실패',
        style:
            TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: color),
      ),
    );
  }

  Future<void> _handleResult(
      BuildContext context, WidgetRef ref, bool isSuccess) async {
    Navigator.pop(context);

    try {
      final selectedHold = ref.read(selectedHoldProvider);
      if (selectedHold == null) {
        throw Exception('선택된 홀드 정보가 없습니다.');
      }

      final visitLogState = ref.read(visitLogViewModelProvider);
      if (visitLogState is! AsyncData || visitLogState.value == null) {
        throw Exception('방문 기록을 불러올 수 없습니다.');
      }

      await ref.read(videoViewModelProvider.notifier).uploadVideo(
            videoFile: File(video.path),
            color: selectedHold.color,
            isSuccess: isSuccess,
            userDateId: visitLogState.value!.userDateId,
            holdId: selectedHold.id,
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isSuccess ? '성공으로 기록되었습니다!' : '실패로 기록되었습니다.',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('업로드에 실패했습니다. 다시 시도해주세요.'),
          ),
        );
      }
    }
  }
}
