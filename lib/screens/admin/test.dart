import 'package:flutter/material.dart';
import 'package:taksi/style/app_style.dart';

class OrderStatisticsPage extends StatelessWidget {
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

class BalanceRequestsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Balansni to\'ldirish so\'rovlari',
        style: AppStyle.fontStyle
            .copyWith(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}



class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Sozlamalar',
        style: AppStyle.fontStyle
            .copyWith(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
