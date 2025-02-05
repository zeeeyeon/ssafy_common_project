class CalendarDetailModel {
  final String climbGroundName;
  final int visitCount;
  final int successCount;
  final double completionRate;
  final Map<String, String> holdColorLevel;
  final Map<String, int> colorAttempts;
  final Map<String, int> colorSuccesses;

  CalendarDetailModel({
    required this.climbGroundName,
    required this.visitCount,
    required this.successCount,
    required this.completionRate,
    required this.holdColorLevel,
    required this.colorAttempts,
    required this.colorSuccesses,
  });

  factory CalendarDetailModel.fromJson(Map<String, dynamic> json) {
    return CalendarDetailModel(
      climbGroundName: json['climbGroundName'] as String,
      visitCount: json['visitCount'] as int,
      successCount: json['successCount'] as int,
      completionRate: (json['completionRate'] as num).toDouble(),
      holdColorLevel: Map<String, String>.from(json['holdColorLevel']),
      colorAttempts: Map<String, int>.from(json['colorAttempts']),
      colorSuccesses: Map<String, int>.from(json['colorSuccesses']),
    );
  }
}
