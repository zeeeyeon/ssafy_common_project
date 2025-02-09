import 'package:flutter/material.dart';
import 'package:kkulkkulk/common/widgets/layout/custom_app_bar.dart';
import 'package:kkulkkulk/features/challenge/data/models/detail_challenge_response_model.dart';
import 'package:kkulkkulk/features/challenge/data/repositories/challenge_repository.dart';

class ChallengeDetailScreen extends StatefulWidget {
  final int climbGroundId;

  const ChallengeDetailScreen({super.key, required this.climbGroundId});
  
  @override
  _ChallengeDetailScreenState createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  late Future<DetailChallengeResponseModel> challengeDeatail;
  final ChallengeRepository _challengeRepository = ChallengeRepository();

  @override
  void initState() {
    super.initState();
    challengeDeatail = _challengeRepository.detailChallenge(widget.climbGroundId); // 클라이밍장 ID로 상세 정보 가져오기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '챌린지 상세 정보'
      ),
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: FutureBuilder<DetailChallengeResponseModel>(
          future: challengeDeatail,
          builder:(context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator()); // 로딩 중일 때
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}')); // 에러 발생 시
            } else if (!snapshot.hasData) {
              return Center(child: Text('장소 정보를 찾을 수 없습니다.'));
            } else {
              // 데이터를 가져왔을 때 화면에 출력
              DetailChallengeResponseModel place = snapshot.data!;
              return SingleChildScrollView(

              );
            }
          }),
      ),
    );
  }
  
}