import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:taksi/pages/drivers_taxi/driver_taxi_home.dart';
import 'package:taksi/pages/drivers_truck/driver_truck_home.dart';
import 'package:taksi/services/db/cache.dart';
import 'package:taksi/services/utils/Errorpage.dart';
import 'package:taksi/pages/admin/admin_page.dart';
import 'package:taksi/pages/civil/civil_page.dart';
import 'package:taksi/pages/new_user/role_select.dart';
import 'package:taksi/services/request_helper.dart';
import 'package:taksi/services/utils/errors.dart';
import 'package:taksi/services/style/app_style.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>?> _futureUserStatus;

  Future<Map<String, dynamic>?> checkUserStatus() async {
    try {
      final response = await requestHelper
          .getWithAuth('/services/zyber/api/users/get-user-status', log: true);

      return response as Map<String, dynamic>?;
    } on UnauthenticatedError {
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _futureUserStatus = checkUserStatus();
  }

  void retryFetchUserStatus() {
    setState(() {
      _futureUserStatus = checkUserStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _futureUserStatus,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Image.asset('assets/images/logo.png', width: 200),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset('assets/images/logo.png', width: 200),
                ),
                Text('Internet bilan aloqa yo\'q'),
                ElevatedButton(
                  onPressed: retryFetchUserStatus,
                  child: Text('Qayta urinish'),
                ),
              ],
            ),
          );
        } else {
          final userData = snapshot.data!;
          final int? status = userData['status'] as int?;
          final int? roleId = userData['role_id'] as int?;

          if (status == null || roleId == null) {
            return const RoleSelectionPage();
          }

          if (status == 0) {
            return const BlockedUsersPage();
          }

          switch (roleId) {
            case 0:
              return const RoleSelectionPage();
            case 1:
              return const MainCivilPage();
            case 2:
              return const DriverTaxiHome();
            case 3:
              return const DriverTruckHome();
            case 4:
              return const AdminDashboard();
            default:
              return const ErrorPage();
          }
        }
      },
    );
  }
}

class BlockedUsersPage extends StatelessWidget {
  const BlockedUsersPage({super.key});

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
            Text(
              'Iltimos, yordam uchun call center bilan bog\'laning.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
