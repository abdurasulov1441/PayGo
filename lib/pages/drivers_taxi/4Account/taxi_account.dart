import 'package:avatar_glow/avatar_glow.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:taksi/app/router.dart';
import 'package:taksi/services/db/cache.dart';
import 'package:taksi/services/request_helper.dart';
import 'package:taksi/style/app_colors.dart';

class TaxiAccountPage extends StatefulWidget {
  const TaxiAccountPage({super.key});

  @override
  State<TaxiAccountPage> createState() => _TaxiAccountPageState();
}

String name = '';
String phone_number = '';
String balance = '';

class _TaxiAccountPageState extends State<TaxiAccountPage> {
  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   _getUserInfo();
  // }

  Future<void> _getUserInfo() async {
    try {
      final response = await requestHelper.getWithAuth(
        '/services/zyber/api/users/get-user-info',
      );
      setState(() {
        name = response['name'];
        phone_number = response['phone_number'];
        balance = response['balance'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Row(
          children: [Text('error'.tr()), Text("$e")],
        )),
      );
    } finally {}
  }

  Future<void> _signOut() async {
    cache.clear();
    router.go(Routes.selsctLanguagePage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25)),
              gradient: LinearGradient(
                colors: [AppColors.grade2, AppColors.grade1],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.only(top: 60, bottom: 30),
            child: Column(
              children: [
                AvatarGlow(
                  child: Material(
                    elevation: 8.0,
                    shape: CircleBorder(),
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[100],
                      child: Image.asset(
                        'assets/images/car.png',
                        height: 50,
                      ),
                      radius: 30.0,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Balans: $balance so\'m',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    IconButton(
                        onPressed: () {
                          _getUserInfo();
                        },
                        icon: Icon(
                          Icons.refresh,
                          color: AppColors.backgroundColor,
                        ))
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                GestureDetector(
                    onTap: () => router.push(Routes.taxiBalancePage),
                    child: _buildOption(
                        'balansni_toldirish', 'Balansni to\'ldirish')),
                GestureDetector(
                    onTap: () => router.push(Routes.tarifsPage),
                    child: _buildOption('tariflar', 'Tariflar')),
                GestureDetector(
                    onTap: () => router.push(Routes.accountDetailInfoPage),
                    child: _buildOption('tariflar', 'Ma\'lumotlar')),
                GestureDetector(
                    onTap: () => router.push(Routes.paymentHistory),
                    child: _buildOption(
                        'transaction_history', 'To\'lovlar tarixi')),
                _buildOption('sozlamalar', 'Sozlamalar'),
                GestureDetector(
                    onTap: _signOut, child: _buildOption('chiqish', 'Chiqish')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(String icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FF),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/images/$icon.svg',
            color: AppColors.grade1,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        ],
      ),
    );
  }
}
