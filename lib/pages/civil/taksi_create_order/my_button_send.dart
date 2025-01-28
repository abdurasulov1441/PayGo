import 'package:flutter/material.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class MyCustomButtonForSend extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;

  const MyCustomButtonForSend({
    super.key,
    this.onPressed,
    this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.grade1,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: AppStyle.fontStyle.copyWith(
                    color: AppColors.ui,
                    fontSize: 16,
                    fontWeight: FontWeight.w800),
              ),
            ],
          )),
    );
  }
}
