import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CreateOrderTruck extends StatefulWidget {
  const CreateOrderTruck({super.key});

  @override
  _CreateOrderTruckState createState() => _CreateOrderTruckState();
}

class _CreateOrderTruckState extends State<CreateOrderTruck> {
  String fromLocation = 'Namangan';
  String toLocation = 'Toshkent';
  final TextEditingController _cargoWeightController = TextEditingController();
  final TextEditingController _cargoNameController = TextEditingController();
  final TextEditingController _phoneController =
      TextEditingController(text: '+998 '); // Pre-fill from database

  DateTime? _selectedDateTime;

  Future<void> _pickDateTime() async {
    DateTime now = DateTime.now();

    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now),
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

  Future<void> _submitTruckOrder() async {
    final phoneNumber = _phoneController.text.trim();
    final cargoWeight = _cargoWeightController.text.trim();
    final cargoName = _cargoNameController.text.trim();

    if (phoneNumber.isEmpty ||
        cargoWeight.isEmpty ||
        cargoName.isEmpty ||
        _selectedDateTime == null) {
      _showSnackBar('Please fill in all fields.');
      return;
    }

    final orderData = {
      'fromLocation': fromLocation,
      'toLocation': toLocation,
      'phoneNumber': phoneNumber,
      'cargoWeight': cargoWeight,
      'cargoName': cargoName,
      'orderTime': Timestamp.fromDate(_selectedDateTime!),
      'status': 'pending',
      'orderType': 'truck',
    };

    await FirebaseFirestore.instance.collection('orders').add(orderData);
    _showSnackBar('Order submitted successfully!');

    setState(() {
      _cargoWeightController.clear();
      _cargoNameController.clear();
      _selectedDateTime = null;
    });
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
      appBar: AppBar(title: Text('Create Truck Order')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildLocationContainer('From', fromLocation),
            SizedBox(height: 10),
            _buildLocationContainer('To', toLocation),
            SizedBox(height: 10),
            _buildTextField(
              controller: _cargoWeightController,
              hintText: 'Enter cargo weight',
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: _cargoNameController,
              hintText: 'Enter cargo name',
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: _phoneController,
              hintText: 'Enter phone number',
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickDateTime,
              child: Text('Select Order Time'),
            ),
            if (_selectedDateTime != null)
              Text(
                  'Selected Time: ${DateFormat('yyyy-MM-dd – HH:mm').format(_selectedDateTime!)}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitTruckOrder,
              child: Text('Submit Order'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationContainer(String label, String location) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text('$label: $location', style: TextStyle(fontSize: 16)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: hintText,
      ),
    );
  }
}
