import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:taksi/screens/admin/balance_check.dart';
import 'package:taksi/screens/admin/order_statistic.dart';
import 'package:taksi/screens/admin/settings.dart';
import 'package:taksi/screens/admin/user_statistic.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminDashboard> {
  int _currentIndex = 0;

  int accountVerificationCount = 0;
  int balanceRequestCount = 0; // Количество транзакций с статусом "unchecked"

  @override
  void initState() {
    super.initState();
    fetchPendingTransactionsCount(); // Получение количества транзакций
  }

  // Получение количества транзакций со статусом "unchecked"
  Future<void> fetchPendingTransactionsCount() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('status', isEqualTo: 'unchecked')
        .get();

    setState(() {
      balanceRequestCount = querySnapshot.docs.length;
    });
  }

  // Список страниц для каждого раздела
  final List<Widget> _pages = [
    OrderStatisticsPage(),
    UserDriverStatisticsPage(),
    BalanceRequestsPage(),
    AdminSettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(_getPageTitle(_currentIndex),
            style: AppStyle.fontStyle.copyWith(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.taxi,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          _buildBottomNavigationBarItem(
              icon: Icons.insert_chart,
              label: 'Buyurtmalar',
              count: 0), // Убираем счетчик
          _buildBottomNavigationBarItem(
              icon: Icons.people,
              label: 'Foydalanuvchi va haydovchi',
              count: 0), // Убираем счетчик
          _buildBottomNavigationBarItem(
              icon: Icons.account_balance_wallet,
              label: 'Balansni to\'ldirish',
              count: balanceRequestCount), // Счётчик транзакций "unchecked"

          _buildBottomNavigationBarItem(
              icon: Icons.settings, label: 'Sozlamalar', count: 0),
        ],
        selectedItemColor: AppColors.taxi,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: AppStyle.fontStyle.copyWith(color: AppColors.taxi),
        unselectedLabelStyle: AppStyle.fontStyle.copyWith(color: Colors.grey),
      ),
    );
  }

  // Построение элемента BottomNavigationBar с бейджем
  BottomNavigationBarItem _buildBottomNavigationBarItem({
    required IconData icon,
    required String label,
    required int count,
  }) {
    return BottomNavigationBarItem(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, size: 30),
          if (count > 0)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                constraints: BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      label: label,
    );
  }

  // Функция для отображения заголовка страницы в AppBar
  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Buyurtmalar statistikasi';
      case 1:
        return 'Foydalanuvchi va haydovchi statistikasi';
      case 2:
        return 'Balansni to\'ldirish so\'rovlari';
      case 3:
        return 'Sozlamalar';
      default:
        return 'Admin Panel';
    }
  }
}
