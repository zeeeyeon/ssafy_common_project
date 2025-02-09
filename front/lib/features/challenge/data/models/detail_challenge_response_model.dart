class DetailChallengeResponseModel {
  final int climbGroundId;
  final String name;
  final String address;
  final String imageUrl;
  final String medal;
  final int success;
  final double successRate;
  final int tryCount;

  DetailChallengeResponseModel({
    required this.climbGroundId,
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.medal,
    required this.success,
    required this.successRate,
    required this.tryCount
  });

  factory DetailChallengeResponseModel.fromJson(Map<String, dynamic> json) {
    return DetailChallengeResponseModel(
      climbGroundId: json['climbGroundId'], 
      name: json['name'], 
      address: json['address'], 
      imageUrl: json['imageUrl'], 
      medal: json['medal'], 
      success: json['success'], 
      successRate: json['success_rate'], 
      tryCount: json['tryCount']
    );
  }
}