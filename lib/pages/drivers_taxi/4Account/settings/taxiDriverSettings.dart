import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:taksi/app/router.dart';
import 'package:taksi/services/db/cache.dart';
import 'package:taksi/services/style/app_colors.dart';
import 'package:taksi/services/style/app_style.dart';
import 'package:url_launcher/url_launcher.dart';

class Taxidriversettings extends StatefulWidget {
  const Taxidriversettings({super.key});

  @override
  State<Taxidriversettings> createState() => _TaxidriversettingsState();
}

class _TaxidriversettingsState extends State<Taxidriversettings> {
  bool isGpsEnabled = false;
  bool isNotificationEnabled = false;
  bool _isTermsAccepted = false;

  final InAppReview _inAppReview = InAppReview.instance;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _requestReview() async {
    if (Platform.isAndroid) {
      // Только для Android
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
      } else {
        await _inAppReview.openStoreListing(
          appStoreId: "uz.paygo", // Укажи свой package name
        );
      }
    }
  }

  void _launchPrivacyPolicy() async {
    final Uri url = Uri.parse("http://appdata.uz/paygo_privacy.pdf");

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Не удалось открыть $url');
    }
  }

  Future<void> _loadSettings() async {
    setState(() {
      isGpsEnabled = cache.getBool('isGPS') ?? false;
      isNotificationEnabled = cache.getBool('isNotification') ?? false;
    });
  }

  Future<void> _toggleGps(bool value) async {
    await cache.setBool('isGPS', value);
    setState(() {
      isGpsEnabled = value;
    });
  }

  Future<void> _toggleNotification(bool value) async {
    await cache.setBool('isNotification', value);
    setState(() {
      isNotificationEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sozlamalar',
          style: AppStyle.fontStyle.copyWith(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.grade1,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 10),
          _buildSwitchItem(
            title: 'Bildirishnomalar',
            icon: Icons.notifications_outlined,
            value: isNotificationEnabled,
            onChanged: _toggleNotification,
          ),
          _buildSwitchItem(
            title: 'Joylashuvni ko\'rsatish',
            icon: Icons.location_on_outlined,
            value: isGpsEnabled,
            onChanged: _toggleGps,
          ),
          _buildSettingsItem(
            title: 'Maxfiylik va xavfsizlik',
            icon: Icons.lock_outline,
            onTap: () {
              _launchPrivacyPolicy();
            },
          ),
          _buildSettingsItem(
            title: 'Baholash',
            icon: Icons.star_outline,
            onTap: () {
              _requestReview();
            },
          ),
          _buildSettingsItem(
            title: 'Ilova haqida',
            icon: Icons.info_outline,
            onTap: () {
              context.push(Routes.appInfo);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(
        title,
        style: AppStyle.fontStyle.copyWith(
            fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black38),
      onTap: onTap,
    );
  }

  Widget _buildSwitchItem({
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(
        title,
        style: AppStyle.fontStyle.copyWith(
            fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.grade1,
      ),
    );
  }
}
