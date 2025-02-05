class PlaceResponseModel {
  final int Id;
  final String name;
  final String image;
  final String address;
  final double distance;

  PlaceResponseModel({
    required this.Id,
    required this.name,
    required this.image,
    required this.address,
    required this.distance,
  });

  factory PlaceResponseModel.fromJson(Map<String, dynamic> json) {
    return PlaceResponseModel(
      Id: json['Id'],
      name: json['name'],
      image: json['image'],
      address: json['address'],
      distance: json['distance'],
    );
  }
}