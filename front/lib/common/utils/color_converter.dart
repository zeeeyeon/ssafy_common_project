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
      default:
        return Colors.grey;
    }
  }
}
