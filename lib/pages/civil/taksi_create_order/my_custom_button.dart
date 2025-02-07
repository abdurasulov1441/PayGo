import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class MyCustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final String? labelIcon;
  final bool isDropdown;

  const MyCustomButton({
    super.key,
    this.onPressed,
    this.labelIcon,
    required this.text,
    required this.isDropdown,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 5,
            backgroundColor: AppColors.ui,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    'assets/icons/$labelIcon.svg',
                    height: 20,
                    color: AppColors.uiText,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  if (text == 'Qayerdan' ||
                      text == 'Qayerga' ||
                      text == 'Vaqtni tanlang')
                    Text(
                      text,
                      style: AppStyle.fontStyle
                          .copyWith(fontSize: 16, color: AppColors.uiText),
                    )
                  else
                    Text(
                      text,
                      style: AppStyle.fontStyle
                          .copyWith(fontSize: 16, color: AppColors.iconColor),
                    ),
                ],
              ),
              SvgPicture.asset(
                'assets/icons/${isDropdown ? 'arrow' : 'arrow'}.svg',
                height: 20,
                color: isDropdown ? AppColors.uiText : AppColors.ui,
              ),
            ],
          )),
    );
  }
}
