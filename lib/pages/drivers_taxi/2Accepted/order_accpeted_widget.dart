import 'package:flutter/material.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class OrderAcceptedWidget extends StatelessWidget {
  final int orderNumber;
  final String status;
  final String customer;
  final String fromLocation;
  final String fromDateTime;
  final String toLocation;
  final String toDateTime;
  final String? peopleCount;
  final String? cargoName;
  final VoidCallback onReject;
  final VoidCallback onFinish;

  const OrderAcceptedWidget({
    super.key,
    required this.orderNumber,
    required this.status,
    required this.customer,
    required this.fromLocation,
    required this.fromDateTime,
    required this.toLocation,
    required this.toDateTime,
    this.peopleCount,
    this.cargoName,
    required this.onReject,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(width: 1, color: AppColors.backgroundColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(-4, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '# $orderNumber',
                style: AppStyle.fontStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grade1,
                ),
              ),
              _buildTag(status, Colors.green),
            ],
          ),
          const Divider(thickness: 1, height: 20),
          Row(
            children: [
              Text(
                'Buyurtmachi:',
                style: AppStyle.fontStyle.copyWith(color: AppColors.uiText),
              ),
              Text(
                ' $customer',
                style: AppStyle.fontStyle.copyWith(
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLocation('Qayerdan', fromLocation),
              Image.asset('assets/images/next.png', width: 30, height: 30),
              _buildLocation('Qayerga', toLocation),
            ],
          ),
          const SizedBox(height: 15),
          if (peopleCount != '0')
            Container(
              child: Row(
                children: [
                  Image.asset('assets/images/team.png', width: 30, height: 30),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Odam soni: $peopleCount',
                    style: AppStyle.fontStyle.copyWith(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              child: Row(
                children: [
                  Image.asset('assets/images/package.png',
                      width: 30, height: 30),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Yuk nomi: $cargoName',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.grade1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: onReject,
                  child: Text(
                    'Qabul qilish',
                    style: AppStyle.fontStyle.copyWith(
                      color: AppColors.backgroundColor,
                    ),
                  )),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.grade1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: onFinish,
                  child: Text(
                    'Buyurtmani tugatish',
                    style: AppStyle.fontStyle.copyWith(
                      color: AppColors.backgroundColor,
                    ),
                  )),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLocation(String label, String location) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: AppColors.uiText),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 5),
          Text(
            location,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}
