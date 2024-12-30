import 'package:flutter/material.dart';
import 'package:taksi/app/router.dart';
import 'package:taksi/services/drawer/my_elevated_button_for_drawer.dart';

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
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     SizedBox(
            //       width: 10,
            //     ),
            //     Text('Balans : 26 000 so\'m'),
            //     SizedBox(
            //       width: 10,
            //     ),
            //     ElevatedButton(
            //       style: ElevatedButton.styleFrom(
            //         elevation: 3,
            //         backgroundColor: Colors.blue,
            //         padding:
            //             const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(8.0),
            //         ),
            //       ),
            //       onPressed: () async {
            //         final url = Uri.parse(
            //             'https://my.click.uz/services/pay?service_id=63738&merchant_id=33627&amount=1000&transaction_param=1&return_url=app-center.uz');
            //         if (!await launchUrl(url,
            //             mode: LaunchMode.inAppBrowserView)) {
            //           throw Exception('Could not launch $url');
            //         }
            //       },
            //       child: const Text(
            //         'To\'ldirish',
            //         style: TextStyle(color: Colors.white),
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 10),
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
