import 'package:big_decimal/big_decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kkulkkulk/features/place/data/models/place_all_model.dart';
import 'package:kkulkkulk/features/place/view_models/search_place_view_model.dart';

// 리버팟의 상태를 관리하는 Notifier
class InitialLoadNotifier extends StateNotifier<bool> {
  InitialLoadNotifier() : super(false);

  void setLoaded() => state = true;  // 로딩 완료 상태로 변경
}

final initialLoadProvider = StateNotifierProvider<InitialLoadNotifier, bool>((ref) {
  return InitialLoadNotifier();
});

class PlaceForm extends ConsumerWidget {
  PlaceForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchPlaceViewModel = ref.watch(searchPlaceViewModelProvider);
    final isLoaded = ref.watch(initialLoadProvider);  // 로딩 여부 추적

    // 페이지가 로드될 때 GPS 기준으로 클라이밍 장소 불러오기
    Future<void> _getInitialClimbingPlaces() async {
      if (!isLoaded) {  // 이미 데이터가 로드되었으면 요청하지 않음
        // 기본 GPS 좌표 (위도, 경도)
        final placeAllModel = PlaceAllModel(
          latitude: BigDecimal.parse('35.0964114'),  // SSafy 사업장 좌표 (예시)
          longitude: BigDecimal.parse('128.8539711'),
        );
        await searchPlaceViewModel.getAllDisCLimbs(placeAllModel);
        ref.read(initialLoadProvider.notifier).setLoaded();  // 데이터 로드 완료 상태로 변경
      }
    }

    // 위젯이 처음 빌드된 후 초기 데이터를 가져오기 위해 호출
    // 빌드가 끝난 후에 한 번만 호출하도록 함
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getInitialClimbingPlaces();
    });

    return Column(
      children: [
        // 검색어 입력창
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: searchPlaceViewModel.keywordController,
            decoration: InputDecoration(
              labelText: "검색어를 입력하세요",
              suffixIcon: searchPlaceViewModel.keywordController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        searchPlaceViewModel.clearKeyword();
                      },
                      icon: Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              searchPlaceViewModel.updateKeyword(value);
            },
          ),
        ),

        // 로딩 중 표시
        if (searchPlaceViewModel.isLoading)
          Center(child: CircularProgressIndicator()),

        // 에러 메시지 표시
        if (searchPlaceViewModel.errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              searchPlaceViewModel.errorMessage,
              style: TextStyle(color: Colors.red),
            ),
          ),

        // 결과 리스트
        Expanded(
          child: ListView.builder(
            itemCount: searchPlaceViewModel.places.length,
            itemBuilder: (context, index) {
              final place = searchPlaceViewModel.places[index];
              return Card(
                child: ListTile(
                  title: Text(place.name),
                  subtitle: Text(place.address),
                  trailing: Text('${place.distance} km'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
