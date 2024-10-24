import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:taksi/screens/drivers/chat_page.dart';
import 'package:taksi/screens/drivers_truck/truck_account.dart';
import 'package:taksi/screens/drivers_truck/truck_history.dart';
import 'package:taksi/screens/drivers_truck/truck_orders.dart';

import 'package:taksi/style/app_colors.dart';

import 'truck_acepted_orders.dart';

class TruckDriverPage extends StatefulWidget {
  const TruckDriverPage({super.key});

  @override
  _TruckDriverPageState createState() => _TruckDriverPageState();
}

class _TruckDriverPageState extends State<TruckDriverPage> {
  int _selectedIndex = 0;
  Timer? _locationUpdateTimer;

  // Define the pages corresponding to the BottomNavigationBar items
  static const List<Widget> _pages = <Widget>[
    TruckOrdersPage(), // Orders for trucks
    TruckAcceptedOrdersPage(), // Accepted Truck Orders
    TruckOrderHistoryPage(), // History of Truck Orders
    TruckDriverAccountPage(), // Account Page for truck drivers
  ];

  @override
  void initState() {
    super.initState();
    _startLocationUpdates(); // Start updating GPS data every 10 seconds
  }

  @override
  void dispose() {
    _locationUpdateTimer
        ?.cancel(); // Stop the timer when the widget is disposed
    super.dispose();
  }

  void _startLocationUpdates() {
    _locationUpdateTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      await _updateDriverLocation(); // Update driver location every 10 seconds
    });
  }

  // Function to get the driver's location and save it to Firestore
  Future<void> _updateDriverLocation() async {
    try {
      // Ensure permissions are granted
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          print('Location permissions are permanently denied');
          return;
        }
      }

      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return;
      }

      // Get current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String? driverEmail = FirebaseAuth.instance.currentUser?.email;
      if (driverEmail != null) {
        // Save to Firestore under a specific collection (e.g., "driver_locations")
        await FirebaseFirestore.instance
            .collection('driver_locations')
            .doc(driverEmail)
            .set(
                {
              'latitude': position.latitude,
              'longitude': position.longitude,
              'timestamp': FieldValue.serverTimestamp(),
            },
                SetOptions(
                    merge: true)); // Merge so we don't overwrite previous data
      }
    } catch (e) {
      print('Failed to get location: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Buyurtmalar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.done),
            label: 'Qabul qilingan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Buyurtma tarixi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Akkaunt',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: Colors.grey[600],
        ),
        iconSize: 26,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        backgroundColor: AppColors.taxi,
        child: Icon(
          Icons.chat,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatPage()),
          );
        },
      ),
    );
  }
}
