import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class CreateOrderTaksi extends StatefulWidget {
  const CreateOrderTaksi({super.key});

  @override
  _CreateOrderTaksiState createState() => _CreateOrderTaksiState();
}

class _CreateOrderTaksiState extends State<CreateOrderTaksi> {
  String fromLocation = 'Namangan';
  String toLocation = 'Toshkent';
  final TextEditingController _phoneController = TextEditingController();
  String _selectedPeople = '1';
  DateTime? _selectedDateTime;
  final List<String> _periodOptions = [
    'Hoziroq',
    'Bugun',
    'Ertaga',
    'Boshqa vaqt'
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserPhone();
  }

  Future<void> _fetchUserPhone() async {
    final email = 'abdurasulov2048@gmail.com';
    final snapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('email', isEqualTo: email)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final userData = snapshot.docs.first.data();
      setState(() {
        _phoneController.text = userData['phoneNumber'] ?? '+998 ';
      });
    }
  }

  Future<void> _submitTaxiOrder() async {
    if (_selectedDateTime == null) {
      _showSnackBar('Iltimos, vaqtni tanlang');
      return;
    }

    final orderData = {
      'fromLocation': fromLocation,
      'toLocation': toLocation,
      'phoneNumber': _phoneController.text,
      'peopleCount': int.parse(_selectedPeople),
      'orderTime': Timestamp.fromDate(_selectedDateTime!),
      'status': 'kutish jarayonida',
      'orderType': 'taksi',
    };

    await FirebaseFirestore.instance.collection('orders').add(orderData);

    _showSnackBar('Buyurtma yuborildi!');
    setState(() {
      _selectedPeople = '1';
      _selectedDateTime = null;
    });
  }

  Future<void> _pickTime(String selectedPeriod) async {
    DateTime now = DateTime.now();

    if (selectedPeriod == 'Hoziroq') {
      setState(() {
        _selectedDateTime = now;
      });
    } else if (selectedPeriod == 'Bugun') {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            now.year,
            now.month,
            now.day,
            time.hour,
            time.minute,
          ).toLocal(); // Преобразуем в локальное время
        });
      }
    } else if (selectedPeriod == 'Ertaga') {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            now.year,
            now.month,
            now.day,
            time.hour,
            time.minute,
          ).toLocal(); // Преобразуем в локальное время
        });
      }
    } else {
      final DateTime? date = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: now,
        lastDate: DateTime(now.year + 1),
      );

      if (date != null) {
        final TimeOfDay? time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (BuildContext context, Widget? child) {
            return MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child!,
            );
          },
        );

        if (time != null) {
          setState(() {
            _selectedDateTime = DateTime(
              now.year,
              now.month,
              now.day,
              time.hour,
              time.minute,
            ).toLocal(); // Преобразуем в локальное время
          });
        }
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppStyle.fontStyle),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Taksi buyurtmasi berish',
            style:
                AppStyle.fontStyle.copyWith(color: Colors.white, fontSize: 20)),
        backgroundColor: AppColors.taxi, // AppBar white background
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white), // Back icon in black
        titleTextStyle: AppStyle.fontStyle.copyWith(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildLocationSelector(
              label: 'Qayerdan',
              location: fromLocation,
              onTap: (String value) {
                _showLocationBottomSheet((selectedLocation) {
                  setState(() {
                    fromLocation = selectedLocation;
                  });
                });
              },
            ),
            SizedBox(height: 10),
            _buildLocationSelector(
              label: 'Qayerga',
              location: toLocation,
              onTap: (String value) {
                _showLocationBottomSheet((selectedLocation) {
                  setState(() {
                    toLocation = selectedLocation;
                  });
                });
              },
            ),
            SizedBox(height: 10),
            _buildPeopleSelector(),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _showTimePickerBottomSheet(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.taxi,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
                _selectedDateTime == null
                    ? 'Vaqtni tanlang'
                    : 'Tanlangan vaqt: ${DateFormat('yyyy-MM-dd – HH:mm').format(_selectedDateTime!)}',
                style: AppStyle.fontStyle.copyWith(color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            Spacer(),
            ElevatedButton(
              onPressed: _submitTaxiOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.taxi,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
                'Buyurtma yuborish',
                style: AppStyle.fontStyle.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSelector({
    required String label,
    required String location,
    required ValueChanged<String> onTap,
  }) {
    return GestureDetector(
      onTap: () => _showLocationBottomSheet(onTap),
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$label: $location', style: AppStyle.fontStyle),
            Icon(Icons.arrow_drop_down, color: AppColors.taxi),
          ],
        ),
      ),
    );
  }

  Widget _buildPeopleSelector() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(width: 1, color: Colors.white)),
        labelText: 'Odamlar soni',
        labelStyle: AppStyle.fontStyle,
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(width: 1, color: Colors.white)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(width: 1, color: Colors.black),
        ),
        filled: true,
        fillColor: Colors.grey[200], // Light background
      ),
      value: _selectedPeople,
      onChanged: (String? newValue) {
        setState(() {
          _selectedPeople = newValue!;
        });
      },
      items: ['1', '2', '3', '4'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: AppStyle.fontStyle),
        );
      }).toList(),
    );
  }

  void _showLocationBottomSheet(Function(String) onSelected) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Manzilni tanlang',
                  style: AppStyle.fontStyle.copyWith(fontSize: 18),
                ),
                Divider(),
                ...[
                  'Qoraqalpog\'iston R',
                  'Andijon',
                  'Buxoro',
                  'Jizzax',
                  'Qashqadaryo',
                  'Namangan',
                  'Navoiy',
                  'Samarqand',
                  'Surxondaryo',
                  'Sirdaryo',
                  'Toshkent sh',
                  'Toshkent v',
                  'Farg\'ona',
                  'Xorazm'
                ].map((location) => ListTile(
                      title: Text(location, style: AppStyle.fontStyle),
                      onTap: () {
                        onSelected(location);
                        Navigator.pop(context);
                      },
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTimePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Vaqtni tanlang',
                style: AppStyle.fontStyle.copyWith(fontSize: 18),
              ),
              Divider(),
              ..._periodOptions.map((option) => ListTile(
                    title: Text(option, style: AppStyle.fontStyle),
                    onTap: () {
                      Navigator.pop(context);
                      _pickTime(option);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }
}
