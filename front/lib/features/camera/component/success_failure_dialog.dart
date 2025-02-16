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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events_rounded,
              size: 60,
              color: Colors.amber,
            ),
            const SizedBox(height: 16),
            const Text(
              '등반 결과',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '이번 등반을 성공하셨나요?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton(
                  context: context,
                  ref: ref,
                  isSuccess: true,
                  icon: Icons.check_circle_outline,
                  label: '성공',
                  color: Colors.green,
                ),
                _buildButton(
                  context: context,
                  ref: ref,
                  isSuccess: false,
                  icon: Icons.cancel_outlined,
                  label: '실패',
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                '취소',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required WidgetRef ref,
    required bool isSuccess,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: () async {
        await _handleResult(context, ref, isSuccess);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: color),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Future<void> _handleResult(
      BuildContext context, WidgetRef ref, bool isSuccess) async {
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
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isSuccess ? '성공으로 기록되었습니다!' : '실패로 기록되었습니다.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('업로드에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    }
  }
}
