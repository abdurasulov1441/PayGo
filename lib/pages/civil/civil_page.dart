import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:taksi/app/router.dart';
import 'package:taksi/pages/civil/custom_app_bar.dart';
import 'package:taksi/services/db/cache.dart';
import 'package:taksi/services/request_helper.dart';
import 'package:taksi/services/style/app_colors.dart';
import 'package:taksi/services/style/app_style.dart';

class MainCivilPage extends StatefulWidget {
  const MainCivilPage({super.key});

  @override
  State<MainCivilPage> createState() => _MainCivilPageState();
}

class _MainCivilPageState extends State<MainCivilPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> order = [];

  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
    _getMyOrders();
  }

  void _startLocationUpdates() {
    _sendLocationToServer();
    _locationTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _sendLocationToServer();
    });
  }

// get my orders from server
  Future<void> _getMyOrders() async {
    try {
      final response = await requestHelper.getWithAuth(
        "/services/zyber/api/orders/get-my-orders?status=1,2",
        log: false,
      );
      if (response['status'] == 200) {
        setState(() {
          order = List<Map<String, dynamic>>.from(response['orders']);
        });
        print(order);
      }

      print("🚚 Мои заказы: $response");
    } catch (e) {
      print("❌ Ошибка получения заказов: $e");
    }
  }

  Future<void> _sendLocationToServer() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final response = await requestHelper.putWithAuth(
        "/services/zyber/api/users/update-location",
        {
          "lat": position.latitude.toString(),
          "long": position.longitude.toString(),
        },
        log: true,
      );

      print(
          "📍 Координаты отправлены: ${position.latitude}, ${position.longitude}");
    } catch (e) {
      print("❌ Ошибка отправки координат: $e");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Важно! Передаем ключ сюда
      appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
      drawer: Drawer(
        child: Column(
          children: [
            _buildHeader(),
            _buildMenuItem(
              icon: Icons.person_outline,
              text: "Akkunt ma'lumotlari",
              onTap: () => context.push(Routes.settingsPage),
            ),
            _buildMenuItem(
              icon: Icons.local_taxi,
              text: "Taksi tarixi",
              onTap: () => context.push(Routes.civilTaksiHistoryPage),
            ),
            _buildMenuItem(
              icon: Icons.local_shipping,
              text: "Yuk tarixi",
              onTap: () => context.push(Routes.settingsPage),
            ),
            _buildMenuItem(
              icon: Icons.settings,
              text: "Sozlamalar",
              onTap: () => context.push(Routes.settingsPage),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                cache.clear();
                context.go(Routes.loginScreen);

                print("Chiqish");
              },
              child: Text(
                "Chiqish",
                style: AppStyle.fontStyle.copyWith(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      backgroundColor: AppColors.ui,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Buyurtma berish',
                      style: AppStyle.fontStyle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grade1),
                    ),
                  ),
                  GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    shrinkWrap: true,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      GestureDetector(
                        onTap: () {
                          context.push(
                            Routes.taxiPage,
                          );
                        },
                        child: transportCard(
                          'Yuk mashinalar',
                          'truck',
                          Colors.green,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.push(
                            Routes.taxiPage,
                          );
                        },
                        child: transportCard(
                          'Yengi avto mashinalar',
                          'car',
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 20),
                    child: Text(
                      'Faol buyurtmalar',
                      style: AppStyle.fontStyle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grade1),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: order.length,
                      itemBuilder: (context, index) {
                        final currentOrder = order[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.backgroundColor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: currentOrder['status_id'] == 1
                                      ? const Color.fromARGB(88, 204, 223, 40)
                                      : const Color.fromARGB(110, 40, 194, 48),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Buyurtma №${currentOrder['id']}',
                                            style: AppStyle.fontStyle.copyWith(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Spacer(),
                                          Text(
                                            '${currentOrder['status']}',
                                            style: AppStyle.fontStyle.copyWith(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  currentOrder['status_id'] == 1
                                                      ? const Color.fromARGB(
                                                          255, 128, 98, 2)
                                                      : const Color.fromARGB(
                                                          255, 42, 97, 44),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Text(
                                            ' ${currentOrder['from_location']}',
                                            style: AppStyle.fontStyle
                                                .copyWith(fontSize: 14),
                                          ),
                                          Spacer(),
                                          Icon(
                                            Icons.arrow_forward,
                                            color: AppColors.grade1,
                                          ),
                                          Spacer(),
                                          Text(
                                            '${currentOrder['to_location']}',
                                            style: AppStyle.fontStyle
                                                .copyWith(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Text(
                                            'Buyurtma vaqti: ${currentOrder['date']}',
                                            style: AppStyle.fontStyle
                                                .copyWith(fontSize: 14),
                                          ),
                                          Spacer(),
                                          if (currentOrder['passenger_count'] ==
                                              0)
                                            Text(
                                              'Pochta: ${currentOrder['pochta']}',
                                              style: AppStyle.fontStyle
                                                  .copyWith(fontSize: 14),
                                            )
                                          else
                                            Text(
                                              'Odamlar: ${currentOrder['passenger_count']}',
                                              style: AppStyle.fontStyle
                                                  .copyWith(fontSize: 14),
                                            )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 120,
                                            height: 30,
                                            child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          213, 241, 44, 30),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                ),
                                                onPressed: () {},
                                                child: Text(
                                                  'Bekor qilish',
                                                  style: AppStyle.fontStyle
                                                      .copyWith(
                                                          fontSize: 12,
                                                          color: AppColors
                                                              .backgroundColor),
                                                )),
                                          ),
                                          Spacer(),
                                          if (currentOrder['status_id'] == 1)
                                            SizedBox(
                                              width: 200,
                                              height: 30,
                                              child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        AppColors.grade1,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    context.push(
                                                      Routes.nearCars,
                                                    );
                                                  },
                                                  child: Text(
                                                    'Sizga yaqin transportlar',
                                                    style: AppStyle.fontStyle
                                                        .copyWith(
                                                            fontSize: 12,
                                                            color: AppColors
                                                                .backgroundColor),
                                                  )),
                                            )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget transportCard(String title, String icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            radius: 40,
            child: SvgPicture.asset(
              'assets/icons/$icon.svg',
              height: 30,
              width: 30,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: AppStyle.fontStyle.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.uiText),
          ),
        ],
      ),
    );
  }
}

Widget _buildHeader() {
  return UserAccountsDrawerHeader(
    decoration: BoxDecoration(color: AppColors.grade1),
    accountName: Text("Lorem Lorem",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    accountEmail:
        Text("Planned: 216  •  Completed: 512", style: TextStyle(fontSize: 14)),
    currentAccountPicture: CircleAvatar(
      backgroundColor: Colors.white,
      child: Icon(Icons.person, size: 50, color: AppColors.grade1),
    ),
  );
}

Widget _buildMenuItem(
    {required IconData icon,
    required String text,
    required VoidCallback onTap}) {
  return ListTile(
    leading: Icon(icon, color: AppColors.grade1),
    title: Text(text, style: AppStyle.fontStyle.copyWith(fontSize: 16)),
    onTap: onTap,
  );
}
