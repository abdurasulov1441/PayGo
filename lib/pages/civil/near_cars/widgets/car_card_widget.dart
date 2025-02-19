import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taksi/pages/civil/near_cars/widgets/vehicle_number_widget.dart';
import 'package:taksi/services/style/app_colors.dart';
import 'package:taksi/services/style/app_style.dart';

class CarCardWidget extends StatelessWidget {
  final VoidCallback onPressed;
  const CarCardWidget({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Image.asset(
                    'assets/images/car_for_widget.png',
                    width: 100,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  Text(
                    '1.35 km',
                    style: AppStyle.fontStyle.copyWith(
                      fontSize: 18,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Haydovchi',
                          style: AppStyle.fontStyle.copyWith(
                            fontSize: 12,
                            color: AppColors.uiText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Raximov Voris Avazbek o‘g‘li',
                          style: AppStyle.fontStyle.copyWith(
                            fontSize: 12,
                            color: AppColors.grade1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Telefon',
                          style: AppStyle.fontStyle.copyWith(
                            fontSize: 12,
                            color: AppColors.uiText,
                          ),
                        ),
                        Text(
                          '+998 99 123 45 67',
                          style: AppStyle.fontStyle.copyWith(
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mashina nomi',
                          style: AppStyle.fontStyle.copyWith(
                            fontSize: 12,
                            color: AppColors.uiText,
                          ),
                        ),
                        Text(
                          'Chevrolet Lacetti',
                          style: AppStyle.fontStyle.copyWith(
                            fontSize: 12,
                            color: AppColors.grade1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mashina raqami',
                          style: AppStyle.fontStyle.copyWith(
                            fontSize: 12,
                            color: AppColors.uiText,
                          ),
                        ),
                        Row(
                          children: [
                            const SizedBox(width: 4),
                            VehicleNumberWidget(
                              vehicleData: {
                                'region_number': '01',
                                'plate_number': '123 ABC',
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Band qilingan joy',
                            style: AppStyle.fontStyle.copyWith(
                              fontSize: 12,
                              color: AppColors.uiText,
                            )),
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/seat.svg',
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 4),
                            SvgPicture.asset(
                              'assets/icons/seat.svg',
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 4),
                            SvgPicture.asset(
                              'assets/icons/seat_off.svg',
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 4),
                            SvgPicture.asset(
                              'assets/icons/seat_off.svg',
                              width: 24,
                              height: 24,
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    children: [
                      Text(
                        'Bahosi',
                        style: AppStyle.fontStyle.copyWith(
                          fontSize: 14,
                          color: AppColors.uiText,
                        ),
                      ),
                      Text(
                        '4.2',
                        style: AppStyle.fontStyle.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF28627F)),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < 4 ? Icons.star : Icons.star_border,
                        color: Color(0xFF28627F),
                        size: 33,
                      );
                    }),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFCCFFC8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Qabul qilish',
                  style: AppStyle.fontStyle.copyWith(
                    fontSize: 14,
                    color: Color(0xFF007111),
                    //fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
