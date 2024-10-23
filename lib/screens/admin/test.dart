import 'package:flutter/material.dart';
import 'package:taksi/style/app_style.dart';

class OrderStatisticsPage extends StatelessWidget {
  const OrderStatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Buyurtmalar statistikasi',
        style: AppStyle.fontStyle
            .copyWith(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class UserDriverStatisticsPage extends StatelessWidget {
  const UserDriverStatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Foydalanuvchi va haydovchi statistikasi',
        style: AppStyle.fontStyle
            .copyWith(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

