import 'dart:convert';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:taksi/app/router.dart';
import 'package:taksi/pages/sign/signup_screen.dart';
import 'package:taksi/services/gradientbutton.dart';
import 'package:taksi/services/request_helper.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController phoneTextInputController =
      TextEditingController(text: '+998 ');
  final formKey = GlobalKey<FormState>();

  final _phoneNumberFormatter = TextInputFormatter.withFunction(
    (oldValue, newValue) {
      if (!newValue.text.startsWith('+998 ')) {
        return TextEditingValue(
          text: '+998 ',
          selection: TextSelection.collapsed(offset: 5),
        );
      }

      String rawText =
          newValue.text.replaceAll(RegExp(r'[^0-9]'), '').substring(3);

      if (rawText.length > 9) {
        rawText = rawText.substring(0, 9);
      }

      String formattedText = '+998 ';
      if (rawText.isNotEmpty) {
        formattedText += '(${rawText.substring(0, min(2, rawText.length))}';
      }
      if (rawText.length > 2) {
        formattedText += ') ${rawText.substring(2, min(5, rawText.length))}';
      }
      if (rawText.length > 5) {
        formattedText += ' ${rawText.substring(5, min(7, rawText.length))}';
      }
      if (rawText.length > 7) {
        formattedText += ' ${rawText.substring(7)}';
      }

      return TextEditingValue(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    },
  );

  Future<void> login() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    try {
      final response = await requestHelper.post(
          '/services/zyber/api/auth/login',
          {
            'phone_number': phoneTextInputController.text.trim(),
          },
          log: true);

      if (response['status'] == 200) {
        String status = response['message'];
        ElegantNotification.success(
          width: 360,
          isDismissable: false,
          animationCurve: Curves.easeInOut,
          position: Alignment.topCenter,
          animation: AnimationType.fromTop,
          title: Text('Paygo'),
          description: Text(status),
          onDismiss: () {},
          onNotificationPressed: () {},
          shadow: BoxShadow(
            color: Colors.green,
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ).show(context);
        context.go(
          Routes.verfySMS,
          extra: phoneTextInputController.text.trim(),
        );
      } else {
        String status = response['message'];
        ElegantNotification.success(
          width: 360,
          isDismissable: false,
          animationCurve: Curves.easeInOut,
          position: Alignment.topCenter,
          animation: AnimationType.fromTop,
          title: Text('Tarif'),
          description: Text(status),
          onDismiss: () {},
          onNotificationPressed: () {},
          shadow: BoxShadow(
            color: Colors.green,
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ).show(context);
      }
    } catch (error) {
      ElegantNotification.success(
        width: 360,
        isDismissable: false,
        animationCurve: Curves.easeInOut,
        position: Alignment.topCenter,
        animation: AnimationType.fromTop,
        title: Text('error'.tr()),
        description: Text('error'.tr()),
        onDismiss: () {},
        onNotificationPressed: () {},
        shadow: BoxShadow(
          color: Colors.green,
          spreadRadius: 2,
          blurRadius: 5,
          offset: const Offset(0, 4),
        ),
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: formKey,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 100,
                ),
                Text(
                  "welcome".tr(),
                  style: AppStyle.fontStyle
                      .copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        height: 100,
                        width: 100,
                        child: Card(
                          color: Colors.white,
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: phoneTextInputController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_phoneNumberFormatter],
                  validator: (phone) {
                    if (phone == null || phone.isEmpty) {
                      return 'enter_phone'.tr();
                    } else if (!RegExp(r'^\+998 \(\d{2}\) \d{3} \d{2} \d{2}$')
                        .hasMatch(phone)) {
                      return 'enter_corectly_phone_format'.tr();
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    prefixIcon:
                        const Icon(Icons.phone, color: AppColors.grade1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'phone_number'.tr(),
                    hintStyle: AppStyle.fontStyle.copyWith(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),
                GradientButton(
                  onPressed: login,
                  text: 'login'.tr(),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('dont_have_account').tr(),
                    const SizedBox(width: 5),
                    TextButton(
                      onPressed: () {
                        context.push(Routes.register);
                      },
                      child: Text(
                        'registration',
                        style: AppStyle.fontStyle
                            .copyWith(color: AppColors.grade2),
                      ).tr(),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
