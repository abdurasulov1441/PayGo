import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
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
  int? paymentStatusCode;
  bool isWaitingAnimation = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkPaymentStatus();
    _startPeriodicCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkPaymentStatus() async {
    try {
      final response = await requestHelper.getWithAuth(
        '/services/zyber/api/payments/payment-status?invoice_id=${widget.invoiceId}',
      );

      if (response['success'] == true) {
        final status = response['payment_status'];
        final message = response['message'];

        setState(() {
          paymentStatusCode = status;
          paymentStatus = message;
        });

        if (status == 2 || (status != null && status < 0)) {
          _timer?.cancel();
        }
      } else {
        setState(() {
          paymentStatusCode = -1;
          paymentStatus = response['message'] ?? 'Xatolik yuz berdi!';
        });
      }
    } catch (e) {
      setState(() {
        paymentStatusCode = -1;
        paymentStatus = 'Tarmoq xatoligi!';
      });
    }
  }

  void _startPeriodicCheck() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkPaymentStatus();
    });
  }

  String _getLottieAnimation() {
    if (paymentStatusCode == null ||
        paymentStatusCode == 0 ||
        paymentStatusCode == 1) {
      isWaitingAnimation = true;
      return 'assets/lottie/payment_waiting.json';
    } else if (paymentStatusCode == 2) {
      isWaitingAnimation = false;
      return 'assets/lottie/payment_done.json';
    } else if (paymentStatusCode != null && paymentStatusCode! < 0) {
      isWaitingAnimation = false;
      return 'assets/lottie/payment_error.json';
    }
    return 'assets/lottie/payment_waiting.json';
  }

  Future<bool> _onWillPop() async {
    _timer?.cancel();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final lottieAnimation = _getLottieAnimation();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            onPressed: () async {
              if (await _onWillPop()) {
                context.pop();
              }
            },
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.backgroundColor,
            ),
          ),
          title: Text(
            'To‘lov holatini tekshirish',
            style: AppStyle.fontStyle.copyWith(
              color: AppColors.backgroundColor,
              fontSize: 20,
            ),
          ),
          backgroundColor: AppColors.grade1,
        ),
        body: RefreshIndicator(
          color: Colors.white,
          backgroundColor: AppColors.grade1,
          onRefresh: _checkPaymentStatus,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppColors.headerColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              'Tranzaksiya raqami № 0034',
                              style: AppStyle.fontStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.backgroundColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text('To\'lov miqdori: 1000 so\'m'),
                        const SizedBox(height: 5),
                        const Text('Yaratilgan vaqti: 11:48 19.01.2025'),
                        const SizedBox(height: 5),
                        const Text('Invoys raqami: 164729939'),
                        const SizedBox(height: 5),
                        Text('To\'lov holati: $paymentStatus'),
                      ],
                    ),
                  ),
                  LottieBuilder.asset(
                    width: 300,
                    height: 300,
                    lottieAnimation,
                    repeat: isWaitingAnimation,
                    animate: true,
                    onLoaded: (composition) {
                      if (!isWaitingAnimation) {
                        Future.delayed(
                          composition.duration,
                          () {
                            setState(() {});
                          },
                        );
                      }
                    },
                  ),
                  if (paymentStatus != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        paymentStatus!,
                        textAlign: TextAlign.center,
                        style: AppStyle.fontStyle.copyWith(
                          fontSize: 18,
                          color: AppColors.grade1,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _checkPaymentStatus,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      backgroundColor: AppColors.grade1,
                    ),
                    child: Text(
                      'To‘lovni tekshirish',
                      style: AppStyle.fontStyle
                          .copyWith(color: AppColors.backgroundColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
