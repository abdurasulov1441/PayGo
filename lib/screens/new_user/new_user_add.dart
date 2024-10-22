import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:taksi/screens/civil/civil_page.dart';
import 'package:taksi/screens/drivers/drivers_page.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  _RoleSelectionPageState createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  final user = FirebaseAuth.instance.currentUser;
  String? selectedRole;
  bool showForm = false;

  void savePassengerData(
      String name, String lastName, String phoneNumber) async {
    final data = {
      'email': user?.email,
      'name': name,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'role': 'Yo’lovchi',
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

  void saveDriverData(
    String name,
    String lastName,
    String phoneNumber,
    String vehicleType,
    String carModel,
    String areaCode,
    String letterCode,
    String numberCode,
    String endingCode,
    String from,
    String to,
  ) async {
    if (from == to) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Qayerdan va Qayerga bir xil bo\'lmasligi kerak!')),
      );
      return;
    }

    final carNumber = '$areaCode$letterCode$numberCode$endingCode';

    // Set the current date and calculate 30 days for expired_date
    DateTime currentDate = DateTime.now();
    DateTime expiredDate = currentDate.add(Duration(days: 30));

    final data = {
      'email': user?.email,
      'name': name,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'vehicleType': vehicleType,
      'carModel': carModel,
      'carNumber': carNumber,
      'from': from,
      'to': to,
      'role': 'Haydovchi',
      'balance': 0, // Add the balance field with a default value of 0
      'expired_date': expiredDate, // Add the expired_date field
      'subscription_plan':
          'Vaqtinchalik' // Add the tarif field as a trial period
    };

    await FirebaseFirestore.instance
        .collection('driver')
        .doc(user?.uid)
        .set(data);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => DriverPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Iltimos, qaysi rolni tanlaysiz",
                style: AppStyle.fontStyle
                    .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RoleCard(
                    icon: Icons.local_shipping,
                    label: "Haydovchi",
                    color: Colors.green[50]!,
                    onTap: () {
                      setState(() {
                        selectedRole = 'Haydovchi';
                        showForm = true;
                      });
                    },
                  ),
                  const SizedBox(width: 20),
                  RoleCard(
                    icon: Icons.person,
                    label: "Yo’lovchi",
                    color: Colors.green[50]!,
                    onTap: () {
                      setState(() {
                        selectedRole = 'Yo’lovchi';
                        showForm = true;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (showForm && selectedRole != null) ...[
                const Divider(),
                Text(
                  selectedRole == 'Haydovchi'
                      ? "Haydovchi ma'lumotlari"
                      : "Yo’lovchi ma'lumotlari",
                  style: AppStyle.fontStyle
                      .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                RoleForm(
                  isDriver: selectedRole == 'Haydovchi',
                  onSave: selectedRole == 'Haydovchi'
                      ? (data) => saveDriverData(
                            data['Ism']!,
                            data['Familiya']!,
                            data['Telefon raqami']!,
                            data['Gruzovik yoki mashina']!,
                            data['Mashina markasi']!,
                            data['Area Code']!,
                            data['Letter Code']!,
                            data['Number Code']!,
                            data['Ending Code']!,
                            data['Qayerdan']!,
                            data['Qayerga']!,
                          )
                      : (data) => savePassengerData(
                            data['Ism']!,
                            data['Familiya']!,
                            data['Telefon raqami']!,
                          ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: AppColors.taxi),
            const SizedBox(height: 10),
            Text(label,
                style: AppStyle.fontStyle.copyWith(color: Colors.black)),
          ],
        ),
      ),
    );
  }
}

class RoleForm extends StatefulWidget {
  final bool isDriver;
  final Function(Map<String, String>) onSave;

  const RoleForm({
    super.key,
    required this.isDriver,
    required this.onSave,
  });

  @override
  _RoleFormState createState() => _RoleFormState();
}

class _RoleFormState extends State<RoleForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {
    'Ism': TextEditingController(),
    'Familiya': TextEditingController(),
    'Telefon raqami': TextEditingController(text: '+998 '),
    'Gruzovik yoki mashina': TextEditingController(),
    'Mashina markasi': TextEditingController(),
    'Area Code': TextEditingController(),
    'Letter Code': TextEditingController(),
    'Number Code': TextEditingController(),
    'Ending Code': TextEditingController(),
    'Qayerdan': TextEditingController(),
    'Qayerga': TextEditingController(),
  };
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

  List<String> regions = [];

  @override
  void initState() {
    super.initState();
    fetchRegionsFromFirestore();
  }

  Future<void> fetchRegionsFromFirestore() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('regions').get();

    setState(() {
      regions = snapshot.docs.map((doc) => doc['region'] as String).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildTextField(_controllers['Ism']!, 'Ism'),
          const SizedBox(height: 15),
          buildTextField(_controllers['Familiya']!, 'Familiya'),
          const SizedBox(height: 15),
          PhoneNumberField(
            controller: _controllers['Telefon raqami']!,
            formatter: _phoneNumberFormatter,
          ),
          if (widget.isDriver) ...[
            const SizedBox(height: 15),
            buildBottomSheetField(
              _controllers['Gruzovik yoki mashina']!,
              'Gruzovik yoki mashina',
              ['Gruzovik', 'Mashina'],
            ),
            const SizedBox(height: 15),
            buildTextField(_controllers['Mashina markasi']!, 'Mashina markasi'),
            const SizedBox(height: 15),
            buildCarNumberField(),
            const SizedBox(height: 15),
            buildBottomSheetField(
                _controllers['Qayerdan']!, 'Qayerdan', regions),
            const SizedBox(height: 15),
            buildBottomSheetField(_controllers['Qayerga']!, 'Qayerga', regions),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                if (widget.isDriver) {
                  if (_controllers['Qayerdan']!.text ==
                      _controllers['Qayerga']!.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Qayerdan va Qayerga bir xil bo\'lmasligi kerak!')),
                    );
                    return;
                  }
                }
                final data = {
                  for (var entry in _controllers.entries)
                    if (widget.isDriver ||
                        (!widget.isDriver &&
                            (entry.key == 'Ism' ||
                                entry.key == 'Familiya' ||
                                entry.key == 'Telefon raqami')))
                      entry.key: entry.value.text,
                };
                widget.onSave(data);
              }
            },
            child: Text(
              "Saqlash",
              style: AppStyle.fontStyle.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCarNumberField() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              const SizedBox(height: 5),
              GestureDetector(
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
            ],
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

  Widget buildBottomSheetField(
    TextEditingController controller,
    String label,
    List<String> options,
  ) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return ListView(
              children: options.map((item) {
                return ListTile(
                  title: Text(item, style: AppStyle.fontStyle),
                  onTap: () {
                    setState(() {
                      controller.text = item;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            );
          },
        );
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
          style: AppStyle.fontStyle,
          validator: (value) =>
              value == null || value.isEmpty ? 'Iltimos, $label tanlang' : null,
        ),
      ),
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      style: AppStyle.fontStyle,
      validator: (value) =>
          value == null || value.isEmpty ? 'Iltimos, $label kiriting' : null,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[100],
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class PhoneNumberField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputFormatter formatter;

  const PhoneNumberField({
    super.key,
    required this.controller,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [formatter],
      decoration: InputDecoration(
        labelText: 'Telefon raqami',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
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
    int selectionIndex = newValue.selection.baseOffset;

    if (text.isNotEmpty) {
      formatted.write('(${text.substring(0, min(2, text.length))}');
    }
    if (text.length > 2) {
      formatted.write(') ${text.substring(2, min(5, text.length))}');
    }
    if (text.length > 5) {
      formatted.write(' ${text.substring(5, min(7, text.length))}');
    }
    if (text.length > 7) {
      formatted.write(' ${text.substring(7, text.length)}');
    }

    selectionIndex = formatted.length;

    if (newValue.selection.baseOffset < 5) {
      selectionIndex = 5;
    }

    return TextEditingValue(
      text: formatted.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  },
);
