import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/features/challenge/data/models/challenge_all_model.dart';
import 'package:kkulkkulk/features/challenge/data/models/challenge_response_model.dart';
import 'package:kkulkkulk/features/challenge/data/models/search_challenge_all_model.dart';
import 'package:kkulkkulk/features/challenge/data/repositories/challenge_repository.dart';

class ChallengeViewModel extends ChangeNotifier {
  final ChallengeRepository _challengeRepository = ChallengeRepository();
  final TextEditingController keywordController = TextEditingController();
  bool isLoading = false;

  String successMessage = '';
  String errorMessage = '';

  List<ChallengeResponseModel> allPlaces = [];
  List<ChallengeResponseModel> filteredPlaces = [];

  // 챌린지 장소 전체 조회(GPS 거리순)
  Future<List<ChallengeResponseModel>> challengesAll(ChallengeAllModel challengeAllModel) async {
    try {
      isLoading = true;
      notifyListeners();
      List<ChallengeResponseModel> fetchChallenges = await _challengeRepository.getAllChallenges(challengeAllModel);
      allPlaces = fetchChallenges;
      filteredPlaces = [];
      isLoading = false;
      notifyListeners();
      return allPlaces;
    } catch (e) {
      isLoading = false;
      print('에러: $e');
      notifyListeners();
      return[];
    }
  }

  // 챌린지 장소 검색 조회
  Future<List<ChallengeResponseModel>> searchChallengeAll(SearchChallengeAllModel searchhallengeAllModel) async {
    try {
      isLoading = true;
      List<ChallengeResponseModel> fetchPlaces = await _challengeRepository.searchGetAllChallenges(searchhallengeAllModel);
      filteredPlaces = fetchPlaces;
      isLoading = false;
      notifyListeners();
      return filteredPlaces;
    } catch (e) {
      isLoading = false;
      print('에러: $e');
      notifyListeners();
      return[];
    }
  }

  // 챌린지 장소 상세 조회
  // Future<

  // 상태 초기화
  void reset() {
    keywordController.clear();
    filteredPlaces = [];
    notifyListeners();
  }

}

// ChallengeViewModel을 Riverpod Provider로 관리
final searchChallengeViewModel = ChangeNotifierProvider<ChallengeViewModel>((ref) {
  return ChallengeViewModel();
});