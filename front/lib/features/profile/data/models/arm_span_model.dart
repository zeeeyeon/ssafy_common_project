class ArmSpanResult {
  final double armSpan;

  ArmSpanResult({required this.armSpan});

  factory ArmSpanResult.fromJson(Map<String, dynamic> json) {
    return ArmSpanResult(
      armSpan: (json['armSpan'] ?? 0.0).toDouble(), // null 방지 & double 변환
    );
  }
}
