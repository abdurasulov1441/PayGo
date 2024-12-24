import 'package:flutter/material.dart';
import 'package:taksi/app/router.dart';
import 'package:taksi/services/drawer/my_elevated_button_for_drawer.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class MyCostomDrawer extends StatelessWidget {
  const MyCostomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 60,
            ),
            Row(
              children: [
                CircleAvatar(
                  // child: Image.asset('assets/images/user.png'),
                  radius: 30,
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Text('Abdulaziz'),
                    Text('+998900961704'),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 10,
                ),
                Text('Balans : 26 000 so\'m'),
                SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 3,
                      backgroundColor: AppColors.grade1,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () {
                      // context.go(Routes.civilPage);
                    },
                    child: Text(
                      'To\'ldirish',
                      style: AppStyle.fontStyle.copyWith(color: Colors.white),
                    ))
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            const Divider(),
            MyElevatedButtonForDrawer(
              icon: Icons.home,
              name: 'Tariflar',
              route: Routes.civilPage,
            ),
            const SizedBox(
              height: 10,
            ),
            MyElevatedButtonForDrawer(
              icon: Icons.home,
              name: 'Yuk buyurtmasi tarixi',
              route: Routes.civilPage,
            ),
            const SizedBox(
              height: 10,
            ),
            MyElevatedButtonForDrawer(
              icon: Icons.home,
              name: 'Yuk buyurtmasi tarixi',
              route: Routes.civilPage,
            ),
            const SizedBox(
              height: 10,
            ),
            MyElevatedButtonForDrawer(
              icon: Icons.home,
              name: 'To\'lovlar tarixi',
              route: Routes.civilPage,
            ),
            const SizedBox(
              height: 10,
            ),
            MyElevatedButtonForDrawer(
              icon: Icons.settings,
              name: 'Sozlamalar',
              route: Routes.civilPage,
            ),
            const Spacer(),
            const Text(
              'Powered by ZyberGruop app-center.uz',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
