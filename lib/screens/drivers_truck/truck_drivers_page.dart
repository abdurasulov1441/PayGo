import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:taksi/screens/drivers_truck/truck_account.dart';
import 'package:taksi/screens/drivers_truck/truck_acepted_orders.dart';
import 'package:taksi/screens/drivers_truck/truck_history.dart';
import 'package:taksi/screens/drivers_truck/truck_orders.dart';
import 'package:taksi/screens/drivers_truck/chat_page.dart';
import 'package:taksi/style/app_colors.dart';

class TruckDriverPage extends StatefulWidget {
  const TruckDriverPage({super.key});

  @override
  _TruckDriverPageState createState() => _TruckDriverPageState();
}

class _TruckDriverPageState extends State<TruckDriverPage> {
  int _selectedIndex = 0;
  Timer? _locationUpdateTimer;
  bool _isSubscriptionValid = true;

  @override
  void initState() {
    super.initState();
    _checkSubscriptionStatus();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _locationUpdateTimer
        ?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<void> _checkSubscriptionStatus() async {
    print("Starting _checkSubscriptionStatus function");
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final querySnapshot = await FirebaseFirestore.instance
          .collection('truckdrivers')
          .where('email', isEqualTo: user.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        print("Document found: ${data.toString()}");

        if (data != null && data['expired_date'] != null) {
          final DateTime expirationDate =
              (data['expired_date'] as Timestamp).toDate();

          // Ensure setState is called only if the widget is still mounted
          if (mounted) {
            setState(() {
              _isSubscriptionValid = DateTime.now().isBefore(expirationDate);
            });
          }
          print("Subscription is valid: $_isSubscriptionValid");
        } else {
          print("No 'expired_date' field found in document");
        }
      } else {
        print("No document found for this user in 'truckdrivers' collection");
      }
    } catch (e) {
      print("Error checking subscription status: $e");
      if (mounted) {
        setState(() {
          _isSubscriptionValid = false;
        });
      }
    }
  }

  void _startLocationUpdates() {
    _locationUpdateTimer = Timer.periodic(Duration(minutes: 10), (timer) async {
      if (mounted) {
        await _updateDriverLocation();
      } else {
        _locationUpdateTimer
            ?.cancel(); // Ensure the timer is canceled if widget is unmounted
      }
    });
  }

  Future<void> _updateDriverLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) return;
      }

      if (permission == LocationPermission.denied) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String? driverEmail = FirebaseAuth.instance.currentUser?.email;
      if (driverEmail != null) {
        await FirebaseFirestore.instance
            .collection('driver_locations')
            .doc(driverEmail)
            .set({
          'latitude': position.latitude,
          'longitude': position.longitude,
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Failed to get location: $e');
    }
  }

  void _onItemTapped(int index) {
    if (mounted) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = _isSubscriptionValid
        ? [
            TruckOrdersPage(),
            TruckAcceptedOrdersPage(),
            TruckOrderHistoryPage(),
            TruckDriverAccountPage(),
          ]
        : [
            SubscriptionExpiredPage(),
            TruckAcceptedOrdersPage(),
            TruckOrderHistoryPage(),
            TruckDriverAccountPage(),
          ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: pages[_selectedIndex],
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
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        iconSize: 24,
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
            MaterialPageRoute(builder: (context) => TruckDriverChatPage()),
          );
        },
      ),
    );
  }
}

class SubscriptionExpiredPage extends StatelessWidget {
  const SubscriptionExpiredPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 10,
        color: Colors.white,
        margin: EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LottieBuilder.asset('assets/lottie/peoples.json'),
              SizedBox(height: 20),
              Text(
                'Sizning obunangiz muddati tugagan. Buyurtmalarni ko\'rish uchun obunani yangilang.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.taxi,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
