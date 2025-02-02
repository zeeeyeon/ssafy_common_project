import 'package:flutter/material.dart';

class TextForm extends StatelessWidget {
  final String text;
  final TextEditingController controller;
  final String? Function(String?)? validator; // 유효성 검사 함수
  final bool isPassword; // 비밀번호 여부

  const TextForm(
    this.text,
    this.controller, {
    Key? key,
    this.validator, // validator를 외부에서 전달받을 수 있도록 함
    this.isPassword = false, // 기본값은 false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          validator: validator, // 외부에서 전달받은 유효성 검사 함수 적용
          obscureText: isPassword, // 비밀번호 필드에서는 텍스트 숨기기
          autovalidateMode: AutovalidateMode.onUserInteraction, // 자동 유효성 검사
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
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: Color(0xFF8A9EA6),
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: Colors.red, // 에러 시 빨간색으로 변경
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: Colors.red, // 포커스 시 에러 빨간색
              ),
            ),
          ),
        ),
      ],
    );
  }
}
