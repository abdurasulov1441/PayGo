import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:u_credit_card/u_credit_card.dart';
import 'package:taksi/style/app_colors.dart'; // Custom AppColors
import 'package:taksi/style/app_style.dart'; // Custom AppStyle

class BalanceTopUpPage extends StatefulWidget {
  const BalanceTopUpPage({super.key});

  @override
  _BalanceTopUpPageState createState() => _BalanceTopUpPageState();
}

class _BalanceTopUpPageState extends State<BalanceTopUpPage> {
  final _amountController = TextEditingController();
  File? _receiptImage;
  bool _isUploading = false;

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
      // Upload the receipt image to Firebase Storage
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      UploadTask uploadTask = FirebaseStorage.instance
          .ref('receipts/$fileName')
          .putFile(_receiptImage!);

      TaskSnapshot snapshot = await uploadTask;
      String downloadURL = await snapshot.ref.getDownloadURL();

      // Get user details
      User? user = FirebaseAuth.instance.currentUser;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('taxidrivers')
          .doc(user?.uid)
          .get();

      // Fetch user details from Firestore
      final userData = userDoc.data() as Map<String, dynamic>?;
      String firstName = userData?['name'] ?? 'Ism kiritilmagan';
      String lastName = userData?['lastName'] ?? 'Familiya kiritilmagan';
      String phoneNumber =
          userData?['phoneNumber'] ?? 'Telefon raqam kiritilmagan';
      String email = user?.email ?? 'Email kiritilmagan';

      // Add transaction to Firestore
      await FirebaseFirestore.instance.collection('transactions').add({
        'amount': int.parse(_amountController.text),
        'receiptUrl': downloadURL,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'status': 'unchecked',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Tranzaksiya muvaffaqiyatli yuborildi.',
                style: AppStyle.fontStyle)),
      );

      // Clear the form
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
              // Display a credit card using the uCreditCard library
              Center(
                child: CreditCardUi(
                  cardHolderFullName: 'Sharipov Hasan',
                  cardNumber: '5614 6812 2313 4002',
                  validThru: '12/25', // Expiration date
                  topLeftColor: AppColors.taxi, // Customizing card colors
                  bottomRightColor: AppColors.taxi.withOpacity(0.8),
                ),
              ),
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
}
