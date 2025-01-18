import 'package:flutter/material.dart';
import 'package:taksi/services/request_helper.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class PaymentStatusPage extends StatefulWidget {
  final String invoiceId;

  const PaymentStatusPage({super.key, required this.invoiceId});

  @override
  _PaymentStatusPageState createState() => _PaymentStatusPageState();
}

class _PaymentStatusPageState extends State<PaymentStatusPage> {
  String? paymentStatus;

  Future<void> _checkPaymentStatus() async {
    try {
      final response = await requestHelper.getWithAuth(
        '/services/zyber/api/payments/payment-status?invoice_id=${widget.invoiceId}',
      );

      if (response['success'] == true) {
        final status = response['message'];

        setState(() {
          paymentStatus = status;
        });
      } else {
        setState(() {
          paymentStatus = response['message'] ?? 'Xatolik yuz berdi!';
        });
      }
    } catch (e) {
      setState(() {
        paymentStatus = 'Tarmoq xatoligi!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'To‘lov holatini tekshirish',
          style: AppStyle.fontStyle.copyWith(
            color: AppColors.backgroundColor,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.grade1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (paymentStatus != null)
              Text(
                paymentStatus!,
                textAlign: TextAlign.center,
                style: AppStyle.fontStyle.copyWith(
                  fontSize: 18,
                  color: AppColors.grade1,
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkPaymentStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.grade1,
              ),
              child: const Text('To‘lovni tekshirish'),
            ),
          ],
        ),
      ),
    );
  }
}
