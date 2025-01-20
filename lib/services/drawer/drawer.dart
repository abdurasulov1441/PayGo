import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:taksi/app/router.dart';
import 'package:taksi/services/db/cache.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class MyCustomDrawer extends StatelessWidget {
  const MyCustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> signOut() async {
      cache.clear();
      router.go(Routes.selsctLanguagePage);
    }

    return Drawer(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          // Размытие и прозрачный задний фон
          BackdropFilter(
            filter:
                ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Степень размытия
            child: Container(
              color: Colors.white.withOpacity(0.3), // Прозрачность
            ),
          ),

          // Контент Drawer
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 70,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  CircleAvatar(
                    radius: 30,
                    child: Image.asset('assets/images/user.png'),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Abdulaziz',
                        style: AppStyle.fontStyle
                            .copyWith(color: AppColors.backgroundColor),
                      ),
                      Text(
                        '+998900961704',
                        style: AppStyle.fontStyle
                            .copyWith(color: AppColors.backgroundColor),
                      ),
                    ],
                  ),
                ],
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  children: [
                    _buildMenuItem(
                      icon: Icons.home,
                      text: 'Home',
                      onTap: () {
                        Navigator.of(context).pushNamed(Routes.civilPage);
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.explore,
                      text: 'Explore',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.event,
                      text: 'My Events',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.task,
                      text: 'Tasks',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.people,
                      text: 'Invite Friends',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.settings,
                      text: 'Settings',
                      onTap: () {},
                    ),
                    const Divider(),
                    _buildMenuItem(
                      icon: Icons.info,
                      text: 'About',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.logout,
                      text: 'Sign Out',
                      onTap: () {
                        signOut();
                      },
                    ),
                  ],
                ),
              ),

              // Нижний текст
              Padding(
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: Text(
                    'Powered by ZyberGroup app-center.uz',
                    style: AppStyle.fontStyle.copyWith(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.grade2),
      title: Text(
        text,
        style: AppStyle.fontStyle.copyWith(
          fontSize: 16,
          color: AppColors.backgroundColor,
        ),
      ),
      onTap: onTap,
    );
  }
}
