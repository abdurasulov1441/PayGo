import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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

  // Fetch phone number directly from Firestore based on user's email
  Future<void> _fetchUserPhone() async {
    final email =
        'abdurasulov2048@gmail.com'; // User's email (replace accordingly)
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
          );
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
            now.day + 1,
            time.hour,
            time.minute,
          );
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
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            );
          });
        }
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Taksi buyurtmasi berish')),
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
                minimumSize: Size(double.infinity, 50), // Full width button
              ),
              child: Text(
                _selectedDateTime == null
                    ? 'Vaqtni tanlang'
                    : 'Tanlangan vaqt: ${DateFormat('yyyy-MM-dd – HH:mm').format(_selectedDateTime!)}',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitTaxiOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(double.infinity, 50), // Full width button
              ),
              child: Text('Buyurtma yuborish'),
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
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$label: $location', style: TextStyle(fontSize: 16)),
            Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildPeopleSelector() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Odamlar soni',
        border: OutlineInputBorder(),
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
          child: Text(value),
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      title: Text(location),
                      onTap: () {
                        onSelected(
                            location); // Call the callback with selected location
                        Navigator.pop(context); // Close the bottom sheet
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Divider(),
              ..._periodOptions.map((option) => ListTile(
                    title: Text(option),
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
