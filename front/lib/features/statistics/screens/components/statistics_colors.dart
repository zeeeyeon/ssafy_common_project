import 'package:flutter/material.dart';

/// ✅ 클라이밍 홀드 색상 변환 함수
Color getColorFromName(String colorName) {
  switch (colorName.toUpperCase()) {
    case 'RED':
      return Colors.red;
    case 'ORANGE':
      return Colors.orange;
    case 'YELLOW':
      return Colors.yellow;
    case 'GREEN':
      return Colors.green;
    case 'BLUE':
      return const Color.fromARGB(255, 4, 83, 148);
    case 'SODOMY':
      return const Color.fromARGB(255, 43, 1, 114);
    case 'PURPLE':
      return Colors.purple;
    case 'BROWN':
      return Colors.brown;
    case 'PINK':
      return Colors.pink;
    case 'GRAY':
      return Colors.grey;
    case 'BLACK':
      return Colors.black;
    case 'WHITE':
      return Colors.white;
    case 'SKYBLUE':
      return const Color.fromARGB(255, 130, 192, 220);
    case 'LIGHT_GREEN':
      return Colors.lightGreen;
    default:
      return Colors.grey;
  }
}
