import 'package:flutter/foundation.dart';

class ArmSpanResult {
  final double armSpan;

  ArmSpanResult({required this.armSpan});

  factory ArmSpanResult.fromJson(Map<String, dynamic> json) {
    debugPrint("📌 [DEBUG] fromJson() 입력 데이터: $json");

    final armSpanValue = (json['content']?['armSpan'] ?? 0.0).toDouble();
    debugPrint("📌 [DEBUG] fromJson() 변환 결과: $armSpanValue");

    return ArmSpanResult(armSpan: armSpanValue);
  }
}
