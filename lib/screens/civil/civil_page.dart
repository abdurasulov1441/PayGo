import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taksi/screens/civil/create_order_truck.dart';
import 'package:taksi/screens/civil/delivery_page.dart';
import 'package:taksi/screens/civil/account_screen.dart';
import 'package:taksi/screens/sign/login_screen.dart';
import 'package:taksi/services/flushbar.dart';

import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart'; // Assuming AppStyle is in this file

class MainCivilPage extends StatelessWidget {
  const MainCivilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user =
        FirebaseAuth.instance.currentUser; // Get the current user

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.taxi,
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: () {
              if (user != null) {
                // If user is logged in, navigate to AccountScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AccountScreen()),
                );
              } else {
                // If not logged in, navigate to LoginScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://i.pinimg.com/originals/ff/a0/9a/ffa09aec412db3f54deadf1b3781de2a.png'),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              color: AppColors.taxi,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                Text(
                  'Tizimga xush kelibsiz!',
                  style: AppStyle.fontStyle.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white,
                  ),
                  width: 100,
                  height: 100,
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 100,
                    height: 100,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding:
                EdgeInsets.only(top: 170), // Adjust this for grid placement
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Barcha transportlar',
                    style: AppStyle.fontStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (user != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DeliveryPage()),
                          );
                        } else {
                          _showLoginDialog(
                              context); // Show registration dialog if not logged in
                        }
                      },
                      child: transportCard(
                        'Yuk mashinasi',
                        Icons.local_shipping,
                        Colors.teal,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (user != null) {
                          showCustomTopToast(context);
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (context) => TaxiPage()),
                          // );
                        } else {
                          _showLoginDialog(context);
                        }
                      },
                      child: transportCard(
                        'Taksi',
                        Icons.local_taxi,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Buyurtma berish',
                    style: AppStyle.fontStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (user != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CreateOrderTruck()),
                          );
                        } else {
                          _showLoginDialog(context);
                        }
                      },
                      child: transportCard(
                        'Yuk mashinasi',
                        Icons.local_shipping,
                        Colors.teal,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (user != null) {
                          showCustomTopToast(context);
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => CreateOrderTaksi()),
                          // );
                        } else {
                          _showLoginDialog(context);
                        }
                      },
                      child: transportCard(
                        'Taksi',
                        Icons.local_taxi,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget transportCard(String title, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            radius: 30,
            child: Icon(icon, color: color, size: 30),
          ),
          SizedBox(height: 10),
          Text(
            title,
            style: AppStyle.fontStyle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showLoginDialog(BuildContext context) {
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
              // Red Header
              Container(
                height: 50,
                //padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.taxi, // Red header background
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Icon(Icons.warning, color: Colors.white), // Warning icon
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ro‘yxatdan o‘tishingiz kerak', // Header text
                        style: AppStyle.fontStyle.copyWith(
                          color: Colors.white, // White text
                          fontSize: 12, // Smaller font size
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
              // White Body
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Ushbu xizmatdan foydalanish uchun tizimga kirishingiz kerak. Ro‘yxatdan o‘tmoqchimisiz?',
                  style: AppStyle.fontStyle.copyWith(
                    color: Colors.black, // Black text for the body
                    fontSize: 11, // Smaller font size for body text
                  ),
                ),
              ),
              Divider(height: 1),
              SizedBox(
                height: 10,
              ),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    style: TextButton.styleFrom(
                      backgroundColor:
                          AppColors.taxi, // Red background for 'YES' button
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Yo\'q',
                      style: AppStyle.fontStyle.copyWith(
                          fontSize: 14, // Smaller font size for 'Yes' button
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold // White text for 'YES' button
                          ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor:
                          AppColors.taxi, // Red background for 'YES' button
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Ha',
                      style: AppStyle.fontStyle.copyWith(
                          fontSize: 14, // Smaller font size for 'Yes' button
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold // White text for 'YES' button
                          ),
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
