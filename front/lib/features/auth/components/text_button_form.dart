import 'package:flutter/material.dart';

class TextButtonForm extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const TextButtonForm(this.text, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, 
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: Color(0xFF8A9EA6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),  
          ),
          padding: EdgeInsets.symmetric(vertical: 16), 
        ),
      ),
    );
  }
}
