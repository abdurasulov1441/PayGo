import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taksi/services/style/app_colors.dart';
import 'package:taksi/services/style/app_style.dart';

class CivilNearTruck extends StatelessWidget {
  const CivilNearTruck({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Sizga yaqin yuk mashinalari',
          style: AppStyle.fontStyle.copyWith(
              color: AppColors.backgroundColor,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
    );
  }
}
