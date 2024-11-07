import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class CallCenterInformationPage extends StatefulWidget {
  const CallCenterInformationPage({Key? key}) : super(key: key);

  @override
  _CallCenterInformationPageState createState() =>
      _CallCenterInformationPageState();
}

class _CallCenterInformationPageState extends State<CallCenterInformationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCallCenterData();
  }

  Future<void> _loadCallCenterData() async {
    DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
        .instance
        .collection('data')
        .doc('call_center')
        .get();

    if (doc.exists && doc.data() != null) {
      Map<String, dynamic> data = doc.data()!;
      _nameController.text = data['name'] ?? '';
      _phoneController.text = data['phone_number'] ?? '';
    }
  }

  Future<void> _updateCallCenterData() async {
    await FirebaseFirestore.instance
        .collection('data')
        .doc('call_center')
        .update({
      'name': _nameController.text,
      'phone_number': _phoneController.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Информация обновлена')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Контактный Центр',
          style: AppStyle.fontStyle.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.taxi,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Название',
                border: OutlineInputBorder(),
              ),
              style: AppStyle.fontStyle,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Телефон',
                border: OutlineInputBorder(),
              ),
              style: AppStyle.fontStyle,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _updateCallCenterData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.taxi,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'Сохранить изменения',
                  style: AppStyle.fontStyle.copyWith(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
