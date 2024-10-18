import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AvtomobilSozlamalariPage extends StatefulWidget {
  const AvtomobilSozlamalariPage({super.key});

  @override
  _AvtomobilSozlamalariPageState createState() =>
      _AvtomobilSozlamalariPageState();
}

class _AvtomobilSozlamalariPageState extends State<AvtomobilSozlamalariPage> {
  String? selectedVehicle;
  final TextEditingController colorController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  void saveVehicleDetails() async {
    if (user != null && selectedVehicle != null) {
      await FirebaseFirestore.instance
          .collection('driver')
          .doc(user!.uid)
          .update({
        'car_type': selectedVehicle,
        'car_color': colorController.text,
        'car_model': modelController.text,
        'car_number': numberController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ma\'lumotlar saqlandi!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Transport turini tanlang',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                vehicleOption(
                  'Gruzovoy',
                  Icons.local_shipping,
                  Colors.teal,
                  'Truck',
                ),
                vehicleOption(
                  'Taksi',
                  Icons.local_taxi,
                  Colors.orange,
                  'Taxi',
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (selectedVehicle != null) ...[
              Text(
                '$selectedVehicle uchun ma\'lumotlarni kiriting',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              buildTextField(
                  colorController, 'Mashina rangi', Icons.color_lens),
              const SizedBox(height: 10),
              buildTextField(modelController, 'Modeli', Icons.directions_car),
              const SizedBox(height: 10),
              buildTextField(numberController, 'Avtomobil raqami',
                  Icons.confirmation_number),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveVehicleDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                ),
                child: const Text('Saqlash'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget vehicleOption(String title, IconData icon, Color color, String value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedVehicle = value;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: selectedVehicle == value ? Colors.teal : Colors.transparent,
            width: 2,
          ),
        ),
        width: 120,
        height: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 10),
            Text(title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
      TextEditingController controller, String hintText, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: hintText,
        prefixIcon: Icon(icon, color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
