import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/features/place/data/models/place_all_model.dart';
import 'package:kkulkkulk/features/place/data/models/place_all_pagination_model.dart';
import 'package:kkulkkulk/features/place/data/models/place_response_model.dart';
import 'package:kkulkkulk/features/place/data/models/search_place_all_model.dart';
import 'package:kkulkkulk/features/place/data/repositories/place_repository.dart';

class SearchPlaceViewModel extends ChangeNotifier {
  final PlaceRepository _placeRepository = PlaceRepository();

  final TextEditingController keywordController = TextEditingController();

  bool isLoading = false;

  String successMessage = '';
  String errorMessage = '';

  List<PlaceResponseModel> allPlaces = [];
  List<PlaceResponseModel> filteredPlaces = [];

  // 클라이밍 장소 전체 조회(GPS 거리순)
  Future<List<PlaceResponseModel>> placesAll(
      PlaceAllModel placeAllModel) async {
    try {
      isLoading = true;
      notifyListeners();
      List<PlaceResponseModel> fetchPlaces =
          await _placeRepository.getAllDisCLimbs(placeAllModel);
      allPlaces = fetchPlaces;
      filteredPlaces = [];
      isLoading = false;
      notifyListeners();
      return allPlaces;
    } catch (e) {
      isLoading = false;
      print('에러: $e');
      notifyListeners();
      return [];
    }
  }

  // 클라이밍 장소 전체 조회(페이지네이션 스크롤 최적화, GPS 거리순)
  Future<List<PlaceResponseModel>> placesAllPagination(
      PlaceAllPaginationModel placeAllPaginationModel) async {
    try {
      isLoading = true;
      notifyListeners();
      List<PlaceResponseModel> fetchPlaces = await _placeRepository
          .getAllDisClimbsPagination(placeAllPaginationModel);
      allPlaces = fetchPlaces;
      filteredPlaces = [];
      isLoading = false;
      notifyListeners();
      return allPlaces;
    } catch (e) {
      isLoading = false;
      print('에러: $e');
      notifyListeners();
      return [];
    }
  }

  // 클라이밍 장소 전체 조회(GPS 거리순)
  Future<List<PlaceResponseModel>> searchPlacesByKeyword(
      SearchPlaceAllModel searchPlaceAllModel) async {
    try {
      isLoading = true;
      List<PlaceResponseModel> fetchPlaces =
          await _placeRepository.searchClimbGround(searchPlaceAllModel);
      filteredPlaces = fetchPlaces;
      isLoading = false;
      notifyListeners();
      return filteredPlaces;
    } catch (e) {
      isLoading = false;
      print('에러: $e');
      notifyListeners();
      return [];
    }
  }

  // 상태 초기화
  void reset() {
    keywordController.clear();
    filteredPlaces = [];
    notifyListeners();
  }
}

// SearchPlaceViewModel을 Riverpod Provider로 관리
final searchPlaceViewModelProvider =
    ChangeNotifierProvider<SearchPlaceViewModel>((ref) {
  return SearchPlaceViewModel();
});
