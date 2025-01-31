import 'package:flutter/material.dart';

class TextForm extends StatelessWidget{
  final String text;
  final TextEditingController controller;
  const TextForm(this.text, this.controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          validator: (value) => value!.isEmpty
          ? '$text 입력해주세요'
          : null,
          obscureText: 
            text.contains('Password') ?
            true :
            false,
          decoration: InputDecoration(
            labelText: '$text 입력',
            labelStyle: TextStyle(
              color: Color(0xFF8A9EA6),  
              fontWeight: FontWeight.bold,  
            ),
            hintText: '$text 입력해주세요',
            hintStyle: TextStyle(
              color: Color(0xFF8A9EA6),
              fontWeight: FontWeight.bold,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: Color(0xFF8A9EA6),
              )
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: Color(0xFF8A9EA6),
              )
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: Color(0xFF8A9EA6),
              )
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: Color(0xFF8A9EA6),
              )
            )
          ),
        )
      ],
    );
  }
}