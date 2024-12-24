import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taksi/app/router.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class MyElevatedButtonForDrawer extends StatelessWidget {
  const MyElevatedButtonForDrawer(
      {super.key, required this.icon, required this.name, required this.route});

  final IconData icon;
  final String name;
  final String route;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.grade1,
          elevation: 3,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        onPressed: () {
          context.go(route);
        },
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              name,
              style: AppStyle.fontStyle.copyWith(color: Colors.white),
            )
          ],
        ));
  }
}
