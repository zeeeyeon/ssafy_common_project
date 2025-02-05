import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:big_decimal/big_decimal.dart';
import 'package:flutter/material.dart';
import 'package:kkulkkulk/features/place/data/models/place_all_model.dart';
import 'package:kkulkkulk/features/place/data/models/place_response_model.dart';
import 'package:kkulkkulk/features/place/data/models/search_place_all_model.dart';
import 'package:kkulkkulk/features/place/data/repositories/place_repository.dart';

// SearchPlaceViewModel을 ChangeNotifier로 관리
class SearchPlaceViewModel extends ChangeNotifier {
  final PlaceRepository _placeRepository = PlaceRepository();
  final TextEditingController keywordController = TextEditingController();

  List<PlaceResponseModel> places = [];
  bool isLoading = false;
  String errorMessage = '';

  // 텍스트 초기화
  void clearKeyword() {
    keywordController.clear();
    notifyListeners();
  }

  // 텍스트가 변경될 때 호출되는 메서드
  void updateKeyword(String value) {
    keywordController.text = value;
    notifyListeners();
  }

  // 클라이밍 장소 전체 조회 (GPS 기준)
  Future<void> getAllDisCLimbs(PlaceAllModel placeAllModel) async {
    try {
      isLoading = true;
      notifyListeners();
      places = await _placeRepository.getAllDisCLimbs(placeAllModel);

      

      isLoading = false;
      notifyListeners();
      print(places);
    } catch (e) {
      isLoading = false;
      errorMessage = '장소를 불러오는 데 실패했습니다: $e';
      notifyListeners();
    }
  }

  // 클라이밍 장소 검색어 조회
  Future<void> searchClimbGround() async {
    try {
      isLoading = true;
      notifyListeners();

      final searchPlaceAllModel = SearchPlaceAllModel(
        keyword: keywordController.text,
        latitude: BigDecimal.parse('35.0964114'),
        longitude: BigDecimal.parse('128.8539711'),
      );

      places = await _placeRepository.searchClimbGround(searchPlaceAllModel);
      if (places == null) {
        places = []; // null인 경우 빈 리스트로 처리
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = '장소 검색에 실패했습니다: $e';
      notifyListeners();
    }
  }
}

// Riverpod provider를 사용하여 SearchPlaceViewModel을 관리
final searchPlaceViewModelProvider = ChangeNotifierProvider<SearchPlaceViewModel>((ref) {
  return SearchPlaceViewModel();
});
