import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taksi/services/request_helper.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class TariffsPage extends StatefulWidget {
  const TariffsPage({super.key});

  @override
  _TariffsPageState createState() => _TariffsPageState();
}

class _TariffsPageState extends State<TariffsPage> {
  List<Map<String, dynamic>> tariffs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTariffs();
  }

  Future<void> _fetchTariffs() async {
    try {
      final response = await requestHelper
          .getWithAuth('/services/zyber/api/ref/get-tariffs', log: true);

      if (response != null && response is List) {
        setState(() {
          tariffs = List<Map<String, dynamic>>.from(response);
          isLoading = false;
        });
      } else {
        _showErrorSnackBar('Tariflarni yuklashda xatolik!');
      }
    } catch (e) {
      _showErrorSnackBar('Tarmoq xatoligi!');
    }
  }

  Future<void> _getTarif(bool isConfirmed, int tariffId) async {
    try {
      final response = await requestHelper.postWithAuth(
        '/services/zyber/api/payments/subscribe-tariff',
        {"tariff_id": tariffId, "buy": isConfirmed},
        log: true,
      );

      final int status = response['status'] is int
          ? response['status']
          : int.tryParse(response['status'].toString()) ?? 0;

      final String ssssssss = response['message'];

      if (status == 1) {
        ElegantNotification.success(
          width: 360,
          isDismissable: false,
          animationCurve: Curves.easeInOut,
          position: Alignment.topCenter,
          animation: AnimationType.fromTop,
          title: Text('Tarif'),
          description: Text(ssssssss),
          onDismiss: () {},
          onNotificationPressed: () {},
          shadow: BoxShadow(
            color: Colors.green,
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ).show(context);
      } else if (status == 3) {
        ElegantNotification.error(
          width: 360,
          isDismissable: false,
          animationCurve: Curves.easeInOut,
          position: Alignment.topCenter,
          animation: AnimationType.fromTop,
          title: Text('Tarif'),
          description: Text(ssssssss),
          onDismiss: () {},
          onNotificationPressed: () {},
          shadow: BoxShadow(
            color: Colors.red,
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ).show(context);
      } else if (status == 2) {
        _showLogoutDialog(response['message'], tariffId);
      } else {
        _showErrorSnackBar('Tariflarni yuklashda xatolik!');
      }
    } catch (e) {
      _showErrorSnackBar('Tarmoq xatoligi!');
    }
  }

  void _showErrorSnackBar(String message) {
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showLogoutDialog(String message, int tariffId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tarif'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Yo\'q'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _getTarif(true, tariffId); // Передаем tariffId
              },
              child: const Text('Ha'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.backgroundColor,
          ),
        ),
        title: Text(
          'Tariflar',
          style: AppStyle.fontStyle.copyWith(
            color: AppColors.backgroundColor,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.grade1,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tariffs.length,
              itemBuilder: (context, index) {
                final tariff = tariffs[index];
                return _buildTariffCard(tariff, index);
              },
            ),
    );
  }

  Widget _buildTariffCard(Map<String, dynamic> tariff, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: index == 2 ? AppColors.grade1 : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${tariff['name']}',
            style: AppStyle.fontStyle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      '${tariff['description']} so\'m tejaladi',
                      style: AppStyle.fontStyle.copyWith(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${tariff['price']} so\'m',
                    style: AppStyle.fontStyle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grade1,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    '30 000',
                    style: AppStyle.fontStyle.copyWith(
                      decoration: TextDecoration.lineThrough,
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '${tariff['monthly']} so\'m oyiga',
                    style: AppStyle.fontStyle.copyWith(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _getTarif(false, tariff['id']); // Передаем tariff['id']
              print("Выбран тариф: ${tariff['name']}, ID: ${tariff['id']}");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.grade1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Center(
              child: Text(
                'Obuna bo\'lish',
                style: AppStyle.fontStyle.copyWith(
                  color: AppColors.backgroundColor,
                  fontSize: 16,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
