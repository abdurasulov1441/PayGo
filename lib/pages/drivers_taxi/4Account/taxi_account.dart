import 'package:avatar_glow/avatar_glow.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:taksi/app/router.dart';
import 'package:taksi/services/db/cache.dart';
import 'package:taksi/services/request_helper.dart';
import 'package:taksi/services/style/app_colors.dart';
import 'package:taksi/services/style/app_style.dart';

class TaxiAccountPage extends StatefulWidget {
  const TaxiAccountPage({super.key});

  @override
  State<TaxiAccountPage> createState() => _TaxiAccountPageState();
}

String name = '';
String phoneNumber = '';
String balance = '';

class _TaxiAccountPageState extends State<TaxiAccountPage> {
  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundColor,
          title:  Text('Akkuntdan chiqmoqchimisz?',style: AppStyle.fontStyle.copyWith(fontSize: 20),textAlign: TextAlign.center,),
          content:  Text('Agar chiqsangiz, qayta kirish talab qilinadi, va keshlaringiz o\'chiriladi.',style: AppStyle.fontStyle.copyWith(fontSize: 16),textAlign: TextAlign.center,),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: AppColors.ui),
                                onPressed: () {
                  Navigator.of(context).pop();
                                },
                                child:  Text('Yo\'q',style: AppStyle.fontStyle.copyWith(fontSize: 16,color: AppColors.textColor),),
                              ),
                ),
                SizedBox(width: 20,),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.red),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _signOut();
                },
                child:  Text('Ha',style: AppStyle.fontStyle.copyWith(fontSize: 16,color: AppColors.backgroundColor),),
              ),
            ),],)
          ],
        );
      },
    );
  }

  Future<void> _getUserInfo() async {
    try {
      final response = await requestHelper
          .getWithAuth('/services/zyber/api/users/get-user-info', log: true);
      setState(() {
        name = response['name'];
        phoneNumber = response['phone_number'];
        balance = response['balance'];
        final accessToken = cache.getString('user_token');
        print(accessToken);
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
    router.go(Routes.loginScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _getUserInfo,
        color: AppColors.grade1,
        child: Column(
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
                        radius: 30.0,
                        child: Image.asset(
                          'assets/images/car.png',
                          height: 50,
                        ),
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
                          fontSize: 20,
                        ),
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
                  GestureDetector(
                      onTap: () => router.push(Routes.settingsPage),
                      child: _buildOption('sozlamalar', 'Sozlamalar')),
                  GestureDetector(
                      onTap: () {
                        _showLogoutDialog(context);
                      },
                      child: _buildOption('chiqish', 'Chiqish')),
                ],
              ),
            ),
          ],
        ),
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
