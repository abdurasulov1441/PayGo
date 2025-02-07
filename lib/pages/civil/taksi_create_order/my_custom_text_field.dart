import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class MyCustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const MyCustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        style: AppStyle.fontStyle,
        controller: controller,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          prefixIconConstraints: BoxConstraints(
            minWidth: 40,
          ),
          prefixIcon: SvgPicture.asset(
            'assets/icons/document.svg',
            height: 20,
            width: 20,
            color: AppColors.uiText,
          ),
          fillColor: AppColors.ui,
          filled: true,
          hintText: hintText,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: const EdgeInsets.all(15),
        ),
      ),
    );
  }
}
