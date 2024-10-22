import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:taksi/screens/admin/admin_page.dart';
import 'package:taksi/screens/civil/civil_page.dart';
import 'package:taksi/screens/drivers/drivers_page.dart';
import 'package:taksi/screens/new_user/role_select_page.dart';
import 'package:taksi/style/app_style.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<String?> getUserRole(String uid, String email) async {
    // Check for admin by email
    if (email == 'abdurasulov1024@gmail.com') {
      return 'admin';
    }

    // Check if the user is in the 'driver' collection
    DocumentSnapshot<Map<String, dynamic>> driverSnapshot =
        await FirebaseFirestore.instance.collection('driver').doc(uid).get();

    if (driverSnapshot.exists) {
      final driverData = driverSnapshot.data();
      if (driverData != null && driverData.containsKey('status')) {
        return driverData['status'] == 'active'
            ? 'Haydovchi_active'
            : 'Haydovchi_unidentified';
      }
      return 'Haydovchi'; // Default to Haydovchi if no status field
    }

    // Check if the user is in the 'user' collection
    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance.collection('user').doc(uid).get();

    if (userSnapshot.exists) {
      return 'Yo’lovchi'; // Passenger
    }

    // No role found, user needs to select a role
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // If not logged in, show MainCivilPage
      return MainCivilPage();
    } else {
      return FutureBuilder<String?>(
        future: getUserRole(user.uid, user.email!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: LottieBuilder.asset('assets/lottie/loading.json'),
              ),
            );
          } else if (snapshot.hasError) {
            // In case of an error, default to MainCivilPage
            return MainCivilPage();
          } else if (snapshot.data == 'admin') {
            return AdminPage(); // Admin role goes to AdminPage
          } else if (snapshot.data == 'Haydovchi_active') {
            return const DriverPage(); // Driver role goes to DriverPage
          } else if (snapshot.data == 'Haydovchi_unidentified') {
            // Show message if driver status is 'unidentified'
            return DriverUnidentifiedScreen();
          } else if (snapshot.data == 'Yo’lovchi') {
            return MainCivilPage(); // Passenger role goes to CivilPage
          } else {
            // No role found, navigate to RoleSelectionPage
            return RoleSelectionPage();
          }
        },
      );
    }
  }
}

class DriverUnidentifiedScreen extends StatefulWidget {
  @override
  _DriverUnidentifiedScreenState createState() =>
      _DriverUnidentifiedScreenState();
}

class _DriverUnidentifiedScreenState extends State<DriverUnidentifiedScreen> {
  Future<void> _refreshDriverStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> driverSnapshot =
          await FirebaseFirestore.instance
              .collection('driver')
              .doc(user.uid)
              .get();

      if (driverSnapshot.exists) {
        final driverData = driverSnapshot.data();
        if (driverData != null && driverData.containsKey('status')) {
          final status = driverData['status'];
          if (status == 'active') {
            // Navigate to DriverPage if status is active
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => DriverPage()),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF6E53B8),
      body: RefreshIndicator(
        onRefresh: _refreshDriverStatus,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          children: [
            SizedBox(
              height: 80,
            ),
            Center(
              child: Text(
                "Sizning ma'lumotlaringiz hozirda tekshirilmoqda. Iltimos, kuting.",
                style: AppStyle.fontStyle.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            LottieBuilder.asset(
              'assets/lottie/checking.json',
              width: 250,
              height: 250,
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                "Siz ushbu sahifani yangilab turishingiz mumkin.",
                style: AppStyle.fontStyle.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
