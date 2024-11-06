import 'package:flutter/material.dart';
import 'package:taksi/screens/new_user/taxi_reg.dart';
import 'package:taksi/screens/new_user/passanger_reg.dart';
import 'package:taksi/screens/new_user/truck_reg.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  _RoleSelectionPageState createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Qaysi rolni tanlaysiz",
                    style: AppStyle.fontStyle
                        .copyWith(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RoleCard(
                        icon: Icons.person,
                        label: "Yo’lovchi",
                        color: Colors.green[50]!,
                        isSelected: selectedRole == "Yo’lovchi",
                        onTap: () {
                          setState(() {
                            selectedRole = "Yo’lovchi";
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      RoleCard(
                        icon: Icons.local_taxi,
                        label: "Taxi haydovchisi",
                        color: Colors.green[50]!,
                        isSelected: selectedRole == "Taxi haydovchisi",
                        onTap: () {
                          setState(() {
                            selectedRole = "Taxi haydovchisi";
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      RoleCard(
                        icon: Icons.local_shipping,
                        label: "Yuk mashina haydovchisi",
                        color: Colors.green[50]!,
                        isSelected: selectedRole == "Yuk mashina haydovchisi",
                        onTap: () {
                          setState(() {
                            selectedRole = "Yuk mashina haydovchisi";
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              // The button is placed at the bottom now
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.taxi,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  if (selectedRole == "Yo’lovchi") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PassengerRegistrationPage(),
                      ),
                    );
                  } else if (selectedRole == "Taxi haydovchisi") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DriverRegistrationPage(),
                      ),
                    );
                  } else if (selectedRole == "Yuk mashina haydovchisi") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const TruckDriverRegistrationPage(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Iltimos, rolni tanlang")),
                    );
                  }
                },
                child: Text(
                  "Kettik",
                  style: AppStyle.fontStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(left: 20),
        width: double.infinity,
        height: 70,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: AppColors.taxi, width: 4)
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, size: 50, color: AppColors.taxi),
            const SizedBox(width: 20),
            Text(
              label,
              style: AppStyle.fontStyle.copyWith(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
