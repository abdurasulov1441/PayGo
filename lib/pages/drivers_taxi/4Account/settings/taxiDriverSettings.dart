import 'package:flutter/material.dart';
import 'package:taksi/style/app_colors.dart';

class Taxidriversettings extends StatelessWidget {
  const Taxidriversettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sozlamalar'),
        backgroundColor: AppColors.backgroundColor,
      ),
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
                onPressed: () {}, child: Text('Biz bilan bog\'lanish')),
            ElevatedButton(onPressed: () {}, child: Text('donat')),
            ElevatedButton(onPressed: () {}, child: Text('bizni baholash')),
            ElevatedButton(onPressed: () {}, child: Text('biz haqimizda')),
            ElevatedButton(onPressed: () {}, child: Text('ilovani ulashish')),
            ElevatedButton(
                onPressed: () {}, child: Text('Foydalanuvchi shartlari')),
            ElevatedButton(onPressed: () {}, child: Text('Maxfiylik siyosati')),
          ],
        ),
      ),
    );
  }
}
