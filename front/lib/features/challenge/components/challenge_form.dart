import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kkulkkulk/common/gps/gps.dart';
import 'package:kkulkkulk/features/challenge/data/models/challenge_all_model.dart';
import 'package:kkulkkulk/features/challenge/data/models/challenge_response_model.dart';
import 'package:kkulkkulk/features/challenge/data/models/search_challenge_all_model.dart';
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
  List<ChallengeResponseModel> allPlaces = [];
  List<ChallengeResponseModel> filteredPlaces = [];

  @override
  void initState() {
    super.initState();
    _fetchAllPlaces();
  }

  // 챌린지 장소 전체 조회(GPS 거리순)
  Future<void> _fetchAllPlaces() async {
    setState(() {
      isLoading = true;
    });
    print('시작');
    try {
      Position position = await determinePosition();
      List<ChallengeResponseModel> places = await _challengeRepository.getAllChallenges(
        ChallengeAllModel(
          userId: 1, // 나중에 토큰으로 사용자 userId 추출 수정
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
    if(keyword.isEmpty) {
      setState(() {
        filteredPlaces = allPlaces;
      });
    } else {
      setState(() {
        isLoading = true;
      });

      try {
        Position position = await determinePosition();
        List<ChallengeResponseModel> place = await _challengeRepository.searchGetAllChallenges(
          SearchChallengeAllModel(
            userId: 1, // 나중에 토큰으로 사용자 userId 추출 수정
            latitude: position.latitude, 
            longitude: position.longitude,
          )
        );
        setState(() {
          filteredPlaces = allPlaces;
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

  // 검색어를 비우는 함수
  void _clearKeyword() {
    setState(() {
      keywordController.clear();
      filteredPlaces = allPlaces; // 검색어를 비우면 전체 장소 리스트로 복원
    });
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
                    icon: Icon(Icons.close),
                    onPressed: _clearKeyword,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20), // 둥근 테두리
              borderSide: BorderSide(color: Color(0xFF8A9EA6), width: 1), // 테두리 색과 두께
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Color(0xFF8A9EA6), width: 2), // 포커스된 테두리
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Color(0xFF8A9EA6), width: 1), // 비활성화된 테두리
            ),
          ),
          // 검색어가 완료되면 엔터키(완료 버튼) 눌렀을 때 검색
          onSubmitted: (value) {
            _searchChallengeByKeyword(value);
          },
        ),
        SizedBox(height: 15),
        if (isLoading) CircularProgressIndicator(),
        // 장소 리스트 출력
        Expanded(
          child: ListView.builder(
            itemCount: filteredPlaces.length,
            itemBuilder: (context, index) {
              final place = filteredPlaces[index];
              return Card(
                key: ValueKey(place.climbGroundId), // 각 카드에 고유 ID를 key로 설정
                margin: EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: GestureDetector(
                  onTap: () {
                    // 상세 페이지로 이동
                    // context.go('/place/${place.id}');
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
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                  child: Image.network(
                                    place.image!,
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
                          if (!place.locked)
                            Container(
                              height: 200,
                              color: Colors.black.withOpacity(0.5), // 어두운 배경 오버레이
                            ),
                          // 자물쇠 아이콘
                          Icon(
                            place.locked ? Icons.lock_open : Icons.lock,
                            color: Color(0xFF8A9EA6),
                            size: 50,
                          ),
                        ],
                      ),
                      // 제목 부분
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          place.name,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      // 장소 ID 표시
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "장소 ID: ${place.climbGroundId}",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                      // 해금 표시
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "장소 상태: ${place.locked ? '열림' : '잠김'}",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                      // 주소 표시
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          place.address ?? "주소 정보 없음",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                      // 거리 표시
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
                        child: Text(
                          "거리: ${place.distance ?? '정보 없음'} km 근처",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
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
