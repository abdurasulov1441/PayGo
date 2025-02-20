import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:taksi/pages/drivers_taxi/3History/order_history_widget.dart';
import 'package:taksi/services/request_helper.dart';
import 'package:taksi/services/style/app_colors.dart';
import 'package:taksi/services/style/app_style.dart';

class TaxiOrdersHistoryPage extends StatefulWidget {
  const TaxiOrdersHistoryPage({super.key});

  @override
  State<TaxiOrdersHistoryPage> createState() => _TaxiOrdersHistoryPageState();
}

class _TaxiOrdersHistoryPageState extends State<TaxiOrdersHistoryPage> {
  List<Map<String, dynamic>> order = [];
  bool isEmpty = false;

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
        if (order.isEmpty) {
          isEmpty = true;
        } else {
          isEmpty = false;
        }
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
      backgroundColor: AppColors.ui,
      appBar: AppBar(
        backgroundColor: AppColors.grade1,
        title: Text(
          'Buyurtmalar tarixi',
          style: AppStyle.fontStyle
              .copyWith(color: AppColors.backgroundColor, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _getOrderHistory,
        color: AppColors.grade1,
        child: isEmpty
            ? SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Center(
                      child:
                          LottieBuilder.asset('assets/lottie/not_found.json'),
                    ),
                    Text(
                      'Buyurtmalar tarixi topilmadi',
                      style: AppStyle.fontStyle
                          .copyWith(color: AppColors.grade1, fontSize: 20),
                    ),
                  ],
                ),
              )
            : ListView.builder(
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
      ),
    );
  }
}
