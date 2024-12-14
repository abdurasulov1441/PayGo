import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class ConfirmPasswordScreen extends StatefulWidget {
  const ConfirmPasswordScreen({super.key});

  @override
  State<ConfirmPasswordScreen> createState() => _ConfirmPasswordScreenState();
}

class _ConfirmPasswordScreenState extends State<ConfirmPasswordScreen> {
  final TextEditingController pinController = TextEditingController();
  final FocusNode pinFocusNode = FocusNode();

  @override
  void dispose() {
    pinController.dispose();
    pinFocusNode.dispose();
    super.dispose();
  }

  void verifyPin() {
    final pin = pinController.text;
    if (pin.length == 4) {
      // Add your logic to verify the PIN here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PIN kod muvaffaqiyatli tasdiqlandi!'),
        ),
      );
      // Navigate to the next page or perform an action
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PIN kod xato yoki to‘liq emas!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: AppStyle.fontStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textColor,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.taxi),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(color: AppColors.taxi, width: 2),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: Colors.grey[300],
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            Lottie.asset(
              'assets/lottie/sms.json',
              width: 150,
              height: 150,
              repeat: false,
            ),
            const SizedBox(height: 20),
            Text(
              'Tasdiqlash kodi',
              style: AppStyle.fontStyle.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'SMS orqali yuborilgan 4 xonali kodni kiriting',
              style: AppStyle.fontStyle.copyWith(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Pinput(
              length: 4,
              controller: pinController,
              focusNode: pinFocusNode,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              submittedPinTheme: submittedPinTheme,
              onCompleted: (pin) => verifyPin(),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.taxi,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: verifyPin,
              child: Text(
                'Tasdiqlash',
                style: AppStyle.fontStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Logic for resending the code
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tasdiqlash kodi qayta yuborildi!'),
                  ),
                );
              },
              child: Text(
                'Kodni qayta yuborish',
                style: AppStyle.fontStyle.copyWith(
                  color: AppColors.taxi,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
