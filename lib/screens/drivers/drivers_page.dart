import 'package:flutter/material.dart';
import 'package:taksi/screens/drivers/account.dart';
import 'package:taksi/screens/drivers/car_set.dart';
import 'package:taksi/screens/drivers/history.dart';
import 'package:taksi/screens/drivers/orders.dart';

class DriverPage extends StatefulWidget {
  const DriverPage({super.key});

  @override
  _DriverPageState createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    BuyurtmalarPage(),
    AvtomobilSozlamalariPage(),
    OrderHistory(),
    AkkauntPage(),
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
            label: 'Avtomobil sozlamalari',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Buyurtmalar tarixi',
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
