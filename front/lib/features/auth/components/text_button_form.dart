import 'package:flutter/material.dart';

class TextButtonForm extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const TextButtonForm(this.text, this.onPressed, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48.0,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 248, 132, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
