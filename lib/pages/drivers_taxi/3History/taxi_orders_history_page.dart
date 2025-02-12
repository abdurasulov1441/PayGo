import 'package:flutter/material.dart';
import 'package:taksi/pages/drivers_taxi/3History/order_history_widget.dart';
import 'package:taksi/services/request_helper.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class TaxiOrdersHistoryPage extends StatefulWidget {
  const TaxiOrdersHistoryPage({super.key});

  @override
  State<TaxiOrdersHistoryPage> createState() => _TaxiOrdersHistoryPageState();
}

class _TaxiOrdersHistoryPageState extends State<TaxiOrdersHistoryPage> {
  List<Map<String, dynamic>> order = [];

  @override
  void initState() {
    super.initState();
    _getOrderHistory();
  }

  Future<void> _getOrderHistory() async {
    try {
      final response = await requestHelper
          .getWithAuth('/services/zyber/api/orders/get-my-orders', log: true);

      setState(() {
        order = List<Map<String, dynamic>>.from(response['orders'])
            .where((o) => o['status_id'] == 3)
            .toList();
        print(order);
      });

      print(response);
    } catch (e) {
      print(e);
    }
  }

  void _updateOrderRating(int orderId, double rating) {
    setState(() {
      for (var o in order) {
        if (o['id'] == orderId) {
          o['rating'] = rating;
          break;
        }
      }
    });
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
          return OrderHistoryWidget(
            orderNumber: currentOrder['id'] ?? '',
            status: currentOrder['status']!,
            customer: currentOrder['name'] ?? '',
            fromLocation: currentOrder['from_location']!,
            toLocation: currentOrder['to_location']!,
            peopleCount: currentOrder['passenger_count']?.toString(),
            cargoName: currentOrder['pochta']?.toString(),
            rating: currentOrder['rating'] != null
                ? double.tryParse(currentOrder['rating'].toString())
                : null,
            onRatingUpdated: _updateOrderRating,
          );
        },
      ),
    );
  }
}
