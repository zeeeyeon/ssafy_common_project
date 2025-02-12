import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/features/camera/data/models/hold_model.dart';

final selectedHoldProvider = StateProvider<Hold?>((ref) => null);
final currentTabProvider = StateProvider<int>((ref) => 0);
