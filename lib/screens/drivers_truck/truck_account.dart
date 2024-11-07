import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taksi/screens/civil/civil_page.dart';
import 'package:taksi/screens/drivers_truck/obunalar.dart';
import 'package:taksi/screens/drivers_truck/payment.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class TruckDriverAccountPage extends StatefulWidget {
  const TruckDriverAccountPage({super.key});

  @override
  _TruckDriverAccountPageState createState() => _TruckDriverAccountPageState();
}

class _TruckDriverAccountPageState extends State<TruckDriverAccountPage> {
  Future<void> _refreshPage() async {
    setState(() {});
  }

  Future<void> _signOut(BuildContext context) async {
    _showLogoutDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Akkaunt', // Заголовок для водителей грузовиков
          style: AppStyle.fontStyle.copyWith(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: AppColors.taxi,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPage,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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

  Widget _buildProfileHeader() {
    final user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('truckdrivers')
          .where('email', isEqualTo: user?.email) // Find by email
          .get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        // Placeholder data
        String firstName = 'John';
        String lastName = 'Doe';
        String fullName = '$firstName $lastName';
        String formattedBalance = '0 UZS';
        String subscriptionPlan = 'No Plan';
        String formattedExpiration =
            'Obuna tugadi'; // Default message if expired

        // Replace placeholder data when actual data is available
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.docs.isNotEmpty) {
          final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;

          firstName = data['name'] ?? firstName;
          lastName = data['surname'] ?? lastName;
          fullName = '$firstName $lastName';

          int balance = data['balance'] ?? 0;
          formattedBalance = NumberFormat('#,###', 'en_US')
              .format(balance)
              .replaceAll(',', ' ');

          subscriptionPlan = data['subscription_plan'] ?? subscriptionPlan;
          Timestamp? expirationTimestamp = data['expired_date'];

          if (expirationTimestamp != null) {
            DateTime expirationDate = expirationTimestamp.toDate();
            if (expirationDate.isAfter(DateTime.now())) {
              Duration difference = expirationDate.difference(DateTime.now());
              int months = difference.inDays ~/ 30;
              int days = difference.inDays % 30;

              if (months >= 12) {
                int years = months ~/ 12;
                int remainingMonths = months % 12;
                formattedExpiration = remainingMonths > 0
                    ? '$years yil, $remainingMonths oy'
                    : '$years yil';
              } else {
                formattedExpiration =
                    months > 0 ? '$months oy, $days kun' : '$days kun';
              }
            } else {
              // Subscription expired, set message
              formattedExpiration = 'Obuna tugadi';
            }
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
                backgroundImage: AssetImage(
                  'assets/images/user.png',
                ), // Default avatar
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
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
                      'Balans: $formattedBalance',
                      style: AppStyle.fontStyle.copyWith(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildMenuItem(
          context,
          icon: Icons.account_balance_wallet,
          title: 'Balansni to\'ldirish',
          onTap: () {
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
          title: 'Obunalar',
          onTap: () {
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
          title: 'Tun rejimi va Til',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tun rejimi va Til selected')),
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
                    Icon(Icons.warning, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Siz rostdan ham chiqmoqchimisiz?',
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
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Agar chiqib ketsangiz, barcha sessiyalar tugatiladi. Davom etasizmi?',
                  style: AppStyle.fontStyle.copyWith(
                    color: Colors.black,
                    fontSize: 11,
                  ),
                ),
              ),
              Divider(height: 1),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
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
                      Navigator.of(context).pop();
                      FirebaseAuth.instance.signOut();
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
