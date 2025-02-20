import 'package:kkulkkulk/features/camera/data/models/hold_model.dart';

class VisitLogResponse {
  final int userDateId;
  final String name;
  final List<Hold> holds;
  final bool newlyCreated;

  VisitLogResponse({
    required this.userDateId,
    required this.name,
    required this.holds,
    required this.newlyCreated,
  });

  factory VisitLogResponse.fromJson(Map<String, dynamic> json) {
    final content = json['content'] as Map<String, dynamic>;
    final holdsJson = content['holds'] as List;
    return VisitLogResponse(
      userDateId: content['userDateId'] as int,
      name: content['name'] as String,
      holds: holdsJson
          .map((e) => Hold.fromJson(e as Map<String, dynamic>))
          .toList(),
      newlyCreated: content['newlyCreated'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "userDateId": userDateId,
      "name": name,
      "holds": holds.map((e) => e.toJson()).toList(),
      "newlyCreated": newlyCreated,
    };
  }
}
