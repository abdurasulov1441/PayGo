import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:taksi/app/router.dart';
import 'package:taksi/style/app_colors.dart';

class TaxiAccountPage extends StatelessWidget {
  const TaxiAccountPage({super.key});

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
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/images/user.png'),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Abdulaziz Abdurasulov',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Balans : 123 000 s\'om',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.refresh,
                          color: AppColors.backgroundColor,
                        ))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Tarif tugash muddati : 2025.08.19',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                )
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
                _buildOption('tariflar', 'Ma\'lumotlar'),
                GestureDetector(
                    onTap: () => router.push(Routes.paymentHistory),
                    child: _buildOption(
                        'transaction_history', 'To\'lovlar tarixi')),
                _buildOption('sozlamalar', 'Sozlamalar'),
                _buildOption('chiqish', 'Chiqish'),
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
