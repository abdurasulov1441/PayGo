import 'package:flutter/material.dart';
import 'package:taksi/services/style/app_colors.dart';

class VehicleNumberWidget extends StatelessWidget {
  final Map<String, dynamic> vehicleData;

  const VehicleNumberWidget({super.key, required this.vehicleData});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      width: 140,
      height: 25,
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
                  size: 5,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  '${vehicleData['region_number']}',
                  style: const TextStyle(
                    fontFamily: 'Number',
                    fontSize: 10,
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
              const SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  '${vehicleData['plate_number']}',
                  style: const TextStyle(
                    fontFamily: 'Number',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            width: 10,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/flag_uz.png',
                width: 17,
                height: 7,
              ),
              Text(
                'UZ',
                style: TextStyle(
                  fontFamily: 'Number',
                  fontSize: 8,
                  color: AppColors.grade1,
                ),
              ),
            ],
          ),
          const Icon(
            Icons.circle,
            size: 5,
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}
