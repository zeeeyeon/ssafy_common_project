import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:kkulkkulk/common/gps/gps.dart';
import 'package:kkulkkulk/common/notification/notification.dart';
import 'package:kkulkkulk/features/challenge/data/models/challenge_all_model.dart';
import 'package:kkulkkulk/features/challenge/data/models/challenge_response_model.dart';
import 'package:kkulkkulk/features/challenge/data/models/near_challenge_model.dart';
import 'package:kkulkkulk/features/challenge/data/models/search_challenge_all_model.dart';
import 'package:kkulkkulk/features/challenge/data/models/unlock_challenge_model.dart';
import 'package:kkulkkulk/features/challenge/data/repositories/challenge_repository.dart';

class ChallengeForm extends StatefulWidget {
  const ChallengeForm({super.key});

  @override
  _ChallengeFormState createState() => _ChallengeFormState();
}

class _ChallengeFormState extends State<ChallengeForm> {
  final ChallengeRepository _challengeRepository = ChallengeRepository();
  final TextEditingController keywordController = TextEditingController();

  bool isLoading = false;
  bool nearChallenge = false;
  List<ChallengeResponseModel> allPlaces = [];
  List<ChallengeResponseModel> filteredPlaces = [];
  ChallengeResponseModel? nearPlace;
  @override
  void initState() {
    super.initState();
    _fetchNearPlaces();
    _fetchAllPlaces();
  }

  // 500m 내에 있는 장소 조회
  Future<void> _fetchNearPlaces() async {
    setState(() {
      isLoading = true;
    });
    try {
      Position position = await determinePosition();
      print('lat(위도) : ${position.latitude} / log(경도) : ${position.longitude}');
      ChallengeResponseModel nearByPlace =
          await _challengeRepository.nearChallenge(
        NearChallengeModel(
            latitude: position.latitude, longitude: position.longitude),
      );
      setState(() {
        nearPlace = nearByPlace;
        isLoading = false;
      });

      print('API 응답: $nearByPlace');
      if(nearByPlace.distance <= 0.5) {
        NotificationService()
          .showPushAlarm('끌락끌락 챌린지 감지!!!', '끌락끌락 챌린지 해당 클라이밍장이 주변에 있습니다.');
          print('showPushAlarm 호출됨!');
      }
      
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching places: $e');
    }
  }

  // 챌린지 장소 전체 조회(GPS 거리순)
  Future<void> _fetchAllPlaces() async {
    setState(() {
      isLoading = true;
    });

    try {
      Position position = await determinePosition();
      List<ChallengeResponseModel> places =
          await _challengeRepository.getAllChallenges(
        ChallengeAllModel(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );
      setState(() {
        allPlaces = places;
        filteredPlaces = places;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching places: $e');
    }
  }

  // 검색어를 입력하고 장소를 검색하는 함수
  Future<void> _searchChallengeByKeyword(String keyword) async {
    if (keyword.isEmpty) {
      setState(() {
        filteredPlaces = allPlaces;
      });
    } else {
      setState(() {
        isLoading = true;
      });

      try {
        Position position = await determinePosition();

        List<ChallengeResponseModel> places = await _challengeRepository
            .searchGetAllChallenges(SearchChallengeAllModel(
          latitude: position.latitude,
          longitude: position.longitude,
          keyword: keyword,
        ));
        print(places);
        setState(() {
          allPlaces = places;
          filteredPlaces = places;
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print('Error searching places: $e');
      }
    }
  }

  // 해금 함수
  Future<void> _unlockChallenge(int climbGroundId) async {
    try {
      print(climbGroundId);
      Position position = await determinePosition();
      print('lat : ${position.latitude}');
      print('log : ${position.longitude}');

      final response = await _challengeRepository.unlockChallenge(
          UnlockChallengeModel(
              climbGroundId: climbGroundId,
              latitude: position.latitude,
              longitude: position.longitude));

      if (response.statusCode == 201) {
        context.push('/challenge/detail/$climbGroundId');
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('해당 클라이밍장이 성공적으로 해금되었습니다')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('해당 클라이밍장을 해금할 수 없는 거리에 있습니다')));
      rethrow;
    }
  }

  // 검색어를 비우는 함수
  void _clearKeyword() {
    setState(() {
      keywordController.clear();
      filteredPlaces = allPlaces; // 검색어를 비우면 전체 장소 리스트로 복원
    });
  }

  // 해금 확인 모달
  void _showUnlockDialog(ChallengeResponseModel place) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "해금하시겠습니까?",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            place.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _unlockChallenge(place.climbGroundId);
                Navigator.of(context).pop();
              },
              child: const Text(
                "확인",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF8A9EA6)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "취소",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF8A9EA6)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 검색어 입력창
        TextField(
          controller: keywordController,
          decoration: InputDecoration(
            hintText: "검색어를 입력하세요",
            suffixIcon: keywordController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _clearKeyword,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20), // 둥근 테두리
              borderSide: const BorderSide(
                  color: Color(0xFF8A9EA6), width: 1), // 테두리 색과 두께
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                  color: Color(0xFF8A9EA6), width: 2), // 포커스된 테두리
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                  color: Color(0xFF8A9EA6), width: 1), // 비활성화된 테두리
            ),
          ),
          // 검색어가 완료되면 엔터키(완료 버튼) 눌렀을 때 검색
          onSubmitted: (value) {
            _searchChallengeByKeyword(value);
          },
        ),
        // nearPlace가 null이 아니면 해당 정보를 표시
        if (nearPlace != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: ListTile(
                title: Text(
                  "근처 챌린지: ${nearPlace?.name}",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: Text("주소: ${nearPlace?.address ?? '주소 정보 없음'}"),
                onTap: () {
                  if (!nearPlace!.locked) {
                    context
                        .push('/challenge/detail/${nearPlace!.climbGroundId}');
                  } else {
                    _showUnlockDialog(nearPlace!);
                  }
                },
              ),
            ),
          ),

        if (isLoading) const CircularProgressIndicator(),
        // 장소 리스트 출력
        Expanded(
          child: ListView.builder(
            itemCount: filteredPlaces.length,
            itemBuilder: (context, index) {
              final place = filteredPlaces[index];
              return Card(
                key: ValueKey(place.climbGroundId), // 각 카드에 고유 ID를 key로 설정
                margin: const EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: GestureDetector(
                  onTap: () {
                    // Position position = await determinePosition();
                    // 상세 페이지로 이동
                    if (!place.locked) {
                      context.push('/challenge/detail/${place.climbGroundId}');
                    } else {
                      _showUnlockDialog(place);
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 이미지 부분
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          place.image != null
                              ? ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12)),
                                  child: Image.network(
                                    place.image,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  height: 200,
                                  color: Colors.grey[200],
                                ),
                          // place.locked가 false일 때만 어두운 배경 오버레이 추가
                          if (place.locked)
                            Container(
                              height: 200,
                              color:
                                  Colors.black.withOpacity(0.5), // 어두운 배경 오버레이
                            ),
                          // 자물쇠 아이콘
                          Icon(
                            !place.locked ? Icons.lock_open : Icons.lock,
                            color: const Color(0xFF8A9EA6),
                            size: 50,
                          ),
                        ],
                      ),
                      // 제목 부분
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          place.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      // 장소 ID 표시
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      //   child: Text(
                      //     "장소 ID: ${place.climbGroundId}",
                      //     style: TextStyle(fontSize: 14, color: Colors.grey),
                      //   ),
                      // ),
                      // 주소 표시
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          place.address ?? "주소 정보 없음",
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                      // 해금 표시
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "해금 상태: ${place.locked ? '잠김' : '열림'}",
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                      // 거리 표시
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
                        child: Text(
                          "거리: ${place.distance ?? '정보 없음'} km 근처",
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
