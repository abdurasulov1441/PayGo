import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:otp_timer_button/otp_timer_button.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taksi/screens/home_screen.dart';

import 'package:taksi/services/snack_bar.dart';
import 'package:taksi/style/app_style.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const VerificationScreen({super.key, required this.phoneNumber});

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _smsController = TextEditingController();
  late PinTheme currentPinTheme;
  bool isLoading = false;
  OtpTimerButtonController controller = OtpTimerButtonController();

  @override
  void initState() {
    super.initState();
    currentPinTheme = defaultPinTheme;
  }

  @override
  void dispose() {
    _smsController.dispose();
    super.dispose();
  }

  void _onCodeChanged(String value) {
    setState(() {
      currentPinTheme = defaultPinTheme;
    });
  }

  Future<void> resendVerificationCode(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('https://paygo.app-center.uz/api/auth/resend'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone_number': phoneNumber.trim() // Удаляем лишние символы
        }),
      );
      print(phoneNumber);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Успешный ответ
        SnackBarService.showSnackBar(context, data['message'], false);
      } else {
        // Ошибка
        SnackBarService.showSnackBar(
            context, data['message'] ?? 'Xatolik yuz berdi.', true);
      }
    } catch (e) {
      SnackBarService.showSnackBar(
          context, 'Internetga ulanishda xatolik: $e', true);
    }
  }

  Future<void> _verifyCode() async {
    String enteredCode = _smsController.text.trim();
    if (enteredCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tasdiqlash kodi 6 raqamdan iborat bo‘lishi kerak.'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://paygo.app-center.uz/api/auth/verify'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone_number': widget.phoneNumber,
          'verification_code': enteredCode,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic> &&
            data['accessToken'] != null &&
            data['refreshToken'] != null) {
          // Сохраняем токены в SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', data['accessToken']);
          await prefs.setString('refresh_token', data['refreshToken']);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tasdiqlash muvaffaqiyatli o’tdi.')),
          );

          // Переход к следующему экрану
          Navigator.pushNamedAndRemoveUntil(
              context, '/home', (Route<dynamic> route) => false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Xatolik: Tokenlar olinmadi.')),
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorData['message'] ?? 'Xatolik yuz berdi.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Internetga ulanishda muammo: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        centerTitle: true,
        backgroundColor: AppColors.grade1,
        title: Text(
          'Telefonni tasdiqlash',
          style: AppStyle.fontStyle.copyWith(color: Colors.white, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset('assets/lottie/sms_verify.json',
                  width: 200, height: 200),
              SizedBox(height: 20),
              Text(
                'Sms ni tasdiqlash',
                style: AppStyle.fontStyle
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(height: 10),
              Text(
                'Biz sizga 6 tali raqam jo‘natdik',
                style: AppStyle.fontStyle.copyWith(color: Colors.grey),
              ),
              SizedBox(height: 10),
              Text(
                maskPhoneNumber(widget.phoneNumber),
                style: AppStyle.fontStyle.copyWith(color: AppColors.grade1),
              ),
              SizedBox(height: 20),
              OtpTimerButton(
                controller: controller,
                height: 60,
                text: Text(
                  'Kodni qaytadan jo\'natish',
                  style: AppStyle.fontStyle.copyWith(color: AppColors.grade1),
                ),
                duration: 5,
                radius: 30,
                backgroundColor: Colors.blue,
                textColor: Colors.white,
                buttonType: ButtonType.text_button,
                loadingIndicator: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.red,
                ),
                loadingIndicatorColor: Colors.red,
                onPressed: () {
                  resendVerificationCode(widget.phoneNumber);
                },
              ),
              Pinput(
                length: 6,
                controller: _smsController,
                defaultPinTheme: currentPinTheme,
                followingPinTheme: followPinTheme,
                errorPinTheme: errorPinTheme,
                onChanged: _onCodeChanged,
                onCompleted: (_) => _verifyCode(),
              ),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _verifyCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.grade1,
                        elevation: 5,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Akkauntni tasdiqlash va yaratish',
                        style: AppStyle.fontStyle
                            .copyWith(color: AppColors.backgroundColor),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

final PinTheme followPinTheme = PinTheme(
  width: 56,
  height: 56,
  textStyle: TextStyle(
      fontSize: 20,
      color: Color.fromRGBO(30, 60, 87, 1),
      fontWeight: FontWeight.w600),
  decoration: BoxDecoration(
    border: Border.all(color: Color.fromRGBO(234, 239, 243, 1)),
    borderRadius: BorderRadius.circular(20),
  ),
);

final PinTheme defaultPinTheme = PinTheme(
  width: 56,
  height: 56,
  textStyle: TextStyle(
      fontSize: 20,
      color: Color.fromRGBO(30, 60, 87, 1),
      fontWeight: FontWeight.w600),
  decoration: BoxDecoration(
    border: Border.all(color: Color.fromRGBO(77, 77, 77, 1)),
    borderRadius: BorderRadius.circular(20),
  ),
);

final PinTheme errorPinTheme = PinTheme(
  width: 56,
  height: 56,
  textStyle: TextStyle(
      fontSize: 20,
      color: Color.fromRGBO(30, 60, 87, 1),
      fontWeight: FontWeight.w600),
  decoration: BoxDecoration(
    border: Border.all(color: Colors.red),
    borderRadius: BorderRadius.circular(20),
  ),
);

final PinTheme successPinTheme = PinTheme(
  width: 56,
  height: 56,
  textStyle: TextStyle(
      fontSize: 20,
      color: Color.fromRGBO(30, 60, 87, 1),
      fontWeight: FontWeight.w600),
  decoration: BoxDecoration(
    border: Border.all(color: Colors.green),
    borderRadius: BorderRadius.circular(20),
  ),
);

String maskPhoneNumber(String phoneNumber) {
  if (phoneNumber.length >= 11) {
    return phoneNumber.replaceRange(4, 10, '******');
  }
  return phoneNumber;
}
