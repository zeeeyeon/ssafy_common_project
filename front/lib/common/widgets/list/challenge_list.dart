import 'package:flutter/material.dart';
import 'package:kkulkkulk/features/challenge/data/models/challenge_model.dart';

class ChallengeList extends StatelessWidget {
  final List<ChallengeModel> challenges;

  const ChallengeList({
    super.key,
    required this.challenges,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        return ListTile(
          title: Text(challenge.title),
          subtitle: Text(challenge.description),
          onTap: () {
            // TODO: 챌린지 상세 페이지로 이동
          },
        );
      },
    );
  }
}
