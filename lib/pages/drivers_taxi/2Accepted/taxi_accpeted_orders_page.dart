import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:taksi/pages/drivers_taxi/2Accepted/order_accpeted_widget.dart';
import 'package:taksi/services/request_helper.dart';
import 'package:taksi/services/style/app_colors.dart';
import 'package:taksi/services/style/app_style.dart';

class TaxiAcceptedOrdersPage extends StatefulWidget {
  const TaxiAcceptedOrdersPage({super.key});

  @override
  State<TaxiAcceptedOrdersPage> createState() => _TaxiAcceptedOrdersPageState();
}

class _TaxiAcceptedOrdersPageState extends State<TaxiAcceptedOrdersPage> {
  List<Map<String, dynamic>> order = [];
  bool isEmpty = false;

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
        if (order.isEmpty) {
          isEmpty = true;
        } else {
          isEmpty = false;
        }
        print(order); // Печатаем отфильтрованные заказы
      });

      print(response); // Печатаем полный ответ
    } catch (e) {
      print(e); // Печатаем ошибку в случае сбоя
    }
  }

  Future<void> _rejectOrder(int orderId) async {
    try {
      final response = await requestHelper.putWithAuth(
        '/services/zyber/api/orders/accept-taxi-order',
        {
          'order_id': orderId,
        },
        log: false,
      );
      setState(() {
        order.removeWhere((order) => order['id'] == orderId);
      });
      print(response);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _finishOrder(int orderId) async {
    try {
      final response = await requestHelper.putWithAuth(
        '/services/zyber/api/orders/complete-journey',
        {
          'order_id': orderId,
        },
        log: false,
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
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.grade1,
        title: Text(
          'Qabul qilingan buyurtmalar',
          style: AppStyle.fontStyle
              .copyWith(color: AppColors.backgroundColor, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _getAcceptedOrders,
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
                      'Qabul qilingan buyurtmalar topilmadi',
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

                  return OrderAcceptedWidget(
                    orderNumber: currentOrder['id'] ?? 0,
                    status: currentOrder['status'] ?? '',
                    customer: currentOrder['name'] ?? '',
                    fromLocation: currentOrder['from_location']!,
                    toLocation: currentOrder['to_location']!,
                    peopleCount: currentOrder['passenger_count']?.toString(),
                    cargoName: currentOrder['pochta']?.toString(),
                    onReject: () => _rejectOrder(currentOrder['id']),
                    onFinish: () => _finishOrder(currentOrder['id']),
                    fromDateTime: currentOrder['from_date_time'] ?? '',
                    toDateTime: currentOrder['to_date_time'] ?? '',
                    phoneNumber: currentOrder['phone_number'] ?? '',
                  );
                },
              ),
      ),
    );
  }
}
