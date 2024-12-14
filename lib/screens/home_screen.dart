import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:taksi/screens/admin/admin_page.dart';
import 'package:taksi/screens/civil/civil_page.dart';
import 'package:taksi/screens/drivers/drivers_page.dart';
import 'package:taksi/screens/drivers_truck/truck_drivers_page.dart';
import 'package:taksi/screens/new_user/role_select.dart';

import 'package:taksi/style/app_style.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  Future<String?> getUserRole(String email) async {
    // Проверка для администратора
    final adminDoc =
        await FirebaseFirestore.instance.collection('data').doc('admin').get();

    if (adminDoc.exists) {
      final adminData = adminDoc.data();
      if (adminData != null && adminData['email'] == email) {
        return 'admin';
      }
    }

    // Проверка для таксистов
    QuerySnapshot<Map<String, dynamic>> driverSnapshot = await FirebaseFirestore
        .instance
        .collection('taxidrivers')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (driverSnapshot.docs.isNotEmpty) {
      final driverData = driverSnapshot.docs.first.data();
      if (driverData.containsKey('status')) {
        return driverData['status'] == 'active'
            ? 'Haydovchi_active'
            : 'Haydovchi_unidentified';
      }
      return 'Haydovchi';
    }

    // Проверка для водителей грузовиков
    QuerySnapshot<Map<String, dynamic>> truckDriverSnapshot =
        await FirebaseFirestore.instance
            .collection('truckdrivers')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

    if (truckDriverSnapshot.docs.isNotEmpty) {
      final truckDriverData = truckDriverSnapshot.docs.first.data();
      if (truckDriverData.containsKey('status')) {
        return truckDriverData['status'] == 'active'
            ? 'TruckDriver_active'
            : 'TruckDriver_unidentified';
      }
      return 'TruckDriver';
    }

    // Проверка для пассажира
    QuerySnapshot<Map<String, dynamic>> userSnapshot = await FirebaseFirestore
        .instance
        .collection('user')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      final userData = userSnapshot.docs.first.data();
      if (userData['status'] == 'active') {
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
        future: getUserRole(user.email!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: LottieBuilder.asset('assets/lottie/loading.json'),
              ),
            );
          } else if (snapshot.hasError) {
            return MainCivilPage();
          } else if (snapshot.data == 'admin') {
            // Логика для страницы администратора
            return AdminDashboard();
          } else if (snapshot.data == 'Haydovchi_active') {
            return const DriverPage();
          } else if (snapshot.data == 'Haydovchi_unidentified') {
            return const DriverUnidentifiedScreen();
          } else if (snapshot.data == 'TruckDriver_active') {
            return const TruckDriverPage();
          } else if (snapshot.data == 'TruckDriver_unidentified') {
            return const DriverUnidentifiedScreen();
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

class DriverUnidentifiedScreen extends StatelessWidget {
  const DriverUnidentifiedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Siz bloklangansiz!',
              style: AppStyle.fontStyle.copyWith(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 50),
            LottieBuilder.asset(
              'assets/lottie/block.json',
              width: 220,
              height: 220,
            ),
            SizedBox(height: 20),
            FutureBuilder<Map<String, String>?>(
              future: fetchSpecialistData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError || snapshot.data == null) {
                  return Text('Ошибка загрузки данных');
                } else {
                  final specialistData = snapshot.data!;
                  return Column(
                    children: [
                      Text('Biz bilan bog\'laning'),
                      SizedBox(height: 30),
                      Text(
                        specialistData['name']!,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        specialistData['phone_number']!,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Функция для получения данных специалиста из Firestore
// Функция для получения данных специалиста из коллекции data/call_center
  Future<Map<String, String>?> fetchSpecialistData() async {
    final specialistRef = FirebaseFirestore.instance
        .collection('data')
        .doc('call_center'); // Обновленная ссылка на коллекцию и документ

    final specialistSnapshot = await specialistRef.get();

    if (specialistSnapshot.exists) {
      final data = specialistSnapshot.data();
      return {
        'name': data?['name'] ?? '',
        'phone_number': data?['phone_number'] ?? '',
      };
    }
    return null;
  }
}
