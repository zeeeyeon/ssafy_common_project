// place_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kkulkkulk/features/place/data/models/place_all_model.dart';
import 'package:kkulkkulk/features/place/data/repositories/place_repository.dart';
import 'package:kkulkkulk/features/place/view_models/search_place_view_model.dart';
import 'package:kkulkkulk/common/gps/gps.dart';  // gps.dart 파일을 임포트
import 'package:logger/logger.dart';

var logger = Logger();

class PlaceForm extends ConsumerWidget {
  PlaceForm({super.key});

  final PlaceRepository _placeRepository = PlaceRepository();

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
            if (searchPlaceViewModel.keywordController.text.isNotEmpty)
              IconButton(
                onPressed: () {
                  print(searchPlaceViewModel.keywordController.text);
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
        SizedBox(height: 30,),
        // 위치 버튼 추가
        ElevatedButton(
          onPressed: () async {
            try {
              // 위치 가져오기 
              // Position position = await determinePosition();

              // logger.d("현재 위치: ${position.latitude}, ${position.longitude}");

              final PlaceAllModel placeAllModel = PlaceAllModel(
                latitude: 35.0964114,
                longitude: 128.8539711,
              );
              logger.d(_placeRepository.getAllDisCLimbs(placeAllModel));
            } catch (e) {
              // 오류 처리
              logger.d("오류 발생: $e");
            }
          },
          child: Text('현재 위치 확인'),
        ),
      ],
    );
  }
}
