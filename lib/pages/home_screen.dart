import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:taksi/services/utils/Errorpage.dart';
import 'package:taksi/pages/admin/admin_page.dart';
import 'package:taksi/pages/civil/civil_page.dart';
import 'package:taksi/pages/new_user/role_select.dart';
import 'package:taksi/pages/sign/login_screen.dart';
import 'package:taksi/services/request_helper.dart';
import 'package:taksi/services/utils/errors.dart';
import 'package:taksi/style/app_style.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<Map<String, dynamic>?> checkUserStatus() async {
    try {
      // Выполнение GET-запроса через RequestHelper
      final response = await requestHelper.getWithAuth(
        '/services/zyber/api/users/get-user-status',
      );

      return response
          as Map<String, dynamic>?; // Возвращаем данные о статусе пользователя
    } on UnauthenticatedError {
      // Если токен недействителен, возвращаем null
      return null;
    } catch (e) {
      // Обработка сетевых ошибок
      print('Ошибка сети: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: checkUserStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: LottieBuilder.asset('assets/lottie/loading.json'),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data == null) {
          // Если токена нет или ошибка — отправляем на LoginPage
          return LoginScreen();
        } else {
          final userData = snapshot.data!;
          final int status = userData['status'];
          final int roleId = userData['role_id'];

          // Проверяем статус и роли
          if (status == 0) {
            return const BlockedUsersPage();
          }

          switch (roleId) {
            case 0:
              return RoleSelectionPage();
            case 1:
              return MainCivilPage();
            // case 2:
            //   return DriverPage();
            // case 3:
            //   return TruckDriverPage();
            case 4:
              return AdminDashboard();
            default:
              return ErrorPage();
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