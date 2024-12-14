import 'package:flutter/material.dart';
import 'package:taksi/style/app_colors.dart';

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
            children: [
              Text(
                "Rolingizni tanlang",
                style: TextStyle(
                  fontFamily: 'YourFontName',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RoleCard(
                      icon: Icons.person,
                      label: "Yo’lovchi",
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
                      isSelected: selectedRole == "Yuk mashina haydovchisi",
                      onTap: () {
                        setState(() {
                          selectedRole = "Yuk mashina haydovchisi";
                        });
                      },
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: selectedRole != null
                    ? () {
                        // Ваш код для перехода на следующий экран
                        print("Выбрана роль: $selectedRole");
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedRole != null
                      ? AppColors.grade1
                      : Colors.grey, // Активный/неактивный цвет
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Keyingisi",
                  style: TextStyle(
                    fontFamily: 'YourFontName',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
  final bool isSelected;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? AppColors.grade2 : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: AppColors.grade1),
            const SizedBox(width: 20),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'YourFontName',
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
