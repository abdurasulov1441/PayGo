import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taksi/pages/civil/history_truck.dart';
import 'package:taksi/pages/civil/historytaxi.dart';
import 'package:taksi/services/flushbar.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final user = FirebaseAuth.instance.currentUser;

  Future<void> signOut() async {
    final navigator = Navigator.of(context);
    await FirebaseAuth.instance.signOut();
    navigator.pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
  }

  void showCustomDialog(String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          title,
          style: AppStyle.fontStyle.copyWith(
              fontWeight: FontWeight.bold, color: AppColors.textColor),
        ),
        content: Text(
          content,
          style: AppStyle.fontStyle.copyWith(color: AppColors.textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Bekor qilish',
              style: AppStyle.fontStyle.copyWith(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.taxi,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Tasdiqlash',
              style: AppStyle.fontStyle.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.taxi,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        title: Text(
          'Sozlamalar',
          style: AppStyle.fontStyle.copyWith(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('user')
            .where('email', isEqualTo: user?.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('Foydalanuvchi ma’lumotlari topilmadi.'));
          }

          final userData =
              snapshot.data!.docs.first.data() as Map<String, dynamic>?;
          String userName = userData?['name'] ?? 'Noma’lum';
          String userSurname = userData?['surname'] ?? 'Noma’lum';
          String userEmail = userData?['email'] ?? 'Noma’lum';
          String userPhoneNumber = userData?['phone_number'] ?? 'Noma’lum';

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            children: [
              Card(
                color: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Foydalanuvchi ma’lumotlari',
                        style: AppStyle.fontStyle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      const SizedBox(height: 15),
                      buildSettingTile(
                        icon: Icons.person,
                        label: '$userName $userSurname',
                      ),
                      const Divider(),
                      buildSettingTile(
                        icon: Icons.email,
                        label: userEmail,
                      ),
                      const Divider(),
                      buildSettingTile(
                        icon: Icons.phone,
                        label: userPhoneNumber,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Card(
                color: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sozlamalar',
                        style: AppStyle.fontStyle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      const SizedBox(height: 15),
                      buildSettingTile(
                        icon: Icons.history,
                        label: 'Sayohat tarixi',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OrderHistoryPage()),
                          );
                        },
                      ),
                      const Divider(),
                      buildSettingTile(
                        icon: Icons.history,
                        label: 'Yuk tarixi',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TruckOrderHistoryPage()),
                          );
                        },
                      ),
                      const Divider(),
                      buildSettingTile(
                        icon: Icons.brightness_6,
                        label: 'Mavzuni o\'zgartirish',
                        onTap: () {
                          showCustomTopToast(context);
                        },
                      ),
                      const Divider(),
                      buildSettingTile(
                        icon: Icons.language,
                        label: 'Tilni o\'zgartirish',
                        onTap: () {
                          showCustomTopToast(context);
                        },
                      ),
                      const Divider(),
                      buildSettingTile(
                        icon: Icons.logout,
                        label: 'Chiqish',
                        onTap: () {
                          showCustomDialog(
                            'Chiqish',
                            'Haqiqatan ham chiqmoqchimisiz?',
                            () => signOut(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildSettingTile(
      {required IconData icon, required String label, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.taxi),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                label,
                style: AppStyle.fontStyle.copyWith(
                  fontSize: 16,
                  color: AppColors.textColor,
                ),
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}
