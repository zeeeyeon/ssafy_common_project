import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kkulkkulk/features/place/data/models/place_detail_model.dart';
import 'package:kkulkkulk/features/place/data/repositories/place_repository.dart';
import 'package:kkulkkulk/common/widgets/layout/custom_app_bar.dart'; // CustomAppBar 경로 수정
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
      appBar: CustomAppBar(
        title: '장소 상세 정보',
        showBackButton: true,
        onBackPressed: () {
          context.go('/place');
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(0),
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
                    Image.network(
                      place.image,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.fill,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(
                            '${place.name}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${place.address}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.call),
                              SizedBox(width: 8.0),
                              TextButton(
                                onPressed: () async {
                                  final tel = Uri.parse('tel:${place.number.replaceAll('-', '')}');
                                  await launchUrl(tel);
                                },
                                child: Text('${place.number}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.black, // 글자 색상 설정
                                ),
                              )
                            ],
                          ),
                          // SizedBox(height: 8),
                          Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.instagram,
                                color: Colors.pinkAccent,
                              ),
                              SizedBox(width: 8.0),
                              TextButton(
                                onPressed: () async {
                                  final snsUrl = Uri.parse(place.snsUrl);
                                  await launchUrl(snsUrl);
                                },
                                child: Text('인스타그램',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, // 글자 두께를 굵게 설정
                                ),),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.black, // 글자 색상 설정
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16,),
                          // Holds 정보 출력
                          Text(
                            '편의시절 및 서비스',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          // ...place.infos.map((info) => Text(
                          // info.info,
                          // style: TextStyle(fontSize: 16),
                          // )),
                          ...place.infos.map((info) {
                          IconData icon = _getIconForInfo(info.info); // 아이콘 결정
                            return Row(
                              children: [
                                Icon(icon, size: 24), // 아이콘 표시
                                SizedBox(width: 16), // 아이콘과 텍스트 사이에 간격 추가
                                Text(
                                  info.info,
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 32,)
                              ],
                            );
                          }).toList(),
                          SizedBox(height: 16,),
                          Text(
                            '난이도',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '총 ${place.holds.length}개의 난이도로 나뉘어 있어요',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey
                            ),
                          ),
                          SizedBox(height: 8),
                          // Hold 시각화: 각 Hold의 색상과 난이도를 그래픽으로 표현
                          _buildHoldsGraph(place.holds),
                          SizedBox(height: 16),
                          // Info 정보 출력
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  // 난이도 그래프를 위한 함수 (각 Hold 색상 표시)
  Widget _buildHoldsGraph(List<HoldModel> holds) {
    // 색상별로 배치된 난이도를 표시하는 Row 형태로 반환
    return Row(
      children: holds.map((hold) {
        return Expanded(
          child: Container(
            height: 25,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: getColorFromName(hold.color), // 색상에 맞는 color 적용
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }).toList(),
    );
  }

  // 헬퍼 함수: 색상 이름을 Color로 변환 (기존의 getColorFromName 함수 사용)
  Color getColorFromName(String name) {
    switch (name.toUpperCase()) {
      case 'RED':
        return Colors.red;
      case 'ORANGE':
        return Colors.orange;
      case 'YELLOW':
        return Colors.yellow;
      case 'GREEN':
        return Colors.green;
      case 'BLUE':
        return Colors.blue;
      case 'NAVY':
        return const Color(0xFF000080); // 네이비
      case 'PURPLE':
        return Colors.purple;
      case 'PINK':
        return Colors.pink;
      case 'SKYBLUE':
        return Colors.lightBlueAccent; // 스카이블루
      case 'CYAN':
        return Colors.cyan;
      case 'TEAL':
        return Colors.teal;
      case 'LIME':
        return Colors.lime;
      case 'AMBER':
        return Colors.amber;
      case 'DEEPORANGE':
        return Colors.deepOrange;
      case 'DEEPPURPLE':
        return Colors.deepPurple;
      case 'LIGHTGREEN':
        return Colors.lightGreen;
      case 'BROWN':
        return Colors.brown;
      case 'GREY':
      case 'GRAY':
        return Colors.grey;
      case 'BLACK':
        return Colors.black;
      case 'WHITE':
        return Colors.white;
      case 'INDIGO':
        return Colors.indigo;
      case 'BLUEGREY':
        return Colors.blueGrey;
      case 'SODOMY':
        return const Color(0xFF000000);
      case 'MAROON':
        return const Color(0xFF800000);
      case 'OLIVE':
        return const Color(0xFF808000);
      case 'CORAL':
        return const Color(0xFFFF7F50);
      case 'VIOLET':
        return const Color(0xFF8F00FF);
      case 'MAGENTA':
        return const Color(0xFFFF00FF);
      case 'AQUA':
        return const Color(0xFF00FFFF);
      case 'GOLD':
        return const Color(0xFFFFD700);
      case 'SILVER':
        return const Color(0xFFC0C0C0);
      default:
        return Colors.grey;
    }
  }

  IconData _getIconForInfo(String info) {
    switch (info) {
      case '예약':
        return Icons.calendar_today;
      case '무선 인터넷':
        return Icons.wifi;
      case '남/녀 화장실 구분':
        return Icons.male; // 남성 화장실 아이콘
      case '주차':
        return Icons.local_parking;
      case '단체 이용 가능':
        return Icons.group;
      case '대기공간':
        return Icons.access_time;
      case '간편결제':
        return Icons.payment;
      case '반려동물 동반':
        return Icons.pets;
      case '유아시설 (놀이방)':
        return Icons.child_care;
      case '방문접수/출장':
        return Icons.business;
      case '노키즈존':
        return Icons.no_accounts;
      case '장애인 편의시설':
        return Icons.accessible;
      case '발렛파킹':
        return Icons.car_repair;
      default:
        return Icons.help; // 기본 아이콘
    }
  }
}
