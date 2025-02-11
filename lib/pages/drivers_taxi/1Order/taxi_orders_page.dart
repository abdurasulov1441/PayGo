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
      setState(() {
        order.removeWhere((order) => order['id'] == orderId);
      });
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
          onRefresh: _getOrders,
          child: ListView.builder(
            itemCount: order.length,
            itemBuilder: (context, index) {
              final currentOrder = order[index];

              return OrderWidget(
                orderNumber: currentOrder['id'] ?? 0,
                status: currentOrder['status'] ?? '',
                customer: currentOrder['name'] ?? '',
                fromLocation: currentOrder['from_location']!,
                toLocation: currentOrder['to_location']!,
                peopleCount: currentOrder['passenger_count']?.toString(),
                cargoName: currentOrder['pochta']?.toString(),
                onAccept: () => _acceptOrders(currentOrder['id']),
                fromDateTime: currentOrder['from_date_time'] ?? '',
                toDateTime: currentOrder['to_date_time'] ?? '',
              );
            },
          ),
        ));
  }
}
