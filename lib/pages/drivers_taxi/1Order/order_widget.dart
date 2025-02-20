import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:taksi/services/style/app_colors.dart';
import 'package:taksi/services/style/app_style.dart';

class OrderWidget extends StatelessWidget {
  final int orderNumber;
  final String status;
  final String customer;
  final String fromLocation;
  final String fromDateTime;
  final String toLocation;
  final String toDateTime;
  final String? peopleCount;
  final String? cargoName;
  final VoidCallback onAccept;

  const OrderWidget({
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
    required this.onAccept,
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
        mainAxisSize: MainAxisSize.min, // Позволяет Column уменьшаться
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
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(toLocation),
                  SvgPicture.asset('assets/icons/fromto.svg',
                      width: 30, height: 120),
                  Text(fromLocation),
                ],
              ),
              Flexible(
                // ✅ Используем Flexible вместо Expanded
                fit: FlexFit
                    .loose, // ✅ Позволяет занимать пространство без ошибок
                child: Column(
                  mainAxisSize: MainAxisSize.min, // ✅ Минимальная высота
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Buyurtmachi: ',
                          style: AppStyle.fontStyle
                              .copyWith(color: AppColors.uiText),
                        ),
                        Text(
                          ' ${customer}',
                          style: AppStyle.fontStyle
                              .copyWith(fontSize: 16, color: AppColors.grade1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    if (peopleCount != '0')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Odam soni:',
                            style: AppStyle.fontStyle.copyWith(
                                fontSize: 14, color: AppColors.uiText),
                          ),
                          Text(
                            ' ${peopleCount}',
                            style: AppStyle.fontStyle.copyWith(
                                fontSize: 14, color: AppColors.grade1),
                          ),
                        ],
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Yuk nomi:',
                            style: AppStyle.fontStyle
                                .copyWith(color: AppColors.uiText),
                          ),
                          Text(
                            ' ${cargoName}',
                            style: AppStyle.fontStyle
                                .copyWith(color: AppColors.grade1),
                          ),
                        ],
                      ),
                    const SizedBox(height: 15),

                    /// **Spacer заменен на SizedBox(), чтобы избежать ошибки**
                    const SizedBox(height: 20),

                    /// **Кнопка теперь опускается вниз**
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.grade1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: onAccept,
                        child: Text(
                          'Qabul qilish',
                          style: AppStyle.fontStyle.copyWith(
                            color: AppColors.backgroundColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
}
