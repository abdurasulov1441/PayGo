import 'package:flutter/material.dart';
import 'package:taksi/pages/drivers_taxi/2Accepted/order_accpeted_widget.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class TaxiAcceptedOrdersPage extends StatelessWidget {
  const TaxiAcceptedOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample static data for the orders
    final orders = [
      {
        'orderNumber': '2132',
        'status': 'Qabul qilingan',
        'customer': 'Abdulaziz',
        'fromLocation': 'Namangan',
        'fromDateTime': '24.10.2024 12:37',
        'toLocation': 'Toshkent',
        'toDateTime': '24.10.2024 15:37',
        'cargoWeight': '400 kg',
        'cargoName': 'Paxta simga oralgan'
      },
      {
        'orderNumber': '2133',
        'status': 'Qabul qilingan',
        'customer': 'Anvar',
        'fromLocation': 'Andijon',
        'fromDateTime': '25.10.2024 10:00',
        'toLocation': 'Samarqand',
        'toDateTime': '25.10.2024 15:00',
        'cargoWeight': '300 kg',
        'cargoName': 'Meva yuklangan'
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.grade1,
        title: Text(
          'Buyurtmalar',
          style: AppStyle.fontStyle
              .copyWith(color: AppColors.backgroundColor, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Dismissible(
            key: Key(order['orderNumber']!),
            direction: DismissDirection.horizontal,
            onDismissed: (direction) {
              if (direction == DismissDirection.startToEnd) {
                // Swipe right action
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Buyurtma ${order['orderNumber']} qabul qilindi!',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (direction == DismissDirection.endToStart) {
                // Swipe left action
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Buyurtma ${order['orderNumber']} rad etildi!',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            background: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              color: Colors.green,
              child: const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 30,
              ),
            ),
            secondaryBackground: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: Colors.red,
              child: const Icon(
                Icons.cancel,
                color: Colors.white,
                size: 30,
              ),
            ),
            child: OrderAcceptedWidget(
              orderNumber: order['orderNumber']!,
              status: order['status']!,
              customer: order['customer']!,
              fromLocation: order['fromLocation']!,
              fromDateTime: order['fromDateTime']!,
              toLocation: order['toLocation']!,
              toDateTime: order['toDateTime']!,
              cargoWeight: order['cargoWeight']!,
              cargoName: order['cargoName']!,
            ),
          );
        },
      ),
    );
  }
}
