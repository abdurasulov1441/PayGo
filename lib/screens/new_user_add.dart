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

  List<String> regions = [];
  bool isLoadingRegions = true;

  @override
  void initState() {
    super.initState();
    fetchRegions(); // Fetch regions from Firestore
  }

  // Fetch regions from Firestore
  Future<void> fetchRegions() async {
    final regionsSnapshot =
        await FirebaseFirestore.instance.collection('regions').get();

    final fetchedRegions =
        regionsSnapshot.docs.map((doc) => doc['region'].toString()).toList();

    setState(() {
      regions = fetchedRegions;
      isLoadingRegions = false;
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
          buildPhoneNumberField(),
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
            isLoadingRegions
                ? CircularProgressIndicator()
                : buildBottomSheetField(
                    _controllers['Qayerdan']!, 'Qayerdan', regions),
            const SizedBox(height: 15),
            isLoadingRegions
                ? CircularProgressIndicator()
                : buildBottomSheetField(
                    _controllers['Qayerga']!, 'Qayerga', regions),
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

  Widget buildPhoneNumberField() {
    return TextFormField(
      controller: _controllers['Telefon raqami']!,
      keyboardType: TextInputType.phone,
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

  Widget buildCarNumberField() {
    return Row(
      children: [
        Expanded(
          flex: 2,
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
