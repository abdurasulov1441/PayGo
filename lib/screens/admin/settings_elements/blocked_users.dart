import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class BlockedUsersPage extends StatelessWidget {
  const BlockedUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Banlangan foydalanuvchilar',
          style: AppStyle.fontStyle.copyWith(fontSize: 24),
        ),
        backgroundColor: AppColors.taxi,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('user')
                    .where('status', isEqualTo: 'inactive')
                    .snapshots(),
                builder: (context, userSnapshot) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('truckdrivers')
                        .where('status', isEqualTo: 'inactive')
                        .snapshots(),
                    builder: (context, driverSnapshot) {
                      if (!userSnapshot.hasData || !driverSnapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      var blockedUsers = userSnapshot.data!.docs;
                      var blockedDrivers = driverSnapshot.data!.docs;

                      if (blockedUsers.isEmpty && blockedDrivers.isEmpty) {
                        return Center(
                          child: Text(
                            'Banlangan foydalanuvchilar yo\'q.',
                            style: AppStyle.fontStyle,
                          ),
                        );
                      }

                      return ListView(
                        children: [
                          ...blockedUsers
                              .map((user) => _buildUserCard(user, 'Pasajir')),
                          ...blockedDrivers.map(
                              (driver) => _buildUserCard(driver, 'Haydovchi')),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Создание карточки для каждого заблокированного пользователя или водителя
  Widget _buildUserCard(DocumentSnapshot user, String role) {
    var userData = user.data() as Map<String, dynamic>?;
    String id = user.id; // Получение ID документа
    String name = userData?['name'] ?? 'Noma\'lum';
    String surname = userData?['surname'] ?? '';
    String phoneNumber = userData?['phone_number'] ?? 'N/A';
    String email = userData?['email'] ?? 'N/A';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 3,
      child: ListTile(
        leading: Icon(
          role == 'Pasajir' ? Icons.person : Icons.directions_car,
          color: AppColors.taxi,
          size: 40,
        ),
        title: Text(
          '$role ID: $id',
          style: AppStyle.fontStyle.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.taxi,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ism: $name', style: AppStyle.fontStyle),
            Text('Familiya: $surname', style: AppStyle.fontStyle),
            Text('Telefon: $phoneNumber', style: AppStyle.fontStyle),
            Text('Email: $email', style: AppStyle.fontStyle),
          ],
        ),
        trailing: Icon(Icons.block, color: Colors.red),
      ),
    );
  }
}
