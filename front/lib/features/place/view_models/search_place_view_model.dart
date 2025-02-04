import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchPlaceViewModel extends ChangeNotifier {

  final TextEditingController keywordController = TextEditingController();

  // 텍스트 초기화
  void clearKeyword() {
    keywordController.clear(); // 상태를 빈 문자열로 업데이트하여 UI 갱신을 트리거
    notifyListeners();
  }

  // 텍스트가 변경될 때 호출되는 메서드
  void updateKeyword(String value) {
    keywordController.text = value; // 텍스트 변경
    notifyListeners(); // 상태 변경을 알리기 위해 notifyListeners 호출
  }
  
}

final searchPlaceViewModelProvider = ChangeNotifierProvider<SearchPlaceViewModel>((ref) {
  return SearchPlaceViewModel();
});
