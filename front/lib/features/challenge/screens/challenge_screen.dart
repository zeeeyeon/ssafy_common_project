import 'package:flutter/material.dart';
import 'package:kkulkkulk/common/widgets/layout/custom_app_bar.dart';
import 'package:kkulkkulk/common/widgets/feedback/error_view.dart';
import 'package:kkulkkulk/common/widgets/list/challenge_list.dart';
import 'package:kkulkkulk/common/exceptions/exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/features/challenge/view_models/challenge_view_model.dart';

class ChallengeScreen extends ConsumerWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: '챌린지',
        showBackButton: false,
      ),
      body: ref.watch(challengeProvider).when(
            data: (challenges) {
              if (challenges.isEmpty) {
                return const ErrorView(
                  type: ErrorType.empty,
                  message: '참여 중인 챌린지가 없습니다',
                );
              }
              return ChallengeList(challenges: challenges);
            },
            error: (error, stackTrace) {
              if (error is NetworkException) {
                return ErrorView(
                  type: ErrorType.network,
                  onRetry: () => ref.refresh(challengeProvider),
                );
              }
              if (error is ServerException) {
                return const ErrorView(type: ErrorType.server);
              }
              return const ErrorView(type: ErrorType.unknown);
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
    );
  }
}
