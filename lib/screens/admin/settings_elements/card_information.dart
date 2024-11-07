import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class EditableCardInformationPage extends StatefulWidget {
  const EditableCardInformationPage({super.key});

  @override
  _EditableCardInformationPageState createState() =>
      _EditableCardInformationPageState();
}

class _EditableCardInformationPageState
    extends State<EditableCardInformationPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardHolderController = TextEditingController();
  final _cardNumberController = TextEditingController();
  String _cardType = 'uzcard'; // Default card type

  @override
  void initState() {
    super.initState();
    _loadCardData();
  }

  Future<void> _loadCardData() async {
    DocumentSnapshot cardDoc =
        await FirebaseFirestore.instance.collection('data').doc('card').get();

    if (cardDoc.exists) {
      var cardData = cardDoc.data() as Map<String, dynamic>;
      setState(() {
        _cardHolderController.text = cardData['card_holder'] ?? '';
        _cardNumberController.text = cardData['card_number'] ?? '';
        _cardType = cardData['type'] ?? 'uzcard';
      });
    }
  }

  Future<void> _saveCardData() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('data').doc('card').update({
        'card_holder': _cardHolderController.text,
        'card_number': _cardNumberController.text,
        'type': _cardType,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Karta ma\'lumotlari saqlandi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Karta Ma\'lumotlarini Tahrirlash',
          style: AppStyle.fontStyle.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.taxi,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Поле для ввода имени владельца карты
              TextFormField(
                controller: _cardHolderController,
                decoration: InputDecoration(
                  labelText: 'Karta Egasi',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Iltimos, karta egasini kiriting';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Поле для ввода номера карты
              TextFormField(
                controller: _cardNumberController,
                decoration: InputDecoration(
                  labelText: 'Karta Raqami',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Iltimos, karta raqamini kiriting';
                  }
                  if (value.length != 16) {
                    return 'Karta raqami 16 ta raqamdan iborat bo\'lishi kerak';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Выбор типа карты
              DropdownButtonFormField<String>(
                value: _cardType,
                items: ['uzcard', 'humo']
                    .map((type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(type.toUpperCase()),
                        ))
                    .toList(),
                onChanged: (newType) {
                  setState(() {
                    _cardType = newType!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Karta Turi',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 32),

              // Кнопка сохранения данных
              Center(
                child: ElevatedButton(
                  onPressed: _saveCardData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.taxi,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 30,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'Ma\'lumotlarni Saqlash',
                    style: AppStyle.fontStyle.copyWith(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
