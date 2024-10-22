import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taksi/screens/drivers/drivers_page.dart';
import 'package:taksi/screens/new_user/new_user_add.dart';
import 'package:taksi/services/phone_number_format.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class DriverRegistrationPage extends StatefulWidget {
  const DriverRegistrationPage({super.key});

  @override
  _DriverRegistrationPageState createState() => _DriverRegistrationPageState();
}

bool isLoading = false;

class _DriverRegistrationPageState extends State<DriverRegistrationPage> {
  final user = FirebaseAuth.instance.currentUser;
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

  File? frontLicense;
  File? backLicense;
  File? frontPassport;
  File? backPassport;

  File? frontCar;
  File? sideCar;
  File? backCar;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(Function(File) onImageSelected) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        onImageSelected(File(image.path));
      });
    }
  }

  Future<void> showBottomSheetForVehicleType(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Avtomobil turini tanlang",
                style: AppStyle.fontStyle
                    .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Divider(color: Colors.grey[300], thickness: 1),
              ListTile(
                title: Text('Yengil avtomobil', style: AppStyle.fontStyle),
                onTap: () {
                  setState(() {
                    _controllers['Gruzovik yoki mashina']!.text =
                        'Yengil avtomobil';
                  });
                  Navigator.pop(context);
                },
              ),
              Divider(color: Colors.grey[300], thickness: 1),
              ListTile(
                title: Text('Yuk mashinasi', style: AppStyle.fontStyle),
                onTap: () {
                  setState(() {
                    _controllers['Gruzovik yoki mashina']!.text =
                        'Yuk mashinasi';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
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

  final _formKey = GlobalKey<FormState>();

  Future<void> saveDataToFirestore() async {
    setState(() {
      isLoading = true; // Показать индикатор загрузки
    });

    try {
      if (_formKey.currentState!.validate()) {
        // Выполняем загрузку данных и изображений
        String frontLicenseUrl =
            await _uploadImage(frontLicense!, "front_license");
        String backLicenseUrl =
            await _uploadImage(backLicense!, "back_license");
        String frontPassportUrl =
            await _uploadImage(frontPassport!, "front_passport");
        String backPassportUrl =
            await _uploadImage(backPassport!, "back_passport");

        String frontCarUrl = await _uploadImage(frontCar!, "front_car");
        String sideCarUrl = await _uploadImage(sideCar!, "side_car");
        String backCarUrl = await _uploadImage(backCar!, "back_car");

        final data = {
          'email': user?.email,
          'name': _controllers['Ism']!.text,
          'lastName': _controllers['Familiya']!.text,
          'phoneNumber': _controllers['Telefon raqami']!.text,
          'vehicleType': _controllers['Gruzovik yoki mashina']!.text,
          'carModel': _controllers['Mashina markasi']!.text,
          'carNumber':
              '${_controllers['Area Code']!.text}${_controllers['Letter Code']!.text}${_controllers['Number Code']!.text}${_controllers['Ending Code']!.text}',
          'from': _controllers['Qayerdan']!.text,
          'to': _controllers['Qayerga']!.text,
          'status': 'unidentified',
          'frontLicense': frontLicenseUrl,
          'backLicense': backLicenseUrl,
          'frontPassport': frontPassportUrl,
          'backPassport': backPassportUrl,
          'frontCar': frontCarUrl,
          'sideCar': sideCarUrl,
          'backCar': backCarUrl,
        };

        await FirebaseFirestore.instance
            .collection('driver')
            .doc(user?.uid)
            .set(data);

        // Навигация после успешного сохранения
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => DriverPage()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      // Обработка ошибок (если необходимо)
    } finally {
      setState(() {
        isLoading = false; // Скрыть индикатор загрузки
      });
    }
  }

  Future<String> _uploadImage(File image, String fileName) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('driver_documents/${user?.uid}/$fileName');
    await storageRef.putFile(image);
    return await storageRef.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Haydovchi ma'lumotlari",
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
                buildBottomSheetField(
                  _controllers['Gruzovik yoki mashina']!,
                  'Avtomobil turini tanlang',
                  () => showBottomSheetForVehicleType(context),
                ),
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
                Text("Avtomobil fotosuratlari (oldi, yon, orqa tomoni)",
                    style: AppStyle.fontStyle.copyWith(fontSize: 16)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _pickImage((image) {
                          frontCar = image;
                        }),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.taxi,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text("Old tomoni yuklash",
                            style: AppStyle.fontStyle
                                .copyWith(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (frontCar != null)
                      Image.file(frontCar!, width: 50, height: 50),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _pickImage((image) {
                          sideCar = image;
                        }),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.taxi,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text("Yon tomoni yuklash",
                            style: AppStyle.fontStyle
                                .copyWith(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (sideCar != null)
                      Image.file(sideCar!, width: 50, height: 50),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _pickImage((image) {
                          backCar = image;
                        }),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.taxi,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text("Orqa tomoni yuklash",
                            style: AppStyle.fontStyle
                                .copyWith(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (backCar != null)
                      Image.file(backCar!, width: 50, height: 50),
                  ],
                ),
                const SizedBox(height: 40),
                Text("Haydovchilik guvohnomasi yuklash",
                    style: AppStyle.fontStyle.copyWith(fontSize: 16)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _pickImage((image) {
                          frontLicense = image;
                        }),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.taxi,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text("Old tomoni yuklash",
                            style: AppStyle.fontStyle
                                .copyWith(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (frontLicense != null)
                      Image.file(frontLicense!, width: 50, height: 50),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _pickImage((image) {
                          backLicense = image;
                        }),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.taxi,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text("Orqa tomoni yuklash",
                            style: AppStyle.fontStyle
                                .copyWith(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (backLicense != null)
                      Image.file(backLicense!, width: 50, height: 50),
                  ],
                ),
                const SizedBox(height: 10),
                Text("Texnik passport yuklash",
                    style: AppStyle.fontStyle.copyWith(fontSize: 16)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _pickImage((image) {
                          frontPassport = image;
                        }),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.taxi,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text("Old tomoni yuklash",
                            style: AppStyle.fontStyle
                                .copyWith(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (frontPassport != null)
                      Image.file(frontPassport!, width: 50, height: 50),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _pickImage((image) {
                          backPassport = image;
                        }),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.taxi,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text("Orqa tomoni yuklash",
                            style: AppStyle.fontStyle
                                .copyWith(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (backPassport != null)
                      Image.file(backPassport!, width: 50, height: 50),
                  ],
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : saveDataToFirestore, // Отключаем кнопку, если идет загрузка
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

  Widget buildBottomSheetField(
    TextEditingController controller,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
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
}
