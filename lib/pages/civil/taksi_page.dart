import 'package:bottom_picker/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bottom_picker/bottom_picker.dart';

class TaxiPage extends StatefulWidget {
  const TaxiPage({super.key});

  @override
  _TaxiPageState createState() => _TaxiPageState();
}

class _TaxiPageState extends State<TaxiPage> {
  String fromLocation = 'Namangan';
  String toLocation = 'Toshkent';
  List<String> regions = [];
  bool isLoadingRegions = true;

  final TextEditingController _phoneController =
      TextEditingController(text: '+998 ');

  final List<String> _periodOptions = [
    'Tanlanmadi',
    'Hoziroq',
    'Bugun',
    'Ertaga',
    'Boshqa vaqt'
  ];
  final List<String> _peopleOptions = ['Tanlanmadi', '1', '2', '3', '4'];

  String _selectedPeriod = 'Tanlanmadi';
  String _selectedPeople = 'Tanlanmadi';
  DateTime? _selectedDateTime;

 

  @override
  void initState() {
    super.initState();
    fetchRegions();
  }

  Future<void> fetchRegions() async {
    try {
      // Imitation of a region fetch function. Replace with your API request.
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        regions = ['Namangan', 'Toshkent', 'Farg‘ona', 'Andijon'];
        isLoadingRegions = false;
      });
    } catch (e) {
      print('Ошибка загрузки регионов: $e');
    }
  }

  void _pickDateTime() {
    BottomPicker.dateTime(
      pickerTitle: Text(
        "Vaqtni tanlang",
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      onSubmit: (date) {
        setState(() {
          _selectedDateTime = date;
        });
      },
      bottomPickerTheme: BottomPickerTheme.blue,
    ).show(context);
  }

  Future<void> _submitData() async {
    final phoneNumber = _phoneController.text.trim();

    if (phoneNumber.isEmpty ||
        _selectedPeriod == 'Tanlanmadi' ||
        _selectedPeople == 'Tanlanmadi' ||
        (_selectedPeriod == 'Boshqa vaqt' && _selectedDateTime == null)) {
      _showSnackBar('Iltimos, barcha maydonlarni to\'ldiring.');
      return;
    }

    final orderData = {
      'fromLocation': fromLocation,
      'toLocation': toLocation,
      'phoneNumber': phoneNumber,
      'peopleCount': int.parse(_selectedPeople),
      'orderTime': _selectedDateTime ?? DateTime.now(),
      'status': 'pending',
      'orderType': 'taksi',
      'driverId': null,
      'driverPhoneNumber': null,
    };

    print(orderData);

    _showSnackBar('Ma\'lumotlar yuborildi!');

    setState(() {
      _phoneController.clear();
      _selectedPeriod = 'Tanlanmadi';
      _selectedPeople = 'Tanlanmadi';
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
      appBar: AppBar(title: const Text("Taksi Buyurtma")),
      body: isLoadingRegions
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildLocationContainer('Qayerdan', fromLocation),
                  const SizedBox(height: 20),
                  _buildLocationContainer('Qayerga', toLocation),
                  const SizedBox(height: 20),
                  _buildDropdown(
                    label: 'Vaqtni tanlang',
                    value: _selectedPeriod,
                    items: _periodOptions,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedPeriod = newValue!;
                        _selectedDateTime = null;
                      });
                      if (_selectedPeriod == 'Boshqa vaqt') {
                        _pickDateTime();
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  if (_selectedDateTime != null)
                    Text(
                      "Tanlangan vaqt: ${_selectedDateTime.toString()}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  const SizedBox(height: 20),
                  _buildDropdown(
                    label: 'Odamlar soni',
                    value: _selectedPeople,
                    items: _peopleOptions,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedPeople = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitData,
                    child: const Text('Yuborish'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLocationContainer(String label, String location) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$label: $location',
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
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
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        DropdownButton<String>(
          value: value,
          isExpanded: true,
          underline: const SizedBox(),
          items: items.map<DropdownMenuItem<String>>((String item) {
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
