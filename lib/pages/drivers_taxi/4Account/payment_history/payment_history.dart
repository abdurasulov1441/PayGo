import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taksi/services/request_helper.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  _PaymentHistoryPageState createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  List<Map<String, dynamic>> paymentHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPaymentHistory();
  }

  Future<void> _fetchPaymentHistory() async {
    try {
      final response = await requestHelper.getWithAuth(
        '/services/zyber/api/payments/payment-history',
      );

      if (response['success'] == true && response['data'] != null) {
        setState(() {
          paymentHistory = List<Map<String, dynamic>>.from(response['data']);
          isLoading = false;
        });
        print(paymentHistory);
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(response['message'] ?? 'Ma’lumotni yuklashda xatolik!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tarmoq xatoligi!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.backgroundColor,
            )),
        title: Text(
          'To‘lovlar tarixi',
          style: AppStyle.fontStyle.copyWith(
            color: AppColors.backgroundColor,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.grade1,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : paymentHistory.isEmpty
              ? const Center(
                  child: Text(
                    'Tarix mavjud emas',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: paymentHistory.length,
                  itemBuilder: (context, index) {
                    final payment = paymentHistory[index];
                    final isTarif = payment['tarif_id'] == 0;
                    final balance = payment['balance'];
                    final tarifName = payment['tariff_name'];
                    return Card(
                      elevation: 5,
                      color: AppColors.backgroundColor,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isTarif
                                  ? 'Balansni to‘ldirish'
                                  : 'Tarif sotib olish',
                              style: AppStyle.fontStyle.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isTarif
                                  ? 'To‘lov muvaffaqiyatli amalga oshirildi'
                                  : 'Tarif uchun to\'lov $tarifName',
                              style: AppStyle.fontStyle.copyWith(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$balance UZS',
                                  style: AppStyle.fontStyle.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isTarif ? Colors.green : Colors.red,
                                  ),
                                ),
                                Text(
                                  '№ ${payment['transaction_id']}',
                                  style: AppStyle.fontStyle.copyWith(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              payment['date'],
                              style: AppStyle.fontStyle.copyWith(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
