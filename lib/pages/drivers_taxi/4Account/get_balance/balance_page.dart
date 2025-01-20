import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:taksi/services/request_helper.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class BalancePage extends StatefulWidget {
  const BalancePage({super.key});

  @override
  _BalancePageState createState() => _BalancePageState();
}

class _BalancePageState extends State<BalancePage> {
  final TextEditingController _amountController = TextEditingController();
  String? selectedPaymentSystem;
  Future<void> _makePayment() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount < 1000) {
      ElegantNotification.success(
        width: 360,
        isDismissable: false,
        animationCurve: Curves.bounceOut,
        position: Alignment.topCenter,
        animation: AnimationType.fromTop,
        title: Text('Update'),
        description: Text('Your data has been updated'),
        onDismiss: () {},
        onNotificationPressed: () {},
        shadow: BoxShadow(
          color: Colors.green.withOpacity(0.2),
          spreadRadius: 2,
          blurRadius: 5,
          offset: const Offset(0, 4),
        ),
      ).show(context);

      return;
    }

    try {
      final response = await requestHelper.postWithAuth(
        '/services/zyber/api/payments/make-payment',
        {'amount': amount},
      );

      if (response['success'] == true) {
        final invoiceId = response['invoice_id'];
        if (invoiceId != null) {
          ElegantNotification.success(
            width: 360,
            isDismissable: false,
            animationCurve: Curves.bounceOut,
            position: Alignment.topCenter,
            animation: AnimationType.fromTop,
            title: Text('To\'lov tizmi'),
            description: Text('Raqamingizga hisob jo\'natildi'),
            onDismiss: () {},
            onNotificationPressed: () {},
            shadow: BoxShadow(
              color: Colors.green.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 4),
            ),
          ).show(context);
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invoice ID yo‘q!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Xatolik yuz berdi!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
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
          'Balansni to‘ldirish',
          style: AppStyle.fontStyle.copyWith(
            color: AppColors.backgroundColor,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.grade1,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    'To\'lov tizimini tanlang',
                    style: AppStyle.fontStyle
                        .copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedPaymentSystem = 'Click';
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedPaymentSystem == 'Click'
                              ? AppColors.grade1
                              : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/click.png',
                            width: 120,
                            height: 120,
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ElegantNotification.success(
                        width: 360,
                        isDismissable: false,
                        animationCurve: Curves.bounceOut,
                        position: Alignment.topCenter,
                        animation: AnimationType.fromTop,
                        title: Text('Update'),
                        description: Text('Your data has been updated'),
                        onDismiss: () {},
                        onNotificationPressed: () {},
                        shadow: BoxShadow(
                          color: Colors.green.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 4),
                        ),
                      ).show(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedPaymentSystem == 'Payme'
                              ? AppColors.grade1
                              : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/payme.png',
                            width: 120,
                            height: 120,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (selectedPaymentSystem == null) ...[
                LottieBuilder.asset(
                  'assets/lottie/balance_pop_up.json',
                ),
              ] else if (selectedPaymentSystem == 'Click') ...[
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'To‘lov uchun miqdorni kiriting',
                    labelText: 'Summa',
                    labelStyle:
                        AppStyle.fontStyle.copyWith(color: AppColors.grade1),
                    prefixIcon: const Icon(
                      Icons.attach_money,
                      color: AppColors.grade1,
                    ),
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
                    final amount = double.tryParse(_amountController.text);
                    if (amount == null || amount < 1000) {
                      ElegantNotification.success(
                        width: 360,
                        isDismissable: false,
                        animationCurve: Curves.bounceOut,
                        position: Alignment.topCenter,
                        animation: AnimationType.fromTop,
                        title: Text('Update'),
                        description: Text('Your data has been updated'),
                        onDismiss: () {},
                        onNotificationPressed: () {},
                        shadow: BoxShadow(
                          color: Colors.green.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 4),
                        ),
                      ).show(context);
                    } else {
                      _makePayment();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: AppColors.grade1,
                  ),
                  child: Text(
                    'Balansni to‘ldirish',
                    style: AppStyle.fontStyle
                        .copyWith(color: AppColors.backgroundColor),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
