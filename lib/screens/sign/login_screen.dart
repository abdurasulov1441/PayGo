import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool isHiddenPassword = true;
  TextEditingController phoneTextInputController =
      TextEditingController(text: '+998 ');
  TextEditingController passwordTextInputController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Форматтер для номера телефона
  final _phoneNumberFormatter = TextInputFormatter.withFunction(
    (oldValue, newValue) {
      if (!newValue.text.startsWith('+998 ')) {
        return oldValue;
      }

      String text = newValue.text.substring(5).replaceAll(RegExp(r'\D'), '');
      if (text.length > 9) {
        text = text.substring(0, 9);
      }

      StringBuffer formatted = StringBuffer('+998 ');
      if (text.isNotEmpty) {
        formatted.write('(${text.substring(0, min(2, text.length))}');
      }
      if (text.length > 2) {
        formatted.write(') ${text.substring(2, min(5, text.length))}');
      }
      if (text.length > 5) {
        formatted.write(' ${text.substring(5, min(7, text.length))}');
      }
      if (text.length > 7) formatted.write(' ${text.substring(7)}');

      return TextEditingValue(
        text: formatted.toString(),
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    },
  );

  void togglePasswordView() {
    setState(() {
      isHiddenPassword = !isHiddenPassword;
    });
  }

  Future<void> login() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    try {
      // Firebase login logic
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: '${phoneTextInputController.text.trim()}@phone.auth',
        password: passwordTextInputController.text.trim(),
      );
      Navigator.pushNamedAndRemoveUntil(
          context, '/home', (Route<dynamic> route) => false);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
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
                    borderRadius:
                        BorderRadius.circular(10), // Радиус скругления
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(0.2), // Цвет тени с прозрачностью
                        blurRadius: 10, // Размытие
                        offset: Offset(0, 5), // Смещение тени
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(10), // Радиус скругления
                    child: SizedBox(
                      height: 100,
                      width: 100,
                      child: Card(
                        color: Colors.white,
                        child: Image.asset(
                          'assets/images/logo.png', // Путь к вашему изображению
                          fit: BoxFit
                              .cover, // Заполняет контейнер, обрезая лишнее
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
              const SizedBox(height: 15),
              TextFormField(
                controller: passwordTextInputController,
                obscureText: isHiddenPassword,
                validator: (value) => value != null && value.length < 6
                    ? 'Kamida 6 ta belgidan iborat bo\'lishi kerak'
                    : null,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  prefixIcon: const Icon(Icons.lock, color: AppColors.grade2),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isHiddenPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: togglePasswordView,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Parolingizni kiriting',
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
