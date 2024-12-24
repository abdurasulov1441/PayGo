import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taksi/app/router.dart';

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
            Icon(icon),
            SizedBox(
              width: 10,
            ),
            Text(name)
          ],
        ));
  }
}
