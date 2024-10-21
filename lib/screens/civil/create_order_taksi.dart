import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase Authentication
import 'package:intl/intl.dart';
import 'package:taksi/screens/civil/history.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class CreateOrderTaksi extends StatefulWidget {
  const CreateOrderTaksi({super.key});

  @override
  _CreateOrderTaksiState createState() => _CreateOrderTaksiState();
}

class _CreateOrderTaksiState extends State<CreateOrderTaksi> {
  String fromLocation = 'Namangan';
  String toLocation = 'Samarqand';
  final TextEditingController _phoneController = TextEditingController();
  String _selectedPeople = '1';
  String _customerName = '';
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
    _fetchUserDetails(); // Fetching user details from Firestore
  }

  Future<void> _fetchUserDetails() async {
    // Get the currently logged-in user's email from Firebase Auth
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;

    if (email == null) {
      _showSnackBar('User is not logged in');
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('email', isEqualTo: email) // Use the logged-in user's email
        .get();

    if (snapshot.docs.isNotEmpty) {
      final userData = snapshot.docs.first.data();
      setState(() {
        _phoneController.text = userData['phoneNumber'] ?? '+998 ';
        _customerName = userData['name'] ?? 'Ism mavjud emas';
      });
    }
  }

  Future<void> _submitTaxiOrder() async {
    if (_selectedDateTime == null) {
      _showSnackBar('Iltimos, vaqtni tanlang');
      return;
    }

    // Get the next order number
    int orderNumber = await _getNextOrderNumber();

    final orderData = {
      'orderNumber': orderNumber, // Save the order number
      'fromLocation': fromLocation,
      'toLocation': toLocation,
      'phoneNumber': _phoneController.text,
      'customerName': _customerName,
      'peopleCount': int.parse(_selectedPeople),
      'orderTime': Timestamp.fromDate(_selectedDateTime!),
      'status': 'kutish jarayonida',
      'orderType': 'taksi',
    };

    await FirebaseFirestore.instance.collection('orders').add(orderData);

    _showSnackBar('Buyurtma №$orderNumber yuborildi!');
    setState(() {
      _selectedPeople = '1';
      _selectedDateTime = null;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OrderHistoryPage()),
      );
    });
  }

  Future<int> _getNextOrderNumber() async {
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get the document that tracks the current order number
      DocumentReference orderNumberDoc =
          FirebaseFirestore.instance.collection('settings').doc('orderNumbers');

      DocumentSnapshot snapshot = await transaction.get(orderNumberDoc);

      if (!snapshot.exists) {
        // If the document doesn't exist, create it and set orderNumber = 1
        transaction.set(orderNumberDoc, {'orderNumber': 1});
        return 1;
      }

      // Get the current order number
      int currentOrderNumber = snapshot['orderNumber'];

      // Increment and save the new order number
      int newOrderNumber = currentOrderNumber + 1;
      transaction.update(orderNumberDoc, {'orderNumber': newOrderNumber});

      return newOrderNumber;
    });
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
        backgroundColor: AppColors.taxi,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: AppStyle.fontStyle.copyWith(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildLocationSelector(
              label: 'Qayerdan',
              location: fromLocation,
              onSelected: (selectedLocation) {
                setState(() {
                  fromLocation = selectedLocation;
                });
              },
            ),
            SizedBox(height: 10),
            _buildLocationSelector(
              label: 'Qayerga',
              location: toLocation,
              onSelected: (selectedLocation) {
                setState(() {
                  toLocation = selectedLocation;
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
    required Function(String) onSelected,
  }) {
    return GestureDetector(
      onTap: () {
        _showLocationBottomSheet((selectedLocation) {
          onSelected(selectedLocation);
        });
      },
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
        fillColor: Colors.grey[200],
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
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('regions').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final regions =
                snapshot.data!.docs.map((doc) => doc['region']).toList();

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
                    ...regions.map((location) => ListTile(
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
      },
    );
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
          ).toLocal();
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
          ).toLocal();
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
            ).toLocal();
          });
        }
      }
    }
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
