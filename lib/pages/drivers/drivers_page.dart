import 'package:flutter/material.dart';
import 'package:taksi/pages/drivers/account.dart';
import 'package:taksi/pages/drivers/acepted_orders.dart';
import 'package:taksi/pages/drivers/chat_page.dart';
import 'package:taksi/pages/drivers/history.dart';
import 'package:taksi/pages/drivers/orders.dart';
import 'package:taksi/style/app_colors.dart';

class DriverPage extends StatefulWidget {
  const DriverPage({super.key});

  @override
  _DriverPageState createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  int _selectedIndex = 0;

  // Define the pages corresponding to the BottomNavigationBar items
  static const List<Widget> _pages = <Widget>[
    BuyurtmalarPage(), // Orders
    AcceptedOrdersPage(), // Accepted Orders
    DriverOrderHistoryPage(), // History of Orders
    AkkauntPage(), // Account Page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white, // Цвет фона навбара
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining),
            label: 'Buyurtmalar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.car_repair),
            label: 'Qabul qilingan buyurtmalar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Buyurtma tarixi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Akkaunt',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal, // Цвет выбранного элемента
        unselectedItemColor: Colors.grey[600], // Цвет невыбранных элементов
        selectedLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ), // Стиль текста для выбранного элемента
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: Colors.grey[600],
        ), // Стиль текста для невыбранных элементов
        iconSize: 26, // Размер иконок
        type:
            BottomNavigationBarType.fixed, // Тип (фиксированный или плавающий)
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            //side: BorderSide()
          ),
          backgroundColor: AppColors.taxi,
          child: Icon(
            Icons.chat,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatPage()),
            );
          }),
    );
  }
}
