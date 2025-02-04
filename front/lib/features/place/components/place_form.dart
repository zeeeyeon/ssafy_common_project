// place_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/features/place/view_models/search_place_view_model.dart';

class PlaceForm extends ConsumerWidget {
  const PlaceForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchPlaceViewModel = ref.watch(searchPlaceViewModelProvider);

    return Column(
      children: [
        SearchBar(
          controller: searchPlaceViewModel.keywordController,
          leading: Icon(Icons.search),
          shadowColor: WidgetStatePropertyAll(Colors.white),
          overlayColor: WidgetStatePropertyAll(Colors.white),
          trailing: [
            // 'X' 버튼은 keywordController.text가 비어있지 않으면 보이도록 설정
            if (searchPlaceViewModel.keywordController.text.isNotEmpty)
              IconButton(
                onPressed: () {
                  print(searchPlaceViewModel.keywordController.text);
                  // X 버튼 클릭 시 텍스트 초기화
                  searchPlaceViewModel.clearKeyword();

                  print(searchPlaceViewModel.keywordController.text);
                },
                icon: Icon(Icons.close),
              ),
            if (searchPlaceViewModel.keywordController.text.isEmpty)
              IconButton(
                onPressed: () {
                  // 음성 입력 기능 처리
                },
                icon: Icon(Icons.keyboard_voice),
              ),
            if (searchPlaceViewModel.keywordController.text.isEmpty)
              IconButton(
                onPressed: () {
                  // 기타 버튼 기능 처리
                },
                icon: Icon(Icons.build),
              ),
          ],
          hintText: "검색어를 입력하세요",
          backgroundColor: WidgetStatePropertyAll(Colors.white),
          onChanged: (value) {
            searchPlaceViewModel.updateKeyword(value);
          },
        
        ),
      ],
    );
  }
}
