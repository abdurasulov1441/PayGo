import 'package:flutter/material.dart';
import 'package:taksi/pages/drivers_taxi/1Order/order_widget.dart';
import 'package:taksi/services/request_helper.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class TaxiOrdersPage extends StatefulWidget {
  const TaxiOrdersPage({super.key});

  @override
  State<TaxiOrdersPage> createState() => _TaxiOrdersPageState();
}

class _TaxiOrdersPageState extends State<TaxiOrdersPage> {
  List<Map<String, dynamic>> order = [];

  @override
  void initState() {
    super.initState();
    _getOrders();
  }

  Future<void> _getOrders() async {
    try {
      final response = await requestHelper.getWithAuth(
          '/services/zyber/api/orders/get-new-taxi-orders',
          log: true);
      setState(() {
        order = List<Map<String, dynamic>>.from(response['orders']);
        print(order);
      });

      print(response);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _acceptOrders(int orderId) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ui,
      appBar: AppBar(
        backgroundColor: AppColors.grade1,
        title: Text(
          'Buyurtmalar',
          style: AppStyle.fontStyle
              .copyWith(color: AppColors.backgroundColor, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: AppColors.grade1,
        onRefresh: () async {
          await _getOrders();
        },
        child: ListView.builder(
          itemCount: order.length,
          itemBuilder: (context, index) {
            final orders = order[index];

            return Dismissible(
              key: Key(orders['orderNumber']?.toString() ?? ''),
              direction: DismissDirection.startToEnd,
              onDismissed: (direction) {
                _acceptOrders(orders['id']);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Buyurtma ${orders['orderNumber']} qabul qilindi!',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.green,
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              child: OrderWidget(
                orderNumber: orders['id'] ?? '',
                status: orders['status'] ?? '',
                customer: orders['name'] ?? '',
                fromLocation: orders['from_location']!,
                fromDateTime: orders['time']?.toString() ?? '',
                toLocation: orders['to_location']!,
                toDateTime: orders['time']!,
                peopleCount: orders['passenger_count']?.toString(),
                cargoName: orders['pochta']?.toString(),
              ),
            );
          },
        ),
      ),
    );
  }
}
