import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class BalanceTopUpPage extends StatefulWidget {
  const BalanceTopUpPage({super.key});

  @override
  _BalanceTopUpPageState createState() => _BalanceTopUpPageState();
}

class _BalanceTopUpPageState extends State<BalanceTopUpPage> {
  final _amountController = TextEditingController();
  File? _receiptImage;
  bool _isUploading = false;
  String cardHolder = 'Loading...';
  String cardNumber = '**** **** **** ****';
  String cardType = 'humo';

  @override
  void initState() {
    super.initState();
    fetchCardData();
  }

  Future<void> fetchCardData() async {
    final doc =
        await FirebaseFirestore.instance.collection('data').doc('card').get();
    if (doc.exists) {
      setState(() {
        cardHolder = doc['card_holder'] ?? 'Ism kiritilmagan';
        cardNumber = doc['card_number'] ?? '**** **** **** ****';
        cardType = doc['type'] ?? 'humo';
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _receiptImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitTransaction() async {
    if (_amountController.text.isEmpty || _receiptImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Summani kiriting va kvitansiyani yuklang.',
                style: AppStyle.fontStyle)),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      UploadTask uploadTask = FirebaseStorage.instance
          .ref('receipts/$fileName')
          .putFile(_receiptImage!);

      TaskSnapshot snapshot = await uploadTask;
      String downloadURL = await snapshot.ref.getDownloadURL();

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'Пользователь не найден';

      final querySnapshot = await FirebaseFirestore.instance
          .collection('truckdrivers')
          .where('email', isEqualTo: user.email)
          .get();

      if (querySnapshot.docs.isEmpty) throw 'Водитель не найден';

      String userId = querySnapshot.docs.first.id;

      await FirebaseFirestore.instance.collection('transactions').add({
        'userId': userId,
        'amount': int.parse(_amountController.text),
        'receiptUrl': downloadURL,
        'email': user.email,
        'status': 'unchecked',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Tranzaksiya muvaffaqiyatli yuborildi.',
                style: AppStyle.fontStyle)),
      );

      setState(() {
        _amountController.clear();
        _receiptImage = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Xatolik yuz berdi: $e', style: AppStyle.fontStyle)),
      );
    }

    setState(() {
      _isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        centerTitle: true,
        title: Text(
          'Balansni to‘ldirish',
          style: AppStyle.fontStyle.copyWith(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: AppColors.taxi,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Karta ma\'lumotlari:',
                style: AppStyle.fontStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.taxi,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              _buildCreditCard(),
              SizedBox(height: 30),
              Text(
                'Summani kiriting:',
                style: AppStyle.fontStyle.copyWith(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Miqdorni kiriting (UZS)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.taxi),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                style: AppStyle.fontStyle.copyWith(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'Kvitansiya skrinshotini yuklang:',
                style: AppStyle.fontStyle.copyWith(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              if (_receiptImage != null)
                Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.taxi, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.file(_receiptImage!, fit: BoxFit.cover),
                ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.image, color: Colors.white),
                label: Text('Kvitansiyani yuklang',
                    style: AppStyle.fontStyle.copyWith(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.taxi,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 30),
              _isUploading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.taxi,
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('To\'lovni tasdiqlash',
                          style:
                              AppStyle.fontStyle.copyWith(color: Colors.white)),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreditCard() {
    String cardImagePath = cardType == 'humo'
        ? 'assets/images/humo.png'
        : 'assets/images/uzcard.png';

    return Container(
      height: 200,
      width: double.infinity,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.teal.shade800,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 30,
          ),
          Row(
            children: [
              Image.asset('assets/images/chip.png', width: 30),
              if (cardType ==
                  'humo') // Показать бесконтактную иконку только для Humo
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Image.asset('assets/images/wire_card.png', width: 25),
                ),
              Spacer(),
            ],
          ),
          SizedBox(height: 20),
          Text(
            cardNumber,
            style: AppStyle.fontStyle.copyWith(
              color: Colors.white,
              fontSize: 22,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                cardHolder.toUpperCase(),
                style: AppStyle.fontStyle.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Image.asset(cardImagePath, height: 30),
            ],
          ),
        ],
      ),
    );
  }
}
