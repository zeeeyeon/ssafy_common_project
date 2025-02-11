class VideoResponse {
  final int id;
  final String url;
  final bool isSuccess;
  final String color;
  final String createdAt;

  VideoResponse({
    required this.id,
    required this.url,
    required this.isSuccess,
    required this.color,
    required this.createdAt,
  });

  factory VideoResponse.fromJson(Map<String, dynamic> json) {
    return VideoResponse(
      id: json['id'] as int,
      url: json['url'] as String,
      isSuccess: json['isSuccess'] as bool,
      color: json['color'] as String,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'isSuccess': isSuccess,
      'color': color,
      'createdAt': createdAt,
    };
  }
}
