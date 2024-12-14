import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taksi/services/snack_bar.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool isHiddenPassword = true;
  TextEditingController phoneTextInputController =
      TextEditingController(text: '+998 ');
  TextEditingController passwordTextInputController = TextEditingController();
  TextEditingController passwordTextRepeatInputController =
      TextEditingController();
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
      if (text.isNotEmpty) formatted.write('(${text.substring(0, 2)}');
      if (text.length > 2) formatted.write(') ${text.substring(2, 5)}');
      if (text.length > 5) formatted.write(' ${text.substring(5, 7)}');
      if (text.length > 7) formatted.write(' ${text.substring(7)}');

      return TextEditingValue(
        text: formatted.toString(),
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    },
  );

  @override
  void dispose() {
    phoneTextInputController.dispose();
    passwordTextInputController.dispose();
    passwordTextRepeatInputController.dispose();
    super.dispose();
  }

  void togglePasswordView() {
    setState(() {
      isHiddenPassword = !isHiddenPassword;
    });
  }

  Future<void> signUp() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    if (passwordTextInputController.text !=
        passwordTextRepeatInputController.text) {
      SnackBarService.showSnackBar(
          context, 'Parollar bir xil bo‘lishi kerak', true);
      return;
    }

    // Ваша логика регистрации пользователя через номер телефона
    SnackBarService.showSnackBar(
        context, 'Ro’yxatdan muvaffaqiyatli o’tdingiz!', false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 120),
              Text(
                'Ro’yxatdan o’tish',
                style: AppStyle.fontStyle.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 100,
                  height: 100,
                ),
              ),
              const SizedBox(height: 20),
              buildTextField(
                phoneTextInputController,
                'Telefon raqam (+998 XXX XXX XX XX)',
                Icons.phone,
                keyboardType: TextInputType.phone,
                inputFormatters: [_phoneNumberFormatter],
                validator: (phone) {
                  if (phone == null || phone.isEmpty) {
                    return 'Telefon raqamni kiriting';
                  } else if (!RegExp(r'^\+998 \(\d{2}\) \d{3} \d{2} \d{2}$')
                      .hasMatch(phone)) {
                    return 'To’g’ri formatni kiriting: +998 (XX) XXX XX XX';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              buildTextField(
                passwordTextInputController,
                'Parol',
                Icons.lock,
                obscureText: isHiddenPassword,
                validator: (value) => value != null && value.length < 6
                    ? 'Kamida 6 ta belgidan iborat bo’lishi kerak'
                    : null,
              ),
              const SizedBox(height: 15),
              buildTextField(
                passwordTextRepeatInputController,
                'Parolni qayta kiriting',
                Icons.lock,
                obscureText: isHiddenPassword,
                validator: (value) =>
                    value != null && value != passwordTextInputController.text
                        ? 'Parollar mos kelishi kerak'
                        : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.taxi,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: signUp,
                child: Text('Ro’yxatdan o’tish',
                    style: AppStyle.fontStyle.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Akkauntingiz bormi?'),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Kirish',
                        style:
                            AppStyle.fontStyle.copyWith(color: AppColors.taxi),
                      )),
                ],
              )
            ],
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
    return TextFormField(
      style: AppStyle.fontStyle.copyWith(color: AppColors.textColor),
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[100],
        prefixIcon: Icon(icon, color: AppColors.taxi),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        hintText: hintText,
        hintStyle: AppStyle.fontStyle.copyWith(color: Colors.grey),
      ),
    );
  }
}
