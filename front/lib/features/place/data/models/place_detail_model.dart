class PlaceDetailModel {
  final String name;
  final String address;
  final String image;
  final String number;
  final double latitude;
  final double longitude;
  final String open;
  final String snsUrl;
  final List<HoldModel> holds;
  final List<InfoModel> infos;
  final int id;

  PlaceDetailModel({
    required this.name,
    required this.address,
    required this.image,
    required this.number,
    required this.latitude,
    required this.longitude,
    required this.open,
    required this.snsUrl,
    required this.holds,
    required this.infos,
    required this.id,
  });

  // JSON 파싱
  factory PlaceDetailModel.fromJson(Map<String, dynamic> json) {
    var holdsList = json['holds'] as List;
    var infosList = json['infos'] as List;

    return PlaceDetailModel(
      name: json['name'],
      address: json['address'],
      image: json['image'],
      number: json['number'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      open: json['open'],
      snsUrl: json['sns_url'],
      holds: holdsList.map((hold) => HoldModel.fromJson(hold)).toList(),
      infos: infosList.map((info) => InfoModel.fromJson(info)).toList(),
      id: json['id'],
    );
  }
}

class HoldModel {
  final String level;
  final String color;
  final int id;

  HoldModel({required this.level, required this.color, required this.id});

  // JSON 파싱
  factory HoldModel.fromJson(Map<String, dynamic> json) {
    return HoldModel(
      level: json['level'],
      color: json['color'],
      id: json['id'],
    );
  }
}

class InfoModel {
  final String info;

  InfoModel({required this.info});

  // JSON 파싱
  factory InfoModel.fromJson(Map<String, dynamic> json) {
    return InfoModel(
      info: json['info'],
    );
  }
}
