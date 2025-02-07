import 'package:flutter/material.dart';
import 'package:taksi/style/app_colors.dart';

class Taxidriversettings extends StatelessWidget {
  const Taxidriversettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Text('Tungi Rejim'),
                Switch(value: true, onChanged: (value) {}),
              ],
            ),
            Row(
              children: [
                Text('Joylashuvni ko\'rsatish'),
                Switch(value: true, onChanged: (value) {}),
              ],
            ),
            Row(
              children: [
                Text('Bildirishnomalar'),
                Switch(value: true, onChanged: (value) {}),
              ],
            ),
            ElevatedButton(
                onPressed: () {}, child: Text('Telefon raqamni o\'zgartirish')),
            ElevatedButton(
                onPressed: () {}, child: Text('Biz bilan bog\'lanish'))
          ],
        ),
      ),
    );
  }
}
