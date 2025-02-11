import 'package:flutter/material.dart';
import 'package:kkulkkulk/common/utils/color_converter.dart';

class AlbumItem {
  final String url;
  final String thumbnailUrl;
  final String color;
  final String level;
  final String name;

  AlbumItem({
    required this.url,
    required this.thumbnailUrl,
    required this.color,
    required this.level,
    required this.name,
  });

  factory AlbumItem.fromJson(Map<String, dynamic> json) {
    return AlbumItem(
      url: json['url'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      color: json['color'] as String? ?? '',
      level: json['level'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  // 색상 표시를 위한 위젯
  Widget buildColorIndicator() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: ColorConverter.fromString(color),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }

  // 레벨 표시를 위한 위젯
  Widget buildLevelIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        level,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class AlbumResponse {
  final List<AlbumItem> albumObject;
  final bool success;
  final String date;

  AlbumResponse({
    required this.albumObject,
    required this.success,
    required this.date,
  });

  factory AlbumResponse.fromJson(Map<String, dynamic> json) {
    final content = json['content'] as Map<String, dynamic>;
    final albumObjectJson = content['albumObject'] as List;

    return AlbumResponse(
      albumObject: albumObjectJson
          .map((item) => AlbumItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      success: content['success'] as bool? ?? false,
      date: content['date'] as String? ?? '',
    );
  }
}
