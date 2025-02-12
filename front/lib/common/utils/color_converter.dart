import 'package:flutter/material.dart';

class ColorConverter {
  static Color fromString(String colorString) {
    switch (colorString.toUpperCase()) {
      case 'RED':
        return Colors.red;
      case 'ORANGE':
        return Colors.orange;
      case 'YELLOW':
        return Colors.yellow;
      case 'GREEN':
        return Colors.green;
      case 'BLUE':
        return Colors.blue;
      case 'NAVY':
        return const Color(0xFF000080);
      case 'PURPLE':
        return Colors.purple;
      case 'PINK':
        return Colors.pink;
      case 'SKYBLUE':
        return Colors.lightBlueAccent;
      case 'CYAN':
        return Colors.cyan;
      case 'TEAL':
        return Colors.teal;
      case 'LIME':
        return Colors.lime;
      case 'AMBER':
        return Colors.amber;
      case 'DEEPORANGE':
        return Colors.deepOrange;
      case 'DEEPPURPLE':
        return Colors.deepPurple;
      case 'LIGHTGREEN':
        return Colors.lightGreen;
      case 'BROWN':
        return Colors.brown;
      case 'GREY':
      case 'GRAY':
        return Colors.grey;
      case 'BLACK':
        return Colors.black;
      case 'WHITE':
        return Colors.white;
      case 'SODOMY':
        return const Color(0xFF000000);
      case 'MAROON':
        return const Color(0xFF800000);
      case 'OLIVE':
        return const Color(0xFF808000);
      case 'CORAL':
        return const Color(0xFFFF7F50);
      case 'VIOLET':
        return const Color(0xFF8F00FF);
      case 'MAGENTA':
        return const Color(0xFFFF00FF);
      case 'AQUA':
        return const Color(0xFF00FFFF);
      case 'GOLD':
        return const Color(0xFFFFD700);
      case 'SILVER':
        return const Color(0xFFC0C0C0);
      default:
        return Colors.grey;
    }
  }
}
