import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:taksi/pages/civil/history_truck.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateOrderTruck extends StatefulWidget {
  const CreateOrderTruck({super.key});

  @override
  _CreateOrderTruckState createState() => _CreateOrderTruckState();
}

class _CreateOrderTruckState extends State<CreateOrderTruck> {
  String fromLocation = 'Namangan';
  String toLocation = 'Samarqand';
  final TextEditingController _cargoNameController = TextEditingController();
  final TextEditingController _cargoWeightController = TextEditingController();
  DateTime? _selectedDateTime;
  final List<String> _periodOptions = [
    'Hoziroq',
    'Bugun',
    'Ertaga',
    'Boshqa vaqt'
  ];

  Future<void> _submitTruckOrder() async {
    if (_selectedDateTime == null) {
      _showSnackBar('Iltimos, vaqtni tanlang');
      return;
    }

    String userId = await _getUserId();
    int orderNumber = await _getNextOrderNumber();

    final orderData = {
      'user_id': userId,
      'accept_time': Timestamp.now(),
      'chosen_time': Timestamp.fromDate(_selectedDateTime!),
      'cargo_weight': double.tryParse(_cargoWeightController.text) ?? 0.0,
      'cargo_name': _cargoNameController.text,
      'from': fromLocation,
      'to': toLocation,
      'status': 'kutish jarayonida',
      'accepted_by': null,
    };

    await FirebaseFirestore.instance
        .collection('truck_orders')
        .doc(orderNumber.toString())
        .set(orderData);

    _showSnackBar('Buyurtma №$orderNumber yuborildi!');
    setState(() {
      _cargoNameController.clear();
      _cargoWeightController.clear();
      _selectedDateTime = null;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TruckOrderHistoryPage()),
      );
    });
  }

  Future<String> _getUserId() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final email = user.email;
      if (email != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('user')
            .where('email', isEqualTo: email)
            .get();

        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.first.id;
        }
      }
    }
    return 'Unknown';
  }

  Future<int> _getNextOrderNumber() async {
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentReference orderNumberDoc = FirebaseFirestore.instance
          .collection('truck_settings')
          .doc('orderNumbers');

      DocumentSnapshot snapshot = await transaction.get(orderNumberDoc);

      if (!snapshot.exists) {
        transaction.set(orderNumberDoc, {'orderNumber': 1});
        return 1;
      }

      int currentOrderNumber = snapshot['orderNumber'];
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios)),
        centerTitle: true,
        title: Text('Yuk uchun buyurtma',
            style:
                AppStyle.fontStyle.copyWith(color: Colors.white, fontSize: 20)),
        backgroundColor: AppColors.taxi,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
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
                    _buildCargoNameField(),
                    SizedBox(height: 10),
                    _buildCargoWeightField(),
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
                      onPressed: _submitTruckOrder,
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
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLocationSelector({
    required String label,
    required String location,
    required ValueChanged<String> onSelected,
  }) {
    return GestureDetector(
      onTap: () => _showLocationBottomSheet(onSelected),
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

  Widget _buildCargoNameField() {
    return TextFormField(
      controller: _cargoNameController,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(width: 1, color: Colors.white),
        ),
        labelText: 'Yuk nomi',
        labelStyle: AppStyle.fontStyle,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(width: 1, color: Colors.white),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(width: 1, color: Colors.black),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildCargoWeightField() {
    return TextFormField(
      controller: _cargoWeightController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(width: 1, color: Colors.white),
        ),
        labelText: 'Yuk vazni (kg)',
        labelStyle: AppStyle.fontStyle,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(width: 1, color: Colors.white),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(width: 1, color: Colors.black),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  void _showLocationBottomSheet(Function(String) onSelected) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('data')
              .doc('regions')
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            final regions = List<String>.from(snapshot.data!['regions']);

            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Manzilni tanlang',
                        style: AppStyle.fontStyle.copyWith(fontSize: 18)),
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
              Text('Vaqtni tanlang',
                  style: AppStyle.fontStyle.copyWith(fontSize: 18)),
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
