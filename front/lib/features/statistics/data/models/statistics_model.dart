class ClimbGround {
  final int climbGround; // 장소 ID
  final int visited; // 방문한 장소 수
  final List<int> list; // 방문한 장소 ID 리스트

  ClimbGround({
    required this.climbGround,
    required this.visited,
    required this.list,
  });

  factory ClimbGround.fromJson(Map<String, dynamic> json) {
    return ClimbGround(
      climbGround: json['climbGround'] as int,
      visited: json['visited'] as int,
      list: List<int>.from(json['list']),
    );
  }
}

class Hold {
  final String color; // 홀드 색상
  final int tryCount; // 시도 횟수
  final int success; // 성공 횟수

  Hold({
    required this.color,
    required this.tryCount,
    required this.success,
  });

  factory Hold.fromJson(Map<String, dynamic> json) {
    return Hold(
      color: json['color'] as String,
      tryCount: json['tryCount'] as int,
      success: json['success'] as int,
    );
  }
}

class StatisticsContent {
  final ClimbGround climbGround;
  final int success; // 성공 횟수
  final double successRate; // 성공률
  final int tryCount; // 시도 횟수
  final List<Hold> holds; // 홀드별 데이터

  StatisticsContent({
    required this.climbGround,
    required this.success,
    required this.successRate,
    required this.tryCount,
    required this.holds,
  });

  factory StatisticsContent.fromJson(Map<String, dynamic> json) {
    return StatisticsContent(
      climbGround: ClimbGround.fromJson(json['climbground']),
      success: json['success'] as int,
      successRate: (json['success_rate'] as num).toDouble(),
      tryCount: json['tryCount'] as int,
      holds: (json['holds'] as List)
          .map((holdJson) => Hold.fromJson(holdJson))
          .toList(),
    );
  }
}

class StatisticsModel {
  final int code; // 상태 코드
  final String message; // 상태 메시지
  final StatisticsContent content; // 실제 데이터

  StatisticsModel({
    required this.code,
    required this.message,
    required this.content,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      code: json['status']['code'] as int,
      message: json['status']['message'] as String,
      content: StatisticsContent.fromJson(json['content']),
    );
  }
}
