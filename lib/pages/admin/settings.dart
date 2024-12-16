import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:taksi/pages/admin/settings_elements/blocked_users.dart';
import 'package:taksi/pages/admin/settings_elements/call_center_information.dart';
import 'package:taksi/pages/admin/settings_elements/card_information.dart';
import 'package:taksi/pages/admin/settings_elements/history_payment.dart';
import 'package:taksi/pages/admin/settings_elements/hududlar_page.dart';
import 'package:taksi/pages/admin/settings_elements/tarif_edit_page.dart';
import 'package:taksi/services/flushbar.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.taxi, size: 32),
        title: Text(
          title,
          style: AppStyle.fontStyle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppStyle.fontStyle.copyWith(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.taxi),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildSettingCard(
                icon: FontAwesomeIcons.history,
                title: 'To\'lov tarixi',
                subtitle: 'Barcha to\'lovlar tarixi',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HistoryPaymentPage(),
                    ),
                  );
                },
              ),
              _buildSettingCard(
                icon: FontAwesomeIcons.ban,
                title: 'Banlangan foydalanuvchilar',
                subtitle: 'Banlangan foydalanuvchilarni ko\'rish',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlockedUsersPage(),
                    ),
                  );
                },
              ),
              _buildSettingCard(
                icon: FontAwesomeIcons.creditCard,
                title: 'Karta ma\'lumotlari',
                subtitle: 'Karta ma\'lumotlarini ko\'rish va yangilash',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditableCardInformationPage(),
                    ),
                  );
                },
              ),
              _buildSettingCard(
                icon: FontAwesomeIcons.mapMarkerAlt,
                title: 'Hududlar',
                subtitle: 'Barcha hududlarni boshqarish',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HududlarPage(),
                    ),
                  );
                },
              ),
              _buildSettingCard(
                icon: FontAwesomeIcons.phone,
                title: 'Aloqa ma\'lumotlari',
                subtitle: 'Aloqa va bog\'lanish ma\'lumotlari',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CallCenterInformationPage(),
                    ),
                  );
                },
              ),
              _buildSettingCard(
                icon: FontAwesomeIcons.tag,
                title: 'Tariflar',
                subtitle: 'Tarif rejalarini boshqarish',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TarifEditPage(),
                    ),
                  );
                },
              ),
              _buildSettingCard(
                icon: FontAwesomeIcons.cogs,
                title: 'Boshqa sozlamalar',
                subtitle: 'Qo\'shimcha sozlamalar',
                onTap: () {
                  showCustomTopToast(context);
                },
              ),
              const SizedBox(height: 20), // Отступ внизу для удобства
            ],
          ),
        ),
      ),
    );
  }
}
