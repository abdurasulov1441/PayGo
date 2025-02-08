import 'package:flutter/material.dart';
import 'package:taksi/services/db/cache.dart';
import 'package:taksi/services/request_helper.dart';

class CivilTaksiHistoryPage extends StatefulWidget {
  const CivilTaksiHistoryPage({super.key});

  @override
  State<CivilTaksiHistoryPage> createState() => _CivilTaksiHistoryPageState();
}

class _CivilTaksiHistoryPageState extends State<CivilTaksiHistoryPage> {
  List<Map<String, dynamic>> order = [];

  @override
  void initState() {
    super.initState();
    _orderHistory();
  }

  Future<void> _orderHistory() async {
    final usertoken = cache.getString('accessToken');
    try {
      final response = await requestHelper
          .getWithAuth('/services/zyber/api/orders/get-my-orders', log: true);
      setState(() {
        order = List<Map<String, dynamic>>.from(response['orders']);
        print(order);

        print(usertoken);
      });

      print(response);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: order.length,
              itemBuilder: (context, index) {
                final orders = order[index];
                return Card(
                  child: Column(
                    children: [
                      Text(orders['id'].toString()),
                      Text(orders['from_location']),
                      Text(orders['to_location']),
                      Text(orders['passenger_count'].toString()),
                      Text(orders['status']),
                      Text(orders['time']),
                      Text(orders['pochta'] ?? ''),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
