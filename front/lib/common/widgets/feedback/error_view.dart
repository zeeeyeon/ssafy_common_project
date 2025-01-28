import 'package:flutter/material.dart';

enum ErrorType {
  network('인터넷 연결을 확인해주세요'),
  server('서버에 문제가 발생했습니다'),
  empty('데이터가 없습니다'),
  unknown('알 수 없는 오류가 발생했습니다');

  final String message;
  const ErrorType(this.message);
}

class ErrorView extends StatelessWidget {
  final ErrorType type;
  final String? message;
  final VoidCallback? onRetry;

  const ErrorView({
    super.key,
    required this.type,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIcon(),
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              message ?? type.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('다시 시도'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.server:
        return Icons.error_outline;
      case ErrorType.empty:
        return Icons.inbox;
      case ErrorType.unknown:
        return Icons.help_outline;
    }
  }
}
