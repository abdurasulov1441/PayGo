import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taksi/app/router.dart';
import 'package:taksi/services/request_helper.dart';
import 'package:taksi/services/utils/errors.dart';
import 'package:taksi/style/app_colors.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  _RoleSelectionPageState createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  String? selectedRole;
  List<dynamic> roles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRoles();
  }

  Future<void> fetchRoles() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await requestHelper.getWithAuth(
        '/services/zyber/api/users/get-roles',
      );

      setState(() {
        roles = response;
        isLoading = false;
      });
    } on UnauthenticatedError {
      context.go(Routes.loginScreen);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка сети. Попробуйте снова.')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateUserRole(int roleId) async {
    try {
      // Отправляем PUT-запрос на сервер через RequestHelper
      final response = await requestHelper.putWithAuth(
        '/services/zyber/api/users/update-user-role',
        {
          'role_id': roleId,
        },
      );

      if (response['success'] == true) {
        context.go(Routes.homeScreen);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response['message'] ?? 'Ошибка обновления роли.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка сети. Попробуйте снова.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
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
                      child: ListView.builder(
                        itemCount: roles.length,
                        itemBuilder: (context, index) {
                          final role = roles[index];
                          return RoleCard(
                            icon: Icons
                                .person, // Вы можете поменять иконки на основе роли
                            label: role['name'],
                            isSelected: selectedRole == role['name'],
                            onTap: () {
                              setState(() {
                                selectedRole = role['name'];
                              });
                            },
                          );
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: selectedRole != null
                          ? () {
                              if (selectedRole == roles.first['name']) {
                                updateUserRole(1);
                              } else {
                                print("Выбрана роль: $selectedRole");
                              }
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
