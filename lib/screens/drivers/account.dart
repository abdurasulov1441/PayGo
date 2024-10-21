import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taksi/screens/civil/civil_page.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart'; // Import your AppStyle

class AkkauntPage extends StatelessWidget {
  const AkkauntPage({super.key});

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainCivilPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xatolik: Chiqishda xatolik yuz berdi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Akkaunt',
          style: AppStyle.fontStyle.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.taxi,
      ),
      body: Column(
        children: [
          _buildProfileHeader(),
          Expanded(
            child: _buildMenuItems(context),
          ),
        ],
      ),
    );
  }

  // Profile header with avatar and balance display
  Widget _buildProfileHeader() {
    final user = FirebaseAuth.instance.currentUser;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.taxi,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(
                'https://via.placeholder.com/150'), // Replace with real avatar URL or asset
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.displayName ?? 'Ism kiritilmagan',
                style: AppStyle.fontStyle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Balans: 0 UZS', // Fetch and display actual balance
                style: AppStyle.fontStyle
                    .copyWith(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Menu items for different actions
  Widget _buildMenuItems(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMenuItem(
          context,
          icon: Icons.account_balance_wallet,
          title: 'Popolnit balans',
          onTap: () {
            // Implement balance top-up action
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Popolnit balans selected')),
            );
          },
        ),
        const SizedBox(height: 10),
        _buildMenuItem(
          context,
          icon: Icons.history,
          title: 'Tarix',
          onTap: () {
            // Implement history action
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tarix selected')),
            );
          },
        ),
        const SizedBox(height: 10),
        _buildMenuItem(
          context,
          icon: Icons.settings,
          title: 'Sozlamalar',
          onTap: () {
            // Implement settings action
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Sozlamalar selected')),
            );
          },
        ),
        const SizedBox(height: 10),
        _buildMenuItem(
          context,
          icon: Icons.logout,
          title: 'Chiqish',
          onTap: () => _signOut(context),
        ),
      ],
    );
  }

  // Helper method to build a menu item
  Widget _buildMenuItem(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(
        title,
        style: AppStyle.fontStyle.copyWith(fontSize: 18),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      tileColor: Colors.grey[200],
    );
  }
}
