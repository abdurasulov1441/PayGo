import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  Future<void> _makePayment() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Iltimos, to‘g‘ri miqdor kiriting!'),
          backgroundColor: Colors.red,
        ),
      );
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
          context.push('/paymentStatus', extra: invoiceId.toString());
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
      appBar: AppBar(
        title: Text(
          'Balansni to‘ldirish',
          style: AppStyle.fontStyle.copyWith(
            color: AppColors.backgroundColor,
            fontSize: 20,
          ),
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'To‘lov uchun miqdorni kiriting',
                labelText: 'Summa',
                prefixIcon: const Icon(
                  Icons.attach_money,
                  color: AppColors.grade1,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.grade1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.grade1),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _makePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.grade1,
              ),
              child: const Text('Balansni to‘ldirish'),
            ),
          ],
        ),
      ),
    );
  }
}
