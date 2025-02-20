class VideoResponse {
  final int? videoId;
  final String url;
  final String thumbnailUrl;
  final int climbRecordId;

  VideoResponse({
    this.videoId,
    required this.url,
    required this.thumbnailUrl,
    required this.climbRecordId,
  });

  factory VideoResponse.fromJson(Map<String, dynamic> json) {
    return VideoResponse(
      videoId: json['videoId'] as int?,
      url: json['url'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      climbRecordId: json['climbRecordId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'videoId': videoId,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'climbRecordId': climbRecordId,
    };
  }
}
