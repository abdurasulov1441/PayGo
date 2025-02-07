import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:taksi/app/router.dart';
import 'package:taksi/services/gradientbutton.dart';
import 'package:taksi/services/language/language_select_page.dart';
import 'package:taksi/services/request_helper.dart';
import 'package:taksi/services/snack_bar.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController nameTextInputController = TextEditingController();
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

  @override
  void dispose() {
    nameTextInputController.dispose();
    phoneTextInputController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    try {
      final response = await requestHelper.post(
          '/services/zyber/api/auth/register',
          {
            'name': nameTextInputController.text.trim(),
            'phone_number': phoneTextInputController.text.trim(),
          },
          log: true);

      SnackBarService.showSnackBar(context, response['message'], false);

      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        context.go(
          Routes.verfySMS,
          extra: phoneTextInputController.text.trim(),
        );
      }
    } catch (e) {
      SnackBarService.showSnackBar(
          context, 'Internetga ulanishda xatolik', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentFlag = context.locale == const Locale('uz')
        ? '🇺🇿'
        : context.locale == const Locale('ru')
            ? '🇷🇺'
            : '🇺🇿';
    return Scaffold(
      backgroundColor: AppColors.ui,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Form(
          key: formKey,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => showLanguageBottomSheet(context),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 25,
                        child: Text(
                          currentFlag,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Image.asset(
                  'assets/images/logo.png',
                  // fit: BoxFit.cover,
                  width: 200,
                  height: 200,
                ),
                Text(
                  'registration'.tr(),
                  style: AppStyle.fontStyle.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grade1,
                  ),
                ),
                const SizedBox(height: 30),
                buildTextField(
                  nameTextInputController,
                  'enter_name'.tr(),
                  Icons.person,
                  validator: (name) {
                    if (name == null || name.isEmpty) {
                      return 'enter_name'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                buildTextField(
                  phoneTextInputController,
                  'phone_number'.tr(),
                  Icons.phone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_phoneNumberFormatter],
                  validator: (phone) {
                    if (phone == null || phone.isEmpty) {
                      return 'enter_phone_format'.tr();
                    } else if (!RegExp(r'^\+998 \(\d{2}\) \d{3} \d{2} \d{2}$')
                        .hasMatch(phone)) {
                      return 'enter_corectly_phone_format'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                GradientButton(
                  onPressed: signUp,
                  text: 'registration'.tr(),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('have_account'.tr()),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'login'.tr(),
                        style: AppStyle.fontStyle.copyWith(
                          color: AppColors.grade1,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String hintText,
    IconData icon, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: TextFormField(
        style: AppStyle.fontStyle.copyWith(color: AppColors.grade1),
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: validator,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon, color: AppColors.grade1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide.none,
          ),
          hintText: hintText,
          hintStyle: AppStyle.fontStyle.copyWith(color: Colors.grey),
        ),
      ),
    );
  }
}
