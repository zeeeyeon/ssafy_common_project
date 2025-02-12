class Hold {
  final int id;
  final String color;
  final String level;

  Hold({
    required this.id,
    required this.color,
    required this.level,
  });

  factory Hold.fromJson(Map<String, dynamic> json) {
    return Hold(
      id: json['id'] as int,
      color: json['color'] as String,
      level: json['level'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'color': color,
      'level': level,
    };
  }
}
