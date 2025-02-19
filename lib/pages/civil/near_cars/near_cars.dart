import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taksi/pages/civil/near_cars/widgets/botom_nav_bar.dart';
import 'package:taksi/pages/civil/near_cars/widgets/car_card_widget.dart';
import 'package:taksi/services/style/app_colors.dart';
import 'package:taksi/services/style/app_style.dart';

class CivilNearCars extends StatelessWidget {
  const CivilNearCars({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ui,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.backgroundColor,
          ),
          onPressed: () => context.pop(context),
        ),
        backgroundColor: AppColors.grade1,
        title: Text(
          'Sizga yaqin yengil mashinalari',
          style: AppStyle.fontStyle.copyWith(
              color: AppColors.backgroundColor,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          CarCardWidget(
            onPressed: () {
              showModalBottomSheetUser(context);
            },
          ),
        ],
      ),
    );
  }
}
