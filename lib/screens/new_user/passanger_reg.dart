import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taksi/screens/civil/civil_page.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

import '../../services/phone_number_format.dart';

class PassengerRegistrationPage extends StatefulWidget {
  const PassengerRegistrationPage({super.key});

  @override
  _PassengerRegistrationPageState createState() =>
      _PassengerRegistrationPageState();
}

class _PassengerRegistrationPageState extends State<PassengerRegistrationPage> {
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController =
      TextEditingController(text: '+998 ');

  final _formKey = GlobalKey<FormState>();

  Future<String> _generateUserId() async {
    // Получаем все документы в коллекции 'user' и сортируем их по 'userId' в обратном порядке
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('user')
        .orderBy('userId', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return '000001'; // Если нет пользователей, начинаем с '000001'
    } else {
      int lastUserId = int.parse(querySnapshot.docs.first['userId']);
      int newUserId = lastUserId + 1;
      return newUserId
          .toString()
          .padLeft(6, '0'); // Преобразуем в шестизначное число
    }
  }

  void savePassengerData() async {
    if (_formKey.currentState!.validate()) {
      String userId = await _generateUserId(); // Генерация нового userId

      final data = {
        'email': user?.email,
        'name': _nameController.text,
        'lastName': _lastNameController.text,
        'phoneNumber': _phoneController.text,
        'userId': userId, // Записываем userId
        'status': 'active', // Статус по умолчанию
        'role': 'passenger', // Роль 'passenger'
      };

      await FirebaseFirestore.instance
          .collection('user')
          .doc(user?.uid)
          .set(data);

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MainCivilPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Yo’lovchi ma'lumotlari",
          style: AppStyle.fontStyle.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.taxi,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildTextField(_nameController, 'Ism'),
              const SizedBox(height: 20),
              buildTextField(_lastNameController, 'Familiya'),
              const SizedBox(height: 20),
              buildPhoneNumberField(_phoneController),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: savePassengerData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.taxi,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Saqlash",
                  style: AppStyle.fontStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppStyle.fontStyle.copyWith(color: AppColors.taxi),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      style: AppStyle.fontStyle,
      validator: (value) =>
          value == null || value.isEmpty ? 'Iltimos, $label kiriting' : null,
    );
  }

  Widget buildPhoneNumberField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [PhoneNumberFormatter()],
      decoration: InputDecoration(
        labelText: 'Telefon raqami',
        labelStyle: AppStyle.fontStyle.copyWith(color: AppColors.taxi),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      style: AppStyle.fontStyle,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Iltimos, telefon raqamingizni kiriting';
        }
        if (!RegExp(r'^\+998 \(\d{2}\) \d{3} \d{2} \d{2}$').hasMatch(value)) {
          return 'To\'g\'ri telefon raqamini kiriting';
        }
        return null;
      },
    );
  }
}
