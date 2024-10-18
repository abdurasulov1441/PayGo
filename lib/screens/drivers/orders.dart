import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BuyurtmalarPage extends StatefulWidget {
  const BuyurtmalarPage({super.key});

  @override
  _BuyurtmalarPageState createState() => _BuyurtmalarPageState();
}

class _BuyurtmalarPageState extends State<BuyurtmalarPage> {
  final user = FirebaseAuth.instance.currentUser;
  bool _needsCarDetails = false;

  @override
  void initState() {
    super.initState();
    checkCarDetails();
  }

  Future<void> checkCarDetails() async {
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('driver')
          .doc(user!.uid)
          .get();

      if (snapshot.exists) {
        // Check if any of the car details fields are empty
        var data = snapshot.data();
        if (data != null &&
            (data['car_type'] == "" ||
                data['car_number'] == "" ||
                data['car_color'] == "" ||
                data['car_model'] == "")) {
          setState(() {
            _needsCarDetails = true;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _needsCarDetails
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Avtomobil ma\'lumotlarini to\'ldiring',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Buyurtma olish uchun avtomobil ma\'lumotlarini to\'ldiring',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            )
          : Text(
              'Buyurtmalar',
              style: TextStyle(fontSize: 24),
            ),
    );
  }
}
