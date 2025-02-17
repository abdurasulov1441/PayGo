import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:taksi/app/router.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';
import 'package:easy_localization/easy_localization.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  _PermissionScreenState createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> _permissions = [
    {
      "title": tr("sms_title"),
      "description": tr("sms_description"),
      "icon": Icons.sms,
      "permission": Permission.sms,
      "mandatory": true,
    },
    {
      "title": tr("gps_title"),
      "description": tr("gps_description"),
      "icon": Icons.location_on,
      "permission": Permission.location,
      "mandatory": false,
    },
    {
      "title": tr("notifications_title"),
      "description": tr("notifications_description"),
      "icon": Icons.notifications,
      "permission": Permission.notification,
      "mandatory": false,
    },
  ];

  Future<void> _requestPermission(int index) async {
    Permission permission = _permissions[index]["permission"] as Permission;
    var status = await permission.request();
    if (status.isGranted || !_permissions[index]["mandatory"]) {
      if (index < _permissions.length - 1) {
        _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      } else {
        context.go(Routes.donePage);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('permission_denied_message'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _permissions.length,
        itemBuilder: (context, index) {
          return _buildPermissionPage(
            _permissions[index]["title"],
            _permissions[index]["description"],
            _permissions[index]["icon"],
            () => _requestPermission(index),
            index,
          );
        },
      ),
    );
  }

  Widget _buildPermissionPage(String title, String description, IconData icon,
      VoidCallback onPressed, int index) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.grade2, AppColors.grade1],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              onPressed: onPressed,
              child: Text(
                tr("allow_button"),
                style: AppStyle.fontStyle.copyWith(
                    color: AppColors.grade1, fontWeight: FontWeight.bold),
              ),
            ),
            if (!_permissions[index]["mandatory"]) ...[
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut),
                child: Text(tr("skip_button"),
                    style: const TextStyle(color: Colors.white70)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
