import 'package:flutter/material.dart';
import 'package:kkulkkulk/common/utils/color_converter.dart';

class ColorIndicator extends StatelessWidget {
  final String color;

  const ColorIndicator({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
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
}
