import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taksi/screens/civil/civil_page.dart';
import 'package:taksi/screens/drivers_truck/obunalar.dart';
import 'package:taksi/screens/drivers/payment.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart'; // Import your AppStyle

class AkkauntPage extends StatefulWidget {
  const AkkauntPage({super.key});

  @override
  _AkkauntPageState createState() => _AkkauntPageState();
}

class _AkkauntPageState extends State<AkkauntPage> {
  Future<void> _refreshPage() async {
    setState(() {});
  }

  Future<void> _signOut(BuildContext context) async {
    _showLogoutDialog(context); // Show the logout confirmation dialog
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Akkaunt',
          style: AppStyle.fontStyle.copyWith(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: AppColors.taxi,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPage, // This will refresh the page
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // Always scrollable
          child: Column(
            children: [
              _buildProfileHeader(),
              SizedBox(height: 20),
              _buildMenuItems(context),
            ],
          ),
        ),
      ),
    );
  }

  // Profile header with avatar, balance, full name, subscription plan, and expiration date display
  Widget _buildProfileHeader() {
    final user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('taxidrivers')
          .doc(user?.uid)
          .get(), // Corrected collection
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return Center(child: Text('Xatolik: Ma\'lumotlar yuklanmadi'));
        }

        // Fetch user data from Firestore
        final data = snapshot.data!.data() as Map<String, dynamic>?;

        String firstName = data?['name'] ?? 'Ism kiritilmagan';
        String lastName = data?['lastName'] ?? 'Familiya kiritilmagan';
        String fullName = '$firstName $lastName';

        int balance = data?['balance'] ?? 0; // Fetch the balance

        // Format the balance with thousand separators
        String formattedBalance =
            NumberFormat('#,###', 'en_US').format(balance).replaceAll(',', ' ');

        // Fetch subscription plan and expiration date (if exists)
        String? subscriptionPlan = data?['subscription_plan'];
        Timestamp? expirationTimestamp = data?['expired_date'];
        String? formattedExpiration;

        if (expirationTimestamp != null) {
          DateTime expirationDate = expirationTimestamp.toDate();
          Duration difference = expirationDate.difference(DateTime.now());

          int months = difference.inDays ~/ 30;
          int days = difference.inDays % 30;

          if (months > 0) {
            formattedExpiration = '$months oylik, $days kun';
          } else {
            formattedExpiration = '$days kun';
          }
        }

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
                    fullName,
                    style: AppStyle.fontStyle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Balans: $formattedBalance UZS', // Display the formatted balance
                    style: AppStyle.fontStyle.copyWith(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  if (subscriptionPlan != null &&
                      formattedExpiration != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Tarif: $subscriptionPlan',
                      style: AppStyle.fontStyle.copyWith(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      'Tugash sanasi: $formattedExpiration',
                      style: AppStyle.fontStyle.copyWith(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Menu items for different actions
  Widget _buildMenuItems(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // Disable ListView scroll
      children: [
        _buildMenuItem(
          context,
          icon: Icons.account_balance_wallet,
          title: 'Balansni to\'ldirish',
          onTap: () {
            // Navigate to balance top-up page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BalanceTopUpPage()),
            );
          },
        ),
        const SizedBox(height: 10),
        _buildMenuItem(
          context,
          icon: Icons.subscriptions,
          title: 'Obunalar', // Changed from History to Obunalar
          onTap: () {
            // Handle Obunalar logic here
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ObunalarPage()),
            );
          },
        ),
        const SizedBox(height: 10),
        _buildMenuItem(
          context,
          icon: Icons.nightlight_round,
          title: 'Tun rejimi va Til', // Night mode and language settings
          onTap: () {
            // Handle night mode and language settings
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tun rejimi va Til selected')),
            );
          },
        ),
        const SizedBox(height: 10),
        _buildMenuItem(
          context,
          icon: Icons.logout,
          title: 'Chiqish', // Logout
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

  // Logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Red Header
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.taxi,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 20),
                    Icon(Icons.warning, color: Colors.white), // Warning icon
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Siz rostdan ham chiqmoqchimisiz?', // Uzbek header text
                        style: AppStyle.fontStyle.copyWith(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
              ),
              // White Body
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Agar chiqib ketsangiz, barcha sessiyalar tugatiladi. Davom etasizmi?', // Uzbek message
                  style: AppStyle.fontStyle.copyWith(
                    color: Colors.black,
                    fontSize: 11,
                  ),
                ),
              ),
              Divider(height: 1),
              SizedBox(height: 10),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.taxi,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Yo\'q',
                      style: AppStyle.fontStyle.copyWith(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      FirebaseAuth.instance.signOut(); // Sign out
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MainCivilPage()),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.taxi,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Ha',
                      style: AppStyle.fontStyle.copyWith(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
