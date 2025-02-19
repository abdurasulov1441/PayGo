import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taksi/services/request_helper.dart';
import 'package:taksi/services/style/app_colors.dart';
import 'package:taksi/services/style/app_style.dart';

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
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.ui,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isTarif
                                    ? 'Balansni to‘ldirish'
                                    : 'Tarif sotib olish',
                                style: AppStyle.fontStyle.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                '$balance so\'m',
                                style: AppStyle.fontStyle.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isTarif ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          Divider(
                            color: Colors.grey,
                            thickness: 1,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('To‘lov xolati: ',
                                  style: AppStyle.fontStyle.copyWith(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  )),
                              Text(
                                isTarif
                                    ? 'Balans to‘ldirildi'
                                    : 'Tarif sotib olindi $tarifName',
                                style: AppStyle.fontStyle.copyWith(
                                    fontSize: 16,
                                    color: AppColors.grade1,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('To‘lov vaqti: ',
                                  style: AppStyle.fontStyle.copyWith(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  )),
                              Text(
                                payment['date'],
                                style: AppStyle.fontStyle.copyWith(
                                  fontSize: 16,
                                  color: AppColors.grade1,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Tranzaksiya raqami: ',
                                  style: AppStyle.fontStyle.copyWith(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  )),
                              Text(
                                '№ ${payment['transaction_id']}',
                                style: AppStyle.fontStyle.copyWith(
                                  fontSize: 16,
                                  color: AppColors.grade1,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
