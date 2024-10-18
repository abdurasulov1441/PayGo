import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taksi/screens/home_screen.dart';
import 'package:taksi/services/snack_bar.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) timer?.cancel();
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 5));

      setState(() => canResendEmail = true);
    } catch (e) {
      if (mounted) {
        SnackBarService.showSnackBar(
          context,
          'Xatolik yuz berdi: $e',
          true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => isEmailVerified
      ? const HomeScreen()
      : Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: AppColors.taxi,
            title: const Text(
              'Email tasdiqlash',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.email_outlined,
                    color: AppColors.taxi,
                    size: 80,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Emailingizni tasdiqlang!',
                    style: AppStyle.fontStyle.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Biz tasdiqlash xatini email manzilingizga yubordik. '
                    'Tasdiqlash uchun o‘sha xatdagi linkka bosing.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.taxi,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 32,
                      ),
                    ),
                    onPressed: canResendEmail ? sendVerificationEmail : null,
                    icon: const Icon(Icons.email),
                    label: Text(
                      'Qayta yuborish',
                      style: AppStyle.fontStyle.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () async {
                      timer?.cancel();
                      await FirebaseAuth.instance.currentUser!.delete();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Bekor qilish',
                      style: AppStyle.fontStyle.copyWith(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
}
