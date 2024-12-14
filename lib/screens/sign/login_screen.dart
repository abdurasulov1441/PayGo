import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taksi/screens/sign/signup_screen.dart';
import 'package:taksi/services/gradientbutton.dart';
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

  // Форматтер для номера телефона
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

    final url = Uri.parse('https://paygo.app-center/api/auth/login');
    final headers = {
      'Content-Type': 'application/json',
      'accept': 'application/json',
    };
    final body = jsonEncode({
      'phone_number': phoneTextInputController.text.trim(),
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Сохранение токена в SharedPreferences
        final token = responseData['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        // Вывод сообщения об успешном входе
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );

        // Навигация на другой экран (при необходимости)
        Navigator.pushNamedAndRemoveUntil(
            context, '/home', (Route<dynamic> route) => false);
      } else {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: ${responseData['message']}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка соединения: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textColor,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Xush kelibsiz !',
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
                    return 'Telefon raqamni kiriting';
                  } else if (!RegExp(r'^\+998 \(\d{2}\) \d{3} \d{2} \d{2}$')
                      .hasMatch(phone)) {
                    return 'To\'g\'ri formatni kiriting: +998 (XX) XXX XX XX';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  prefixIcon: const Icon(Icons.phone, color: AppColors.grade2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  hintText: '+998 (XX) XXX XX XX',
                  hintStyle: AppStyle.fontStyle.copyWith(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 20),
              GradientButton(
                onPressed: login,
                text: 'Kirish',
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Akkauntingiz yo\'qmi?'),
                  const SizedBox(width: 5),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignUpScreen()),
                      );
                    },
                    child: Text(
                      'Ro\'yxatdan o\'tish',
                      style:
                          AppStyle.fontStyle.copyWith(color: AppColors.grade2),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
