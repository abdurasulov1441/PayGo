import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:taksi/screens/admin/home_page.dart';
import 'package:taksi/screens/civil/civil_page.dart';
import 'package:taksi/screens/drivers/drivers_page.dart';
import 'package:taksi/screens/new_user_add.dart';

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
      return 'Haydovchi'; // Driver
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
            return const MainPage(); // Admin role goes to AdminPage
          } else if (snapshot.data == 'Haydovchi') {
            return const DriverPage(); // Driver role goes to DriverPage
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
