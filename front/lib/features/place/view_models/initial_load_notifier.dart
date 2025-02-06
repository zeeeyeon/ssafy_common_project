import 'package:flutter_riverpod/flutter_riverpod.dart';

class InitialLoadNotifier extends StateNotifier<bool> {
  InitialLoadNotifier() : super(false);

  void setLoaded() => state = true;  // 로딩 완료 상태로 변경
}

final initialLoadProvider = StateNotifierProvider<InitialLoadNotifier, bool>((ref) {
  return InitialLoadNotifier();
});
