/// ✅ 사용자가 방문한 클라이밍장 정보
class ClimbGround {
  final int climbGround; // 방문한 클라이밍장 개수
  final int visited; // 총 방문 횟수
  final List<int> list; // 방문한 클라이밍장 ID 리스트

  ClimbGround({
    required this.climbGround,
    required this.visited,
    required this.list,
  });

  /// ✅ JSON 데이터를 ClimbGround 객체로 변환하는 팩토리 생성자
  factory ClimbGround.fromJson(Map<String, dynamic> json) {
    return ClimbGround(
      climbGround: json['climbGround'], // 방문한 클라이밍장 개수
      visited: json['visited'], // 방문 횟수
      list: List<int>.from(json['list']), // 클라이밍장 ID 리스트
    );
  }
}

/// ✅ 특정 색상의 홀드(그립) 관련 통계 정보
class Hold {
  final String color; // 홀드 색상
  final int tryCount; // 시도 횟수
  final int success; // 성공 횟수

  Hold({
    required this.color,
    required this.tryCount,
    required this.success,
  });

  /// ✅ JSON 데이터를 Hold 객체로 변환하는 팩토리 생성자
  factory Hold.fromJson(Map<String, dynamic> json) {
    return Hold(
      color: json['color'], // 홀드 색상
      tryCount: json['tryCount'], // 시도 횟수
      success: json['success'], // 성공 횟수
    );
  }
}

/// ✅ 사용자의 전체적인 클라이밍 활동 통계 데이터 모델
class StatisticsModel {
  final ClimbGround climbGround; // 클라이밍장 관련 정보
  final int success; // 전체 성공 횟수
  final double successRate; // 성공률 (%)
  final int tryCount; // 전체 시도 횟수
  final List<Hold> holds; // 홀드별 시도 및 성공 데이터 리스트

  StatisticsModel({
    required this.climbGround,
    required this.success,
    required this.successRate,
    required this.tryCount,
    required this.holds,
  });

  /// ✅ JSON 데이터를 StatisticsModel 객체로 변환하는 팩토리 생성자
  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      climbGround:
          ClimbGround.fromJson(json['content']['climbground']), // 클라이밍장 정보 변환
      success: json['content']['success'] as int, // 성공 횟수
      successRate:
          (json['content']['success_rate'] as num).toDouble(), // 성공률 변환
      tryCount: json['content']['tryCount'] as int, // 전체 시도 횟수
      holds: (json['content']['holds'] as List)
          .map((hold) => Hold.fromJson(hold))
          .toList(), // 홀드별 데이터 리스트 변환
    );
  }
}

/// ✅ 특정 클라이밍장의 개별 통계 정보를 담는 모델
class ClimbingGymStatistics {
  final String name; // 클라이밍장 이름
  final int totalVisited; // 총 방문 횟수
  final int success; // 성공 횟수
  final double successRate; // 성공률 (%)
  final int tryCount; // 시도 횟수
  final List<Hold> holds; // 홀드별 시도 및 성공 데이터 리스트

  ClimbingGymStatistics({
    required this.name,
    required this.totalVisited,
    required this.success,
    required this.successRate,
    required this.tryCount,
    required this.holds,
  });

  /// ✅ JSON 데이터를 ClimbingGymStatistics 객체로 변환하는 팩토리 생성자
  factory ClimbingGymStatistics.fromJson(Map<String, dynamic> json) {
    return ClimbingGymStatistics(
      name: json['content']['name'], // 클라이밍장 이름
      totalVisited: json['content']['totalVisited'], // 총 방문 횟수
      success: json['content']['success'], // 성공 횟수
      successRate:
          (json['content']['success_rate'] as num).toDouble(), // 성공률 변환
      tryCount: json['content']['tryCount'], // 시도 횟수
      holds: (json['content']['holds'] as List)
          .map((hold) => Hold.fromJson(hold))
          .toList(), // 홀드별 데이터 리스트 변환
    );
  }
}

/// ✅ 클라이밍장 상세 정보 모델 (여러 클라이밍장 목록을 위한 모델)
class ClimbingGym {
  final int id;
  final String name;
  final String image;
  final String address;

  ClimbingGym({
    required this.id,
    required this.name,
    required this.image,
    required this.address,
  });

  factory ClimbingGym.fromJson(Map<String, dynamic> json) {
    return ClimbingGym(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      address: json['address'],
    );
  }
}
