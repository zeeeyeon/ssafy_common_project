class ClimbGround {
  final int climbGround;
  final int visited;
  final List<int> list;

  ClimbGround({
    required this.climbGround,
    required this.visited,
    required this.list,
  });

  factory ClimbGround.fromJson(Map<String, dynamic> json) {
    return ClimbGround(
        climbGround: json['climbGround'],
        visited: json['visited'],
        list: List<int>.from(json['list']));
  }
}

class Hold {
  final String color;
  final int tryCount;
  final int success;

  Hold({
    required this.color,
    required this.tryCount,
    required this.success,
  });

  factory Hold.fromJson(Map<String, dynamic> json) {
    return Hold(
      color: json['color'],
      tryCount: json['tryCount'],
      success: json['success'],
    );
  }
}

class StatisticsModel {
  final ClimbGround climbGround;
  final int success;
  final double successRate;
  final int tryCount;
  final List<Hold> holds;

  StatisticsModel({
    required this.climbGround,
    required this.success,
    required this.successRate,
    required this.tryCount,
    required this.holds,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      climbGround: ClimbGround.fromJson(json['content']['climbground']),
      success: json['content']['success'] as int,
      successRate: (json['content']['success_rate'] as num).toDouble(),
      tryCount: json['content']['tryCount'] as int,
      holds: (json['content']['holds'] as List)
          .map((hold) => Hold.fromJson(hold))
          .toList(),
    );
  }
}
