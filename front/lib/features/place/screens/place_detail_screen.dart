import 'package:flutter/material.dart';
import 'package:kkulkkulk/features/place/data/models/place_detail_model.dart';
import 'package:kkulkkulk/features/place/data/repositories/place_repository.dart';
import 'package:kkulkkulk/common/widgets/layout/custom_app_bar.dart'; // CustomAppBar 경로 수정

class PlaceDetailScreen extends StatefulWidget {
  final int id;

  const PlaceDetailScreen({super.key, required this.id});

  @override
  _PlaceDetailScreenState createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  late Future<PlaceDetailModel> placeDetail; // 클라이밍장 상세 정보를 저장할 변수
  final PlaceRepository _placeRepository = PlaceRepository(); // PlaceRepository 인스턴스

  @override
  void initState() {
    super.initState();
    placeDetail = _placeRepository.detailClimb(widget.id); // 클라이밍장 ID로 상세 정보 가져오기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '장소 상세 정보'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<PlaceDetailModel>(
          future: placeDetail,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator()); // 로딩 중일 때
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}')); // 에러 발생 시
            } else if (!snapshot.hasData) {
              return Center(child: Text('장소 정보를 찾을 수 없습니다.'));
            } else {
              // 데이터를 가져왔을 때 화면에 출력
              PlaceDetailModel place = snapshot.data!;
              return SingleChildScrollView( // 스크롤을 가능하게 만든 부분
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 장소 이름
                    Text(
                      '장소 이름: ${place.name}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    // 주소
                    Text(
                      '주소: ${place.address}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    // 전화번호
                    Text(
                      '전화번호: ${place.number}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    // SNS 링크
                    Text(
                      'SNS: ${place.snsUrl}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    // 운영 시간
                    Text(
                      '운영 시간: ${place.open}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    // 위치 (위도, 경도)
                    Text(
                      '위도: ${place.latitude}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '경도: ${place.longitude}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    // Holds 정보 출력
                    Text(
                      'Holds:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ...place.holds.map((hold) => Text(
                          'Level: ${hold.level}, Color: ${hold.color}',
                          style: TextStyle(fontSize: 16),
                        )),
                    SizedBox(height: 16),
                    // Info 정보 출력
                    Text(
                      '기타 정보:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ...place.infos.map((info) => Text(
                          info.info,
                          style: TextStyle(fontSize: 16),
                        )),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
