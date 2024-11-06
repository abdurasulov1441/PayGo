import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taksi/screens/home_screen.dart';
import 'package:taksi/screens/new_user/new_user_add.dart';
import 'package:taksi/services/phone_number_format.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class TruckDriverRegistrationPage extends StatefulWidget {
  const TruckDriverRegistrationPage({super.key});

  @override
  _TruckDriverRegistrationPageState createState() =>
      _TruckDriverRegistrationPageState();
}

bool isLoading = false;

class _TruckDriverRegistrationPageState
    extends State<TruckDriverRegistrationPage> {
  final user = FirebaseAuth.instance.currentUser;

  final Map<String, TextEditingController> _controllers = {
    'Ism': TextEditingController(),
    'Familiya': TextEditingController(),
    'Telefon raqami': TextEditingController(text: '+998 '),
    'Mashina markasi': TextEditingController(),
    'Area Code': TextEditingController(),
    'Letter Code': TextEditingController(),
    'Number Code': TextEditingController(),
    'Ending Code': TextEditingController(),
    'Qayerdan': TextEditingController(),
    'Qayerga': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    fetchRegionsFromFirestore();
  }

  List<String> regions = [];

  Future<void> fetchRegionsFromFirestore() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('data')
        .doc('regions')
        .get();

    setState(() {
      regions = List<String>.from(snapshot['regions']);
    });
  }

  final Map<String, String> areaCodes = {
    '01': 'Toshkent sh',
    '10': 'Toshkent v',
    '20': 'Sirdaryo',
    '25': 'Jizzax',
    '30': 'Samarqand',
    '40': 'Farg\'ona',
    '50': 'Namangan',
    '60': 'Andijon',
    '70': 'Qashqadaryo',
    '75': 'Surxondaryo',
    '80': 'Buxoro',
    '85': 'Navoiy',
    '90': 'Xorazm',
    '95': 'Qoraqalpog\'iston R',
  };

  final _formKey = GlobalKey<FormState>();

  Future<String> generateTruckDriverUserId() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('truckdrivers')
        .orderBy('userId', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return '000001';
    } else {
      String lastUserId = querySnapshot.docs.first['userId'];
      int newUserId = int.parse(lastUserId) + 1;
      return newUserId.toString().padLeft(6, '0');
    }
  }

  Future<void> saveDataToFirestore() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (_formKey.currentState!.validate()) {
        String userId =
            await generateTruckDriverUserId(); // Сгенерированный `userId`
        DateTime expiredDate = DateTime.now().add(Duration(days: 31));

        final data = {
          'userId': userId,
          'email': user?.email,
          'name': _controllers['Ism']!.text,
          'surname': _controllers['Familiya']!.text,
          'phone_number': _controllers['Telefon raqami']!.text,
          'truck_model': _controllers['Mashina markasi']!.text,
          'truck_number':
              '${_controllers['Area Code']!.text}${_controllers['Letter Code']!.text}${_controllers['Number Code']!.text}${_controllers['Ending Code']!.text}',
          'from': _controllers['Qayerdan']!.text,
          'to': _controllers['Qayerga']!.text,
          'status': 'active',
          'balance': 0,
          'expired_date': Timestamp.fromDate(expiredDate),
          'subscription_plan': 'Vaqtinchalik',
          'reports': 0,
        };

        // Используем `userId` как идентификатор документа
        await FirebaseFirestore.instance
            .collection('truckdrivers')
            .doc(userId)
            .set(data);

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      // Обработка ошибок
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Gruz Haydovchi ma'lumotlari",
            style: AppStyle.fontStyle.copyWith(color: Colors.white)),
        backgroundColor: AppColors.taxi,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildTextField(_controllers['Ism']!, 'Ism'),
                const SizedBox(height: 20),
                buildTextField(_controllers['Familiya']!, 'Familiya'),
                const SizedBox(height: 20),
                buildPhoneNumberField(_controllers['Telefon raqami']!),
                const SizedBox(height: 20),
                buildTextField(
                    _controllers['Mashina markasi']!, 'Mashina markasi'),
                const SizedBox(height: 20),
                buildCarNumberField(),
                const SizedBox(height: 20),
                buildRegionField(_controllers['Qayerdan']!, 'Qayerdan'),
                const SizedBox(height: 20),
                buildRegionField(_controllers['Qayerga']!, 'Qayerga'),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: isLoading ? null : saveDataToFirestore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.taxi,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text(
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

  Widget buildRegionField(TextEditingController controller, String label) {
    return GestureDetector(
      onTap: () async {
        await showRegionBottomSheet(controller);
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: AppStyle.fontStyle.copyWith(color: AppColors.taxi),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
          style: AppStyle.fontStyle,
        ),
      ),
    );
  }

  Future<void> showRegionBottomSheet(TextEditingController controller) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ListView(
          children: regions.map((region) {
            return ListTile(
              title: Text(region, style: AppStyle.fontStyle),
              onTap: () {
                setState(() {
                  controller.text = region;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget buildCarNumberField() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () => showAreaCodeBottomSheet(context),
            child: AbsorbPointer(
              child: TextFormField(
                controller: _controllers['Area Code']!,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: AppStyle.fontStyle,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 1,
          child: TextFormField(
            controller: _controllers['Letter Code']!,
            textAlign: TextAlign.center,
            maxLength: 1,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            inputFormatters: [UpperCaseTextFormatter()],
            style: AppStyle.fontStyle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: _controllers['Number Code']!,
            textAlign: TextAlign.center,
            maxLength: 3,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            keyboardType: TextInputType.number,
            style: AppStyle.fontStyle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: _controllers['Ending Code']!,
            textAlign: TextAlign.center,
            maxLength: 2,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            inputFormatters: [UpperCaseTextFormatter()],
            style: AppStyle.fontStyle,
          ),
        ),
      ],
    );
  }

  Future<void> showAreaCodeBottomSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children: areaCodes.entries.map((entry) {
            return ListTile(
              title: Text('${entry.key} - ${entry.value}',
                  style: AppStyle.fontStyle),
              onTap: () {
                setState(() {
                  _controllers['Area Code']!.text = entry.key;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }
}
