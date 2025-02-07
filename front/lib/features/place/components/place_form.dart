import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kkulkkulk/features/place/data/models/place_all_model.dart';
import 'package:kkulkkulk/features/place/data/models/place_response_model.dart';
import 'package:kkulkkulk/features/place/data/models/search_place_all_model.dart';
import 'package:kkulkkulk/features/place/data/repositories/place_repository.dart';

class PlaceForm extends StatefulWidget {
  const PlaceForm({super.key});

  @override
  _PlaceFormState createState() => _PlaceFormState();
}

class _PlaceFormState extends State<PlaceForm> {
  final PlaceRepository _placeRepository = PlaceRepository();
  final TextEditingController keywordController = TextEditingController();

  bool isLoading = false;
  List<PlaceResponseModel> allPlaces = [];
  List<PlaceResponseModel> filteredPlaces = [];

  @override
  void initState() {
    super.initState();
    _fetchAllPlaces();
  }

  // 전체 장소 가져오기
  Future<void> _fetchAllPlaces() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<PlaceResponseModel> places = await _placeRepository.getAllDisCLimbs(
        PlaceAllModel(latitude: 0, longitude: 0),
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
  Future<void> _searchPlacesByKeyword(String keyword) async {
    if (keyword.isEmpty) {
      setState(() {
        filteredPlaces = allPlaces; // 검색어가 없으면 전체 장소 리스트로 복원
      });
    } else {
      setState(() {
        isLoading = true;
      });

      try {
        List<PlaceResponseModel> places = await _placeRepository.searchClimbGround(
          SearchPlaceAllModel(keyword: keyword, latitude: 0, longitude: 0),
        );
        setState(() {
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
            _searchPlacesByKeyword(value);
          },
        ),
        SizedBox(height: 15),
        // 로딩 인디케이터
        if (isLoading) CircularProgressIndicator(),
        // 장소 리스트 출력
        Expanded(
          child: ListView.builder(
            itemCount: filteredPlaces.length,
            itemBuilder: (context, index) {
              final place = filteredPlaces[index];
              return Card(
                key: ValueKey(place.id), // 각 카드에 고유 ID를 key로 설정
                margin: EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: GestureDetector(
                  onTap: () {
                    // 상세 페이지로 이동
                    context.go('/place/${place.id}');
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 이미지 표시
                      place.image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                              child: Image.network(
                                place.image!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.fill,
                              ),
                            )
                          : Container(
                              height: 200,
                              color: Colors.grey[200],
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
                          "장소 ID: ${place.id}",
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
                          "거리: ${place.distance ?? '정보 없음'} km",
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
