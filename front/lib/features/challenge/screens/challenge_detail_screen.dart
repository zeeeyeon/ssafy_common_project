import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kkulkkulk/common/widgets/layout/custom_app_bar.dart';
import 'package:kkulkkulk/features/challenge/data/models/detail_challenge_response_model.dart';
import 'package:kkulkkulk/features/challenge/data/repositories/challenge_repository.dart';
import 'package:kkulkkulk/features/place/components/dounut_chart.dart';

class ChallengeDetailScreen extends StatefulWidget {
  final int climbGroundId;

  const ChallengeDetailScreen({super.key, required this.climbGroundId});
  
  @override
  _ChallengeDetailScreenState createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> with TickerProviderStateMixin {
  late Future<DetailChallengeResponseModel> challengeDeatail;
  final ChallengeRepository _challengeRepository = ChallengeRepository();
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    challengeDeatail = _challengeRepository.detailChallenge(widget.climbGroundId); // 클라이밍장 ID로 상세 정보 가져오기

    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '챌린지 상세 정보',
        showBackButton: true,
        onBackPressed: () {
          context.go('/challenge');
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: FutureBuilder<DetailChallengeResponseModel>(
          future: challengeDeatail,
          builder: (context, snapshot) {
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.network(
                      place.imageUrl,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.fill,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            '${place.name}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${place.address}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey
                            ),
                          ),
                          SizedBox(height: 30,),

                          // Wrapping the Image in AnimatedBuilder to apply the animation
                          AnimatedBuilder(
                            animation: _animation,
                            builder: (context, child) {
                              return Transform(
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.004)
                                  ..rotateY(pi * 2.0 * _animation.value),
                                alignment: Alignment.center,
                                child: child,
                              );
                            },
                            child: Image.asset('assets/challenge/${place.medal}.png'),
                          ),
                          SizedBox(height: 20),
                          Text(
                            '${place.medal}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            '${place.tryCount}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${place.success}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${place.successRate}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),

                          // DonutChart widget 추가
                          DonutChart(
                            radius: 50,
                            strokeWidth: 10,
                            total: 127.0,
                            value: 63.0,
                            child: Center(
                              child: Text(
                                '${place.success}%',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 21,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          }
        ),
      ),
    );
  }
}
