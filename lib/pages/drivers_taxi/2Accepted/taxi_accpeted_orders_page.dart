import 'package:flutter/material.dart';
import 'package:taksi/pages/drivers_taxi/2Accepted/order_accpeted_widget.dart';
import 'package:taksi/services/request_helper.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class TaxiAcceptedOrdersPage extends StatefulWidget {
  const TaxiAcceptedOrdersPage({super.key});

  @override
  State<TaxiAcceptedOrdersPage> createState() => _TaxiAcceptedOrdersPageState();
}

class _TaxiAcceptedOrdersPageState extends State<TaxiAcceptedOrdersPage> {
  List<Map<String, dynamic>> order = [];

  @override
  void initState() {
    super.initState();
    _getAcceptedOrders();
  }

  Future<void> _getAcceptedOrders() async {
    try {
      final response = await requestHelper
          .getWithAuth('/services/zyber/api/orders/get-my-orders', log: true);

      setState(() {
        // Фильтруем только заказы со status_id == 2
        order = List<Map<String, dynamic>>.from(response['orders'])
            .where((o) => o['status_id'] == 2)
            .toList();
        print(order); // Печатаем отфильтрованные заказы
      });

      print(response); // Печатаем полный ответ
    } catch (e) {
      print(e); // Печатаем ошибку в случае сбоя
    }
  }

  Future<void> _rejectOrder(String orderId) async {
    try {
      final response = await requestHelper.putWithAuth(
        '/services/zyber/api/orders/accept-taxi-order',
        {
          'order_id': orderId,
        },
        log: true,
      );
      print(response);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _finishOrder(String orderId) async {
    try {
      final response = await requestHelper.putWithAuth(
        '/services/zyber/api/orders/complete-journey',
        {
          'order_id': orderId,
        },
        log: true,
      );
      print(response);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        itemCount: order.length,
        itemBuilder: (context, index) {
          final currentOrder = order[index];
          return Dismissible(
            key: Key(currentOrder['orderNumber']?.toString() ?? ''),
            direction: DismissDirection.horizontal,
            onDismissed: (direction) {
              if (direction == DismissDirection.startToEnd) {
                _finishOrder(currentOrder['id']?.toString() ?? '');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Buyurtma ${currentOrder['orderNumber']} qabul qilindi!',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (direction == DismissDirection.endToStart) {
                _rejectOrder(currentOrder['id']?.toString() ?? '');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Buyurtma ${currentOrder['orderNumber']} rad etildi!',
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
              orderNumber: currentOrder['id'] ?? '',
              status: currentOrder['status']!,
              customer: currentOrder['name'] ?? '',
              fromLocation: currentOrder['from_location']!,
              fromDateTime: currentOrder['time']?.toString() ?? '',
              toLocation: currentOrder['to_location']!,
              toDateTime: currentOrder['time']!,
              peopleCount: currentOrder['passenger_count']?.toString(),
              cargoName: currentOrder['pochta']?.toString(),
            ),
          );
        },
      ),
    );
  }
}
