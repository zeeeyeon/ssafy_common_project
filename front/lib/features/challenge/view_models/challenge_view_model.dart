import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/features/challenge/data/models/challenge_model.dart';
import 'package:kkulkkulk/features/challenge/data/repositories/challenge_repository.dart';

final challengeRepositoryProvider = Provider((ref) => ChallengeRepository());

final challengeProvider = FutureProvider<List<ChallengeModel>>((ref) async {
  final repository = ref.watch(challengeRepositoryProvider);
  return repository.getChallenges();
});
