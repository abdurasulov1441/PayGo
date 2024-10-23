import 'package:flutter/material.dart';

import 'package:taksi/screens/drivers/chat_page.dart';
import 'package:taksi/screens/drivers_truck/truck_account.dart';
import 'package:taksi/screens/drivers_truck/truck_history.dart';
import 'package:taksi/screens/drivers_truck/truck_orders.dart';

import 'package:taksi/style/app_colors.dart';

import 'truck_acepted_orders.dart';

class TruckDriverPage extends StatefulWidget {
  const TruckDriverPage({super.key});

  @override
  _TruckDriverPageState createState() => _TruckDriverPageState();
}

class _TruckDriverPageState extends State<TruckDriverPage> {
  int _selectedIndex = 0;

  // Define the pages corresponding to the BottomNavigationBar items
  static const List<Widget> _pages = <Widget>[
    TruckOrdersPage(), // Orders for trucks
    TruckAcceptedOrdersPage(), // Accepted Truck Orders
    TruckOrderHistoryPage(), // History of Truck Orders
    TruckDriverAccountPage(), // Account Page for truck drivers
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
        backgroundColor: Colors.white, // Background color of navbar
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Buyurtmalar', // Orders
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.done),
            label: 'Qabul qilingan', // Accepted Orders
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Buyurtma tarixi', // Order History
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Akkaunt', // Account
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal, // Selected item color
        unselectedItemColor: Colors.grey[600], // Unselected items color
        selectedLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ), // Style for selected label
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: Colors.grey[600],
        ), // Style for unselected labels
        iconSize: 26, // Icon size
        type: BottomNavigationBarType.fixed, // Fixed navbar type
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
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
        },
      ),
    );
  }
}
