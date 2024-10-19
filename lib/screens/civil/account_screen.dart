import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taksi/screens/civil/history.dart';
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

  Future<void> deleteUserData() async {
    await FirebaseFirestore.instance.collection('user').doc(user!.uid).delete();
    await signOut();
  }

  Future<void> changeProfile() async {
    await FirebaseFirestore.instance.collection('user').doc(user!.uid).delete();
  }

  void showFeatureInDevelopmentMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Bu funksiya hozirda ishlab chiqilmoqda va tez orada mavjud bo‘ladi.'),
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
        actions: [
          IconButton(
            icon: const Icon(
              Icons.done,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('user')
            .doc(user!.uid)
            .snapshots(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = userSnapshot.data!.data() as Map<String, dynamic>?;

          String userName = userData?['name'] ?? 'Noma’lum';
          String userLastName = userData?['lastName'] ?? 'Noma’lum';
          String userEmail = userData?['email'] ?? 'Noma’lum';
          String userPhoneNumber = userData?['phoneNumber'] ?? 'Noma’lum';

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            children: [
              // First Card: Account Information Section
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
                        label: '$userName $userLastName',
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

              // Second Card: Settings Options Section
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
                        icon: Icons.brightness_6,
                        label: 'Mavzuni o\'zgartirish',
                        onTap: () {
                          showFeatureInDevelopmentMessage(context);
                        },
                      ),
                      const Divider(),
                      buildSettingTile(
                        icon: Icons.language,
                        label: 'Tilni o\'zgartirish',
                        onTap: () {
                          showFeatureInDevelopmentMessage(context);
                        },
                      ),
                      const Divider(),
                      buildSettingTile(
                        icon: Icons.directions_car,
                        label: 'Haydovchi sifatida kiring',
                        onTap: () async {
                          await changeProfile();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/home',
                            (Route<dynamic> route) => false,
                          );
                        },
                      ),
                      const Divider(),
                      buildSettingTile(
                        icon: Icons.delete_forever,
                        label: 'Ma\'lumotlarni o\'chirish',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Tasdiqlash'),
                                content: const Text(
                                    'Ma’lumotlaringizni o‘chirib tashlamoqchimisiz?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Bekor qilish'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      deleteUserData();
                                      Navigator.pop(context);
                                    },
                                    child: const Text('O\'chirish'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      const Divider(),
                      buildSettingTile(
                        icon: Icons.logout,
                        label: 'Chiqish',
                        onTap: () => signOut(),
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

  // Custom ListTile for settings
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
