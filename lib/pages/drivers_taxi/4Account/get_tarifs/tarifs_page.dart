import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taksi/services/request_helper.dart';
import 'package:taksi/services/utils/toats/error.dart';
import 'package:taksi/services/utils/toats/succes.dart';
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
        showErrorToast(context, 'Tarif', 'Tariflarni yuklashda xatolik!');
      }
    } catch (e) {
      showErrorToast(context, 'Tarif', 'Tarmoq xatoligi!');
    }
  }

  Future<void> _getTarif(bool isConfirmed, int tariffId) async {
    try {
      final response = await requestHelper.postWithAuth(
        '/services/zyber/api/payments/subscribe-tariff',
        {"tariff_id": tariffId, "buy": isConfirmed},
        log: false,
      );

      final int status = response['status'] is int
          ? response['status']
          : int.tryParse(response['status'].toString()) ?? 0;

      final String ssssssss = response['message'];

      if (status == 1) {
        showSuccessToast(context, 'Tarif', ssssssss);
      } else if (status == 3) {
        showSuccessToast(context, 'Tarif', ssssssss);
      } else if (status == 2) {
        _showLogoutDialog(response['message'], tariffId);
      } else {
        showErrorToast(context, 'Tarif', 'Xatolik!');
      }
    } catch (e) {
      showErrorToast(context, 'Tarif', 'Tarmoq xatoligi!');
    }
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
                await _getTarif(true, tariffId);
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
      backgroundColor: AppColors.backgroundColor,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ExpansionTileCard(
        elevation: 2,
        baseColor: AppColors.ui,
        expandedColor: AppColors.ui,
        initiallyExpanded: index == 2,
        title: Text(
          tariff['name'],
          style: AppStyle.fontStyle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Icon(Icons.expand_more),
        children: [
          Divider(thickness: 1.0, height: 1.0),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildPriceRow(
                  "Ta’rif narxi (oyiga)",
                  tariff['monthly'],
                ),
                _buildPriceRow("Chegirma narxi", tariff['description'],
                    isDiscount: true),
                Divider(),
                _buildPriceRow("Jami", tariff['price'], isTotal: true),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _getTarif(false, tariff['id']);
                    print(
                        "Выбран тариф: ${tariff['name']}, ID: ${tariff['id']}");
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, dynamic amount,
      {bool isDiscount = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: isDiscount ? Colors.grey : Colors.black,
                  fontSize: 16)),
          Text(
            "${amount.toString()} so’m",
            style: TextStyle(
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal
                  ? Colors.teal[900]
                  : isDiscount
                      ? Colors.grey
                      : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
