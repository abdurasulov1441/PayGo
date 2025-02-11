import 'package:flutter/material.dart';
import 'package:taksi/services/db/cache.dart';
import 'package:taksi/style/app_colors.dart';

class Taxidriversettings extends StatefulWidget {
  const Taxidriversettings({super.key});

  @override
  State<Taxidriversettings> createState() => _TaxidriversettingsState();
}

class _TaxidriversettingsState extends State<Taxidriversettings> {
  bool isGpsEnabled = false;
  bool isNotificationEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
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
        title: const Text(
          'Sozlamalar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 10),
          _buildSettingsItem(
            title: 'Hisob',
            icon: Icons.person_outline,
            onTap: () {},
          ),
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
            onTap: () {},
          ),
          _buildSettingsItem(
            title: 'Yordam va qo‘llab-quvvatlash',
            icon: Icons.headset_mic_outlined,
            onTap: () {},
          ),
          _buildSettingsItem(
            title: 'Ilova haqida',
            icon: Icons.info_outline,
            onTap: () {},
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
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.grade1,
      ),
    );
  }
}
