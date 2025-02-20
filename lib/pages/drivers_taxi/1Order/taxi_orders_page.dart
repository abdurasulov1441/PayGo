import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:taksi/app/router.dart';
import 'package:taksi/pages/drivers_taxi/1Order/order_widget.dart';
import 'package:taksi/services/db/cache.dart';
import 'package:taksi/services/request_helper.dart';
import 'package:taksi/services/style/app_colors.dart';
import 'package:taksi/services/style/app_style.dart';

class TaxiOrdersPage extends StatefulWidget {
  const TaxiOrdersPage({super.key});

  @override
  State<TaxiOrdersPage> createState() => _TaxiOrdersPageState();
}

class _TaxiOrdersPageState extends State<TaxiOrdersPage> {
  List<Map<String, dynamic>> order = [];
  bool isEmpty = false;
  int? isActiveUser = cache.getInt('user_status');

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
    _getOrders();
  }

  Future<void> _getOrders() async {
    _checkUserStatus();
    try {
      final response = await requestHelper.getWithAuth(
          '/services/zyber/api/orders/get-new-taxi-orders',
          log: false);

      setState(() {
        order = List<Map<String, dynamic>>.from(response['orders']);

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

  Future<void> _acceptOrders(int orderId) async {
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

  // get user status
  Future<Map<String, dynamic>?> _checkUserStatus() async {
    try {
      final response = await requestHelper
          .getWithAuth('/services/zyber/api/users/get-user-status', log: true);
      setState(() {
        isActiveUser = response['status'];
      });
      cache.setInt('user_status', response['status']);
    } catch (e) {
      return null;
    }
    return null;
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
          child: isEmpty
              ? SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 100,
                      ),
                      Center(
                          child: isActiveUser == 3
                              ? Lottie.asset('assets/lottie/upgrade_plan.json',
                                  width: 250, height: 250)
                              : Lottie.asset('assets/lottie/not_found.json')),
                      if (isActiveUser == 3)
                        Column(
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              textAlign: TextAlign.center,
                              'Yangi buyurtmalarni ko‘rish uchun',
                              style: AppStyle.fontStyle.copyWith(
                                  color: AppColors.grade1, fontSize: 20),
                            ),
                            Text(
                              textAlign: TextAlign.center,
                              'obunani faollashtiring',
                              style: AppStyle.fontStyle.copyWith(
                                  color: AppColors.grade1, fontSize: 20),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    backgroundColor: AppColors.grade1),
                                onPressed: () {
                                  context.go(Routes.tarifsPage);
                                },
                                child: Text(
                                  'Tariflar ro‘yxati',
                                  style: AppStyle.fontStyle.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.backgroundColor),
                                ))
                          ],
                        )
                      else
                        Text(
                          'Buyurtmalar topilmadi',
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
