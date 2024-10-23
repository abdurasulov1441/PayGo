import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:taksi/screens/admin/admin_page.dart';
import 'package:taksi/screens/civil/civil_page.dart';
import 'package:taksi/screens/drivers/drivers_page.dart';
import 'package:taksi/screens/drivers_truck/truck_drivers_page.dart';
import 'package:taksi/screens/new_user/role_select_page.dart';
import 'package:taksi/style/app_style.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<String?> getUserRole(String uid, String email) async {
    if (email == 'abdurasulov1024@gmail.com') {
      return 'admin';
    }

    DocumentSnapshot<Map<String, dynamic>> driverSnapshot =
        await FirebaseFirestore.instance
            .collection('taxidrivers')
            .doc(uid)
            .get();

    if (driverSnapshot.exists) {
      final driverData = driverSnapshot.data();
      if (driverData != null && driverData.containsKey('status')) {
        return driverData['status'] == 'active'
            ? 'Haydovchi_active'
            : 'Haydovchi_unidentified';
      }
      return 'Haydovchi';
    }

    DocumentSnapshot<Map<String, dynamic>> truckDriverSnapshot =
        await FirebaseFirestore.instance
            .collection('truckdrivers')
            .doc(uid)
            .get();

    if (truckDriverSnapshot.exists) {
      final truckDriverData = truckDriverSnapshot.data();
      if (truckDriverData != null && truckDriverData.containsKey('status')) {
        return truckDriverData['status'] == 'active'
            ? 'TruckDriver_active'
            : 'TruckDriver_unidentified';
      }
      return 'TruckDriver';
    }

    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance.collection('user').doc(uid).get();

    if (userSnapshot.exists) {
      final userData = userSnapshot.data();
      if (userData != null && userData['status'] == 'active') {
        return 'Yo’lovchi';
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
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
            return MainCivilPage();
          } else if (snapshot.data == 'admin') {
            return AdminPage();
          } else if (snapshot.data == 'Haydovchi_active') {
            return const DriverPage();
          } else if (snapshot.data == 'Haydovchi_unidentified') {
            return DriverUnidentifiedScreen();
          } else if (snapshot.data == 'TruckDriver_active') {
            return const TruckDriversPage();
          } else if (snapshot.data == 'TruckDriver_unidentified') {
            return DriverUnidentifiedScreen();
          } else if (snapshot.data == 'Yo’lovchi') {
            return MainCivilPage();
          } else {
            return RoleSelectionPage();
          }
        },
      );
    }
  }
}

class DriverUnidentifiedScreen extends StatefulWidget {
  const DriverUnidentifiedScreen({super.key});

  @override
  State<DriverUnidentifiedScreen> createState() =>
      _DriverUnidentifiedScreenState();
}

class _DriverUnidentifiedScreenState extends State<DriverUnidentifiedScreen> {
  Future<void> _refreshPage() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF6E54b8),
      body: RefreshIndicator(
        onRefresh: _refreshPage,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ma\'lumotlaringiz tekshirilmoqda...',
                style: AppStyle.fontStyle.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 50,
              ),
              LottieBuilder.asset(
                'assets/lottie/checking.json',
                width: 220,
                height: 220,
              )
            ],
          ),
        ),
      ),
    );
  }
}
