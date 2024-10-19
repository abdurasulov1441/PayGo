import 'package:flutter/material.dart';
import 'package:taksi/screens/civil/history.dart';
import 'package:taksi/screens/drivers/account.dart';
import 'package:taksi/screens/drivers/acepted_orders.dart';
import 'package:taksi/screens/drivers/history.dart';

import 'package:taksi/screens/drivers/orders.dart';

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
      appBar: AppBar(
        title: const Text('Haydovchi Paneli'),
        backgroundColor: Colors.teal,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
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
        selectedItemColor: Colors.teal,
        onTap: _onItemTapped,
      ),
    );
  }
}
