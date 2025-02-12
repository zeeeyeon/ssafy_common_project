import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kkulkkulk/common/widgets/layout/custom_app_bar.dart';
import 'package:kkulkkulk/features/challenge/data/models/detail_challenge_response_model.dart';
import 'package:kkulkkulk/features/challenge/data/repositories/challenge_repository.dart';
import 'package:kkulkkulk/features/challenge/components/dounut_chart.dart';

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

  // 메달 색상을 반환하는 함수
Color _getMedalColor(String medal) {
  switch (medal.toUpperCase()) { // 대소문자 구분 방지
    case 'GOLD':
      return Color(0xFFFFD700); // 금색
    case 'SILVER':
      return Color(0xFFB0B0B0); // 은색
    case 'BRONZE':
      return Color(0xFFCD7F32); // 동색
    default:
      return Color(0xFF8B4513); // NONE일 때 
  }
}

// DonutChart에 사용할 색상을 반환하는 함수
  Color _getDonutChartColor(String medal) {
    return _getMedalColor(medal); // 메달 색상과 동일한 색상 반환
  }

// 메달에 반짝이는 효과를 추가하는 함수
List<Shadow> _getMedalShadow(String medal) {
  switch (medal.toUpperCase()) {
    case 'GOLD':
      return [
        Shadow(
          offset: Offset(2, 2),
          blurRadius: 15,
          color: Color(0xFFFFD700).withOpacity(0.8), // 금색 반짝임 효과
        ),
        Shadow(
          offset: Offset(-2, -2),
          blurRadius: 10,
          color: Color(0xFFFFE700).withOpacity(0.6), // 금색 빛나는 느낌 추가
        ),
        
      ];
    case 'SILVER':
      return [
        Shadow(
          offset: Offset(2, 2),
          blurRadius: 15,
          color: Color(0xFFC0C0C0).withOpacity(0.8), // 은색 반짝임 효과
        ),
        Shadow(
          offset: Offset(-2, -2),
          blurRadius: 10,
          color: Color(0xFFB0B0B0).withOpacity(0.6), // 은색 빛나는 느낌 추가
        ),
      ];
    case 'BRONZE':
      return [
        Shadow(
          offset: Offset(2, 2),
          blurRadius: 15,
          color: Color(0xFFCD7F32).withOpacity(0.8), // 동색 반짝임 효과
        ),
        Shadow(
          offset: Offset(-2, -2),
          blurRadius: 10,
          color: Color(0xFFB57B5A).withOpacity(0.6), // 동색의 밝은 효과
        ),
      ];
    case 'NONE':
      return [
        Shadow(
          offset: Offset(2, 2),
          blurRadius: 10,
          color: Color(0xFF8B4513).withOpacity(0.7), // 나무색 그림자 효과
        ),
        Shadow(
          offset: Offset(-2, -2),
          blurRadius: 5,
          color: Color(0xFF8B4513).withOpacity(0.6), // 나무색의 빛나는 느낌
        ),
      ];
    default:
      return []; // 반짝임 효과가 필요 없는 경우
  }
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
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 20,),
                          Stack(
                            children: [
                              // place.medal 텍스트를 화면 정중앙에 배치
                              Center(
                                child: Text(
                                  '${place.medal}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: _getMedalColor(place.medal),
                                    shadows: _getMedalShadow(place.medal),
                                  ),
                                ),
                              ),
                              // 우측에 + 버튼 배치
                              Positioned(
                                right: 0,
                                top: -8,
                                child: IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    // 모달을 띄우는 코드
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,  // 이 설정으로 모달의 크기를 자동으로 맞춤
                                      builder: (context) {
                                        return Container(
                                          width: double.infinity,  // 가로가 화면 전체로 확장됨
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '볼더 광물 획득 기준',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Image.asset(
                                                    'assets/challenge/GOLD.png',
                                                    width: 50,
                                                    height: 50,
                                                  ),
                                                  Text(
                                                    '시도 횟수 5회 이상 및 성공률 50% 달성',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Image.asset(
                                                    'assets/challenge/SILVER.png',
                                                    width: 50,
                                                    height: 50,
                                                  ),
                                                  Text(
                                                    '시도 횟수 5회 이상',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Image.asset(
                                                    'assets/challenge/BRONZE.png',
                                                    width: 50,
                                                    height: 50,
                                                  ),
                                                  Text(
                                                    '시도 횟수 1회 이상',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Image.asset(
                                                    'assets/challenge/NONE.png',
                                                    width: 50,
                                                    height: 50,
                                                  ),
                                                  Text(
                                                    '최초 해금 시',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 60),
                          SizedBox(
                            width: 300,
                            child: DonutChart(
                              radius: 10,
                              strokeWidth: 10,
                              total: place.tryCount.toDouble(),
                              value: place.success.toDouble(),
                              progressColor: _getDonutChartColor(place.medal),
                              child: Center(
                                child: Column(
                                  children: [
                                    Text(
                                      '성공률 ${place.successRate}% (${place.tryCount}회)',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
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
                                  ],
                                ),
                              ),
                            ),
                          ),
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