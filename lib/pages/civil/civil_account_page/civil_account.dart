import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taksi/app/router.dart';
import 'package:taksi/services/db/cache.dart';
import 'package:taksi/services/style/app_colors.dart';

class CivilAccount extends StatelessWidget {
  const CivilAccount({super.key});
  Future<void> _signOut() async {
    cache.clear();
    router.go(Routes.loginScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: Icon(Icons.arrow_back, color: Colors.white)),
        backgroundColor: AppColors.grade1,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Text(
              'Lorem Lorem',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('Planned: 216', style: TextStyle(color: Colors.grey)),
                SizedBox(width: 20),
                Text('Completed: 512', style: TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 20),
            ...[
              'Akkunt ma\'lumotlari',
              'Taksi tarixi',
              'Yuk tarixi',
              'Sozlamalar',
            ].map(
              (title) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () {
                    switch (title) {
                      case 'Akkunt ma\'lumotlari':
                        context.push(Routes.civilTaksiHistoryPage);
                        break;
                      case 'Taksi tarixi':
                        context.push(Routes.civilTaksiHistoryPage);
                        break;
                      case 'Yuk tarixi':
                        context.push(Routes.civilTaksiHistoryPage);
                        break;
                      case 'Sozlamalar':
                        context.push(Routes.civilTaksiHistoryPage);
                        break;
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Icon(
                          _getIconForTitle(title),
                          color: AppColors.grade1,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          title,
                          style: const TextStyle(color: Colors.black),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                _signOut();
              },
              child: const Text(
                'Chiqish',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    switch (title) {
      case 'Akkunt ma\'lumotlari':
        return Icons.person;
      case 'Taksi tarixi':
        return Icons.local_taxi_outlined;
      case 'Yuk tarixi':
        return Icons.local_shipping;
      case 'Sozlamalar':
        return Icons.settings;

      default:
        return Icons.circle;
    }
  }
}
