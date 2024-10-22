import 'package:flutter/material.dart';
import 'package:taksi/screens/new_user/driver_reg.dart';
import 'package:taksi/screens/new_user/passanger_reg.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  _RoleSelectionPageState createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  String? selectedRole; // Track the selected role

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    "Iltimos, qaysi rolni tanlaysiz",
                    style: AppStyle.fontStyle
                        .copyWith(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RoleCard(
                        icon: Icons.local_shipping,
                        label: "Haydovchi",
                        color: Colors.green[50]!,
                        isSelected: selectedRole == "Haydovchi",
                        onTap: () {
                          setState(() {
                            selectedRole = "Haydovchi";
                          });
                        },
                      ),
                      const SizedBox(width: 40),
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
                  if (selectedRole == "Haydovchi") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DriverRegistrationPage(),
                      ),
                    );
                  } else if (selectedRole == "Yo’lovchi") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PassengerRegistrationPage(),
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
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: AppColors.taxi, width: 4)
              : Border.all(color: Colors.transparent),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: AppColors.taxi),
            const SizedBox(height: 15),
            Text(label,
                style: AppStyle.fontStyle
                    .copyWith(color: Colors.black, fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
