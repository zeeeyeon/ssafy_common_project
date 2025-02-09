class ChallengeResponseModel {
  final String name;
  final String image;
  final String address;
  final double distance;
  final bool locked;
  final int climbGroundId;

  ChallengeResponseModel({
    required this.name,
    required this.image,
    required this.address,
    required this.distance,
    required this.locked,
    required this.climbGroundId,
  });

  factory ChallengeResponseModel.fromJson(Map<String, dynamic> json) {
    return ChallengeResponseModel(
      name: json['name'],
      image: json['image'],
      address: json['address'], 
      distance: json['distance'], 
      locked: json['locked'], 
      climbGroundId: json['climbGroundId'],
    );
  }
}