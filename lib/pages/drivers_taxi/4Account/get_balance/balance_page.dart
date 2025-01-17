import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';
import 'package:url_launcher/url_launcher.dart';

class BalancePage extends StatefulWidget {
  const BalancePage({super.key});

  @override
  _BalancePageState createState() => _BalancePageState();
}

class _BalancePageState extends State<BalancePage> {
  double currentBalance = 26000.0;
  final TextEditingController _amountController = TextEditingController();

  Future<void> _makePayment() async {
    final url = Uri.parse(
        'https://my.click.uz/services/pay?service_id=63738&merchant_id=33627&amount=1000&transaction_param=0002&return_url=https://paygo.app-center.uz/services/zyber/api/users/payment-status?transaction_param=0002');

    if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Balansni to\'ldirish',
          style: AppStyle.fontStyle
              .copyWith(color: AppColors.backgroundColor, fontSize: 20),
        ),
        backgroundColor: AppColors.grade1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.backgroundColor,
          ),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LottieBuilder.asset('assets/lottie/balance_pop_up.json'),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F8FF),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Sizning hozirgi balansingiz',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${currentBalance.toStringAsFixed(2)} UZS',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.grade1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'To\'lov uchun miqdorni kiriting',
                  labelText: 'Summa',
                  labelStyle: const TextStyle(color: AppColors.grade1),
                  prefixIcon:
                      const Icon(Icons.attach_money, color: AppColors.grade1),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.grade1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.grade1),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _makePayment();
                  // final amount = double.tryParse(_amountController.text);
                  // if (amount != null && amount > 0) {

                  // } else {
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     const SnackBar(
                  //       content: Text('Please enter a valid amount!'),
                  //       backgroundColor: Colors.red,
                  //     ),
                  //   );
                  // }
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  backgroundColor: AppColors.grade1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Balansni to\'ldirish',
                    style: AppStyle.fontStyle
                        .copyWith(color: AppColors.backgroundColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
