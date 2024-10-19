import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateOrderTaksi extends StatefulWidget {
  const CreateOrderTaksi({super.key});

  @override
  _CreateOrderTaksiState createState() => _CreateOrderTaksiState();
}

class _CreateOrderTaksiState extends State<CreateOrderTaksi> {
  String fromLocation = 'Namangan';
  String toLocation = 'Toshkent';
  final TextEditingController _phoneController =
      TextEditingController(text: '+998 ');
  String _selectedPeople = '1';
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

  Future<void> _submitTaxiOrder() async {
    final phoneNumber = _phoneController.text.trim();

    if (phoneNumber.isEmpty || _selectedDateTime == null) {
      _showSnackBar('Please fill in all fields.');
      return;
    }

    final orderData = {
      'fromLocation': fromLocation,
      'toLocation': toLocation,
      'phoneNumber': phoneNumber,
      'peopleCount': int.parse(_selectedPeople),
      'orderTime': Timestamp.fromDate(_selectedDateTime!),
      'status': 'pending',
      'orderType': 'taksi',
    };

    await FirebaseFirestore.instance.collection('orders').add(orderData);
    _showSnackBar('Order submitted successfully!');

    setState(() {
      _selectedPeople = '1';
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
      appBar: AppBar(title: Text('Create Taxi Order')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildLocationContainer('From', fromLocation),
            SizedBox(height: 10),
            _buildLocationContainer('To', toLocation),
            SizedBox(height: 10),
            _buildDropdown(
              label: 'Number of People',
              value: _selectedPeople,
              items: ['1', '2', '3', '4'],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPeople = newValue!;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickDateTime,
              child: Text('Select Order Time'),
            ),
            if (_selectedDateTime != null)
              Text('Selected Time: ${_selectedDateTime.toString()}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitTaxiOrder,
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

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        DropdownButton<String>(
          value: value,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
