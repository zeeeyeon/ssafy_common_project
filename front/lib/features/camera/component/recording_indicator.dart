import 'package:flutter/material.dart';

class RecordingIndicator extends StatelessWidget {
  final Duration duration;

  const RecordingIndicator({
    required this.duration,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.fiber_manual_record,
            color: Colors.red,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
} 