class AlbumItem {
  final String url;
  final String thumbnailUrl;
  final String color;
  final String level;
  final String name;
  final bool isSuccess;

  AlbumItem({
    required this.url,
    required this.thumbnailUrl,
    required this.color,
    required this.level,
    required this.name,
    required this.isSuccess,
  });

  factory AlbumItem.fromJson(Map<String, dynamic> json) {
    return AlbumItem(
      url: json['url'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      color: json['color'] as String,
      level: json['level'] as String,
      name: json['name'] as String,
      isSuccess: json['isSuccess'] as bool,
    );
  }
}

class AlbumResponse {
  final List<AlbumItem> albumObject;

  AlbumResponse({required this.albumObject});

  factory AlbumResponse.fromJson(Map<String, dynamic> json) {
    return AlbumResponse(
      albumObject: (json['albumObject'] as List)
          .map((item) => AlbumItem.fromJson(item))
          .toList(),
    );
  }
}
