import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:taksi/services/request_helper.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class AccountDetailInfoTaksi extends StatefulWidget {
  const AccountDetailInfoTaksi({super.key});

  @override
  State<AccountDetailInfoTaksi> createState() => _AccountDetailInfoTaksiState();
}

class _AccountDetailInfoTaksiState extends State<AccountDetailInfoTaksi> {
  Map<String, dynamic>? userData;

  Future<void> _fetchDetailInfo() async {
    try {
      final response = await requestHelper
          .getWithAuth('/services/zyber/api/users/get-user-info', log: true);

      if (response != null && response is Map<String, dynamic>) {
        setState(() {
          userData = response;
        });
      }
    } catch (e) {
      setState(() {
        userData = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDetailInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.backgroundColor,
            )),
        centerTitle: true,
        title: Text(
          'Profil',
          style: AppStyle.fontStyle
              .copyWith(color: AppColors.backgroundColor, fontSize: 20),
        ),
        backgroundColor: AppColors.grade1,
      ),
      body: userData == null
          ? Center(
              child: LottieBuilder.asset('assets/lottie/loading.json'),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.grade1,
                      child: Text(
                        userData!['name'][0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userData!['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userData!['role'],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    DavlatRaqami(
                      vehicleData: userData!['vehicle'],
                    ),
                    _buildInfoRow(
                      context,
                      icon: Icons.phone,
                      label: 'Номер телефона',
                      value: userData!['phone_number'],
                    ),
                    _buildInfoRow(
                      context,
                      icon: Icons.monetization_on,
                      label: 'Баланс',
                      value: '${userData!['balance']} сум',
                    ),
                    _buildInfoRow(
                      context,
                      icon: Icons.car_rental,
                      label: 'Автомобиль',
                      value:
                          '${userData!['vehicle']['brand']} ${userData!['vehicle']['model']}',
                    ),
                    _buildInfoRow(
                      context,
                      icon: Icons.location_on,
                      label: 'Откуда',
                      value: userData!['vehicle']['from_location'],
                    ),
                    _buildInfoRow(
                      context,
                      icon: Icons.location_on,
                      label: 'Куда',
                      value: userData!['vehicle']['to_location'],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoRow(BuildContext context,
      {required IconData icon, required String label, required String value}) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.ui,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      margin: EdgeInsets.symmetric(
        vertical: 5,
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.grade1),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DavlatRaqami extends StatelessWidget {
  final Map<String, dynamic> vehicleData;

  const DavlatRaqami({super.key, required this.vehicleData});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      width: 240,
      height: 45,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textColor),
        color: AppColors.ui,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: const Icon(
                  Icons.circle,
                  size: 10,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${vehicleData['region_number']}',
                  style: const TextStyle(
                    fontFamily: 'Number',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const VerticalDivider(
                color: Colors.black,
                width: 1,
                thickness: 1,
              ),
              const SizedBox(width: 20),
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  '${vehicleData['plate_number']}',
                  style: const TextStyle(
                    fontFamily: 'Number',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            width: 20,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/flag_uz.png',
                width: 25,
                height: 15,
              ),
              Text(
                'UZ',
                style: TextStyle(
                  fontFamily: 'Number',
                  fontSize: 10,
                  color: AppColors.grade1,
                ),
              ),
            ],
          ),
          const Icon(
            Icons.circle,
            size: 10,
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}
